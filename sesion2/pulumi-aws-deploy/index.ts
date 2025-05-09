import * as aws from "@pulumi/aws";

// 1. Crear la VPC
const vpc = new aws.ec2.Vpc("MyVPC", {
    cidrBlock: "10.0.0.0/16",
    tags: { Name: "MyVPC" }
});

// 2. Crear el Internet Gateway
const igw = new aws.ec2.InternetGateway("MyIGW", {
    vpcId: vpc.id,
    tags: { Name: "MyIGW" }
});

// 3. Crear la Subred Pública
const subnet = new aws.ec2.Subnet("MySubnet", {
    vpcId: vpc.id,
    cidrBlock: "10.0.1.0/24",
    availabilityZone: "us-east-1a",
    mapPublicIpOnLaunch: true,
    tags: { Name: "MySubnet" }
});

// 4. Crear la tabla de enrutamiento
const routeTable = new aws.ec2.RouteTable("MyRouteTable", {
    vpcId: vpc.id,
    routes: [{
        cidrBlock: "0.0.0.0/0",
        gatewayId: igw.id,
    }],
    tags: { Name: "MyRouteTable" }
});

// 5. Asociar la subred a la tabla de enrutamiento
const routeTableAssociation = new aws.ec2.RouteTableAssociation("MyRouteTableAssociation", {
    subnetId: subnet.id,
    routeTableId: routeTable.id,
});

// 6. Crear el Security Group
const sg = new aws.ec2.SecurityGroup("MySecurityGroup", {
    vpcId: vpc.id,
    description: "Allow SSH and HTTP",
    ingress: [
        { protocol: "tcp", fromPort: 22, toPort: 22, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] },
    ],
    egress: [
        { protocol: "-1", fromPort: 0, toPort: 0, cidrBlocks: ["0.0.0.0/0"] },
    ],
    tags: { Name: "MySecurityGroup" }
});

// 7. Crear la EC2 Instance
const server = new aws.ec2.Instance("MyInstance", {
    instanceType: "t3.micro",
    ami: "ami-0e449927258d45bc4",
    subnetId: subnet.id,
    vpcSecurityGroupIds: [sg.id],
    associatePublicIpAddress: true,
    userData: `#!/bin/bash
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf install -y mariadb105-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<?php phpinfo(); ?>" > index.php
mv index.php /var/www/html/index.php`,
    tags: { Name: "MyInstance" }
});

// Exportar IP pública
export const publicIp = server.publicIp;
export const publicDns = server.publicDns;
