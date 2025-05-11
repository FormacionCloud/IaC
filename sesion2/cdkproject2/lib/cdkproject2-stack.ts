import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import {Role} from 'aws-cdk-lib/aws-iam';

export class Cdkproject2Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    
    // Quitar restricción de grupo de seguridad por defecto (crea un rol)
    this.node.setContext('@aws-cdk/aws-ec2:restrictDefaultSecurityGroup', false);

    // VPC con subred pública
    const vpc = new ec2.Vpc(this, 'VPC', {
      natGateways: 0,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'ServerPublic',
          subnetType: ec2.SubnetType.PUBLIC,
          mapPublicIpOnLaunch: true,
        },
      ],
      maxAzs: 2,
    });

    // Grupo de seguridad
    const instanceSecurityGroup = new ec2.SecurityGroup(this, 'SecurityGroup', {
      vpc: vpc,
      description: 'Security Group puertos 22 y 80',
      allowAllOutbound: true,
    });

    // Reglas del grupo de seguridad: puertos 22 y 80
    instanceSecurityGroup.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(22));
    instanceSecurityGroup.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(80));
    
    const userData = ec2.UserData.forLinux();
    
    // Script de inicio
    userData.addCommands(
      'sudo dnf update -y',
      'sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel',
      'sudo dnf install -y mariadb105-server',
      'sudo systemctl start mariadb',
      'sudo systemctl enable mariadb',
      'sudo systemctl start httpd',
      'sudo systemctl enable httpd',
      'echo "<?php phpinfo(); ?>" > /var/www/html/index.php'
    );
    
    // Obtener LabRole
    const labRole = Role.fromRoleArn(this, 'role', `arn:aws:iam::${this.account}:role/LabRole`)
        
    // Instancia EC2
    const instance = new ec2.Instance(this, 'Instance', {
      role: labRole,
      vpc: vpc,
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T3, ec2.InstanceSize.MICRO),
      machineImage: ec2.MachineImage.latestAmazonLinux2023({
        cachedInContext: false,
        cpuType: ec2.AmazonLinuxCpuType.X86_64,
      }),
      userData: userData,
      securityGroup: instanceSecurityGroup
    });
  }
}
