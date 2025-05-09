//CDKTF 4 VPCs en dos regiones

import { Construct } from 'constructs';
import { App, TerraformStack, TerraformOutput } from 'cdktf';
import { AwsProvider, Vpc, Subnet, InternetGateway, RouteTable, Route, RouteTableAssociation, SecurityGroup, Instance } from '@cdktf/provider-aws';

interface VpcConfig {
  name: string;
  cidr: string;
  region: string;
  az: string;
}

class MultiVpcStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    const vpcs: VpcConfig[] = [
      { name: 'MyVPCa', cidr: '10.0.0.0/16', region: 'us-east-1', az: 'us-east-1a' },
      { name: 'MyVPCb', cidr: '10.1.0.0/16', region: 'us-east-1', az: 'us-east-1b' },
      { name: 'MyVPCc', cidr: '10.2.0.0/16', region: 'us-west-2', az: 'us-west-2a' },
      { name: 'MyVPCd', cidr: '10.3.0.0/16', region: 'us-west-2', az: 'us-west-2b' }
    ];

    vpcs.forEach((vpcConfig, index) => {
      const provider = new AwsProvider(this, `aws-${index}`, {
        region: vpcConfig.region,
        alias: vpcConfig.region.replace('-', '') + index
      });

      const vpc = new Vpc(this, `Vpc-${index}`, {
        provider: provider,
        cidrBlock: vpcConfig.cidr,
        tags: { Name: vpcConfig.name }
      });

      const subnet = new Subnet(this, `Subnet-${index}`, {
        provider: provider,
        vpcId: vpc.id,
        cidrBlock: vpcConfig.cidr.replace('/16', '/24'),
        availabilityZone: vpcConfig.az,
        mapPublicIpOnLaunch: true,
        tags: { Name: `${vpcConfig.name}-subnet` }
      });

      const igw = new InternetGateway(this, `IGW-${index}`, {
        provider: provider,
        vpcId: vpc.id,
        tags: { Name: `${vpcConfig.name}-igw` }
      });

      const routeTable = new RouteTable(this, `RouteTable-${index}`, {
        provider: provider,
        vpcId: vpc.id,
        tags: { Name: `${vpcConfig.name}-rt` }
      });

      new Route(this, `DefaultRoute-${index}`, {
        provider: provider,
        routeTableId: routeTable.id,
        destinationCidrBlock: '0.0.0.0/0',
        gatewayId: igw.id
      });

      new RouteTableAssociation(this, `RouteAssoc-${index}`, {
        provider: provider,
        subnetId: subnet.id,
        routeTableId: routeTable.id
      });

      const sg = new SecurityGroup(this, `SG-${index}`, {
        provider: provider,
        vpcId: vpc.id,
        name: `${vpcConfig.name}-sg`,
        description: 'Allow SSH and HTTP',
        ingress: [
          { fromPort: 22, toPort: 22, protocol: 'tcp', cidrBlocks: ['0.0.0.0/0'] },
          { fromPort: 80, toPort: 80, protocol: 'tcp', cidrBlocks: ['0.0.0.0/0'] }
        ],
        egress: [
          { fromPort: 0, toPort: 0, protocol: '-1', cidrBlocks: ['0.0.0.0/0'] }
        ],
        tags: { Name: `${vpcConfig.name}-sg` }
      });

      const instance = new Instance(this, `Instance-${index}`, {
        provider: provider,
        ami: 'ami-0e449927258d45bc4',
        instanceType: 't3.micro',
        subnetId: subnet.id,
        vpcSecurityGroupIds: [sg.id],
        associatePublicIpAddress: true,
        userData: `
#!/bin/bash
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf install -y mariadb105-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<?php phpinfo(); ?>" > index.php
mv index.php /var/www/html/index.php
`,
        tags: { Name: `${vpcConfig.name}-instance` }
      });

      new TerraformOutput(this, `instance-ip-${index}`, {
        value: instance.publicIp,
      });
    });
  }
}

const app = new App();
new MultiVpcStack(app, 'multi-vpc-cdktf');
app.synth();
