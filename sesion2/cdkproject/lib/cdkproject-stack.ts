import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';

export class CdkprojectStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Crear VPC
    const vpc = new ec2.CfnVPC(this, 'MyVpc', {
      cidrBlock: '10.0.0.0/16',
      enableDnsHostnames: true,
      enableDnsSupport: true,
      tags: [{ key: 'Name', value: 'MyVpc' }],
    });

    // Crear Internet Gateway
    const igw = new ec2.CfnInternetGateway(this, 'MyIgw', {
      tags: [{ key: 'Name', value: 'MyIgw' }],
    });

    // Asociar IGW a VPC
    new ec2.CfnVPCGatewayAttachment(this, 'MyIgwAttachment', {
      vpcId: vpc.ref,
      internetGatewayId: igw.ref,
    });

    // Crear Subnet pública
    const subnet = new ec2.CfnSubnet(this, 'MyPublicSubnet', {
      vpcId: vpc.ref,
      cidrBlock: '10.0.0.0/24',
      availabilityZone: 'us-east-1a',
      mapPublicIpOnLaunch: true,
      tags: [{ key: 'Name', value: 'MyPublicSubnet' }],
    });

    // Crear Route Table
    const routeTable = new ec2.CfnRouteTable(this, 'MyRouteTable', {
      vpcId: vpc.ref,
      tags: [{ key: 'Name', value: 'MyRouteTable' }],
    });

    new ec2.CfnSubnetRouteTableAssociation(this, 'MySubnetAssociation', {
      subnetId: subnet.ref,
      routeTableId: routeTable.ref,
    });

    new ec2.CfnRoute(this, 'DefaultRoute', {
      routeTableId: routeTable.ref,
      destinationCidrBlock: '0.0.0.0/0',
      gatewayId: igw.ref,
    });

    // Crear Security Group sin reglas inline
    const securityGroup = new ec2.CfnSecurityGroup(this, 'InstanceSG', {
      vpcId: vpc.ref,
      groupDescription: 'Allow SSH and HTTP access',
      tags: [{ key: 'Name', value: 'InstanceSG' }],
    });

    // Reglas como recursos separados
    new ec2.CfnSecurityGroupIngress(this, 'SGRuleSSH', {
      groupId: securityGroup.ref,
      ipProtocol: 'tcp',
      fromPort: 22,
      toPort: 22,
      cidrIp: '0.0.0.0/0',
    });

    new ec2.CfnSecurityGroupIngress(this, 'SGRuleHTTP', {
      groupId: securityGroup.ref,
      ipProtocol: 'tcp',
      fromPort: 80,
      toPort: 80,
      cidrIp: '0.0.0.0/0',
    });

    // Instancia EC2
    new ec2.CfnInstance(this, 'Instance', {
      instanceType: 't2.micro',
      imageId: 'ami-0e449927258d45bc4',
      subnetId: subnet.ref,
      securityGroupIds: [securityGroup.ref],
      userData: cdk.Fn.base64(`#!/bin/bash
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf install -y mariadb105-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<?php phpinfo(); ?>" > /var/www/html/index.php
`),
      tags: [{ key: 'Name', value: 'MyInstance' }],
    });
  }
}
