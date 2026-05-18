import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';

export class CdkprojectStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ── VPC ──────────────────────────────────────────────────────────────────
    const vpc = new ec2.CfnVPC(this, 'MyVpc', {
      cidrBlock: '10.0.0.0/16',
      enableDnsHostnames: true,
      enableDnsSupport: true,
      tags: [{ key: 'Name', value: 'MyVpc' }],
    });

    // ── Internet Gateway ─────────────────────────────────────────────────────
    const igw = new ec2.CfnInternetGateway(this, 'MyIgw', {
      tags: [{ key: 'Name', value: 'MyIgw' }],
    });

    new ec2.CfnVPCGatewayAttachment(this, 'MyIgwAttachment', {
      vpcId: vpc.ref,
      internetGatewayId: igw.ref,
    });

    // ── Subred pública ───────────────────────────────────────────────────────
    const subnet = new ec2.CfnSubnet(this, 'MyPublicSubnet', {
      vpcId: vpc.ref,
      cidrBlock: '10.0.0.0/24',
      availabilityZone: 'us-east-1a',
      mapPublicIpOnLaunch: true,
      tags: [{ key: 'Name', value: 'MyPublicSubnet' }],
    });

    // ── Route Table ──────────────────────────────────────────────────────────
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

    // ── Security Group ───────────────────────────────────────────────────────
    const sg = new ec2.CfnSecurityGroup(this, 'InstanceSG', {
      vpcId: vpc.ref,
      groupDescription: 'Allow SSH and HTTP',
      tags: [{ key: 'Name', value: 'InstanceSG' }],
    });

    new ec2.CfnSecurityGroupIngress(this, 'SGRuleSSH', {
      groupId: sg.ref,
      ipProtocol: 'tcp',
      fromPort: 22,
      toPort: 22,
      cidrIp: '0.0.0.0/0',
    });

    new ec2.CfnSecurityGroupIngress(this, 'SGRuleHTTP', {
      groupId: sg.ref,
      ipProtocol: 'tcp',
      fromPort: 80,
      toPort: 80,
      cidrIp: '0.0.0.0/0',
    });

    // ── Instancia EC2 con pila LAMP ──────────────────────────────────────────
    const instance = new ec2.CfnInstance(this, 'MyInstance', {
      instanceType: 't3.micro',
      imageId: 'ami-0236922087fa98b6e', // Amazon Linux 2023 us-east-1
      subnetId: subnet.ref,
      securityGroupIds: [sg.ref],
      userData: cdk.Fn.base64(
        [
          '#!/bin/bash',
          'dnf update -y',
          'dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel mariadb105-server',
          'systemctl enable --now mariadb',
          'systemctl enable --now httpd',
          'echo "<?php phpinfo(); ?>" > /var/www/html/index.php',
        ].join('\n')
      ),
      tags: [{ key: 'Name', value: 'MyInstance' }],
    });

    // ── Output: IP pública ───────────────────────────────────────────────────
    new cdk.CfnOutput(this, 'PublicIp', {
      value: instance.attrPublicIp,
      description: 'IP pública de la instancia EC2',
    });
  }
}
