#############################
# codigo clasico de terraform
# 4vpc 2 regiones
#############################

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

##########################
# VPC 1 - MyVPCa (us-east-1a)
##########################

resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPCa"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyVPCa-subnet"
  }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "MyVPCa-igw"
  }
}

resource "aws_route_table" "rt_a" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "MyVPCa-rt"
  }
}

resource "aws_route" "route_a" {
  route_table_id         = aws_route_table.rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_a.id
}

resource "aws_route_table_association" "rta_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt_a.id
}

resource "aws_security_group" "sg_a" {
  name        = "MyVPCa-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVPCa-sg"
  }
}

resource "aws_instance" "instance_a" {
  ami                         = "ami-0e449927258d45bc4"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.sg_a.id]
  associate_public_ip_address = true

  user_data = <<-EOF
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
  EOF

  tags = {
    Name = "MyVPCa-instance"
  }
}

##########################
# VPC 2 - MyVPCb (us-east-1b)
##########################

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "MyVPCb"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyVPCb-subnet"
  }
}

resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.vpc_b.id

  tags = {
    Name = "MyVPCb-igw"
  }
}

resource "aws_route_table" "rt_b" {
  vpc_id = aws_vpc.vpc_b.id

  tags = {
    Name = "MyVPCb-rt"
  }
}

resource "aws_route" "route_b" {
  route_table_id         = aws_route_table.rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_b.id
}

resource "aws_route_table_association" "rta_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt_b.id
}

resource "aws_security_group" "sg_b" {
  name        = "MyVPCb-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVPCb-sg"
  }
}

resource "aws_instance" "instance_b" {
  ami                         = "ami-0e449927258d45bc4"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet_b.id
  vpc_security_group_ids      = [aws_security_group.sg_b.id]
  associate_public_ip_address = true

  user_data = <<-EOF
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
  EOF

  tags = {
    Name = "MyVPCb-instance"
  }
}

##########################
# VPC 3 - MyVPCc (us-west-2a)
##########################

resource "aws_vpc" "vpc_c" {
  provider   = aws.west
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "MyVPCc"
  }
}

resource "aws_subnet" "subnet_c" {
  provider                = aws.west
  vpc_id                  = aws_vpc.vpc_c.id
  cidr_block              = "10.2.0.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyVPCc-subnet"
  }
}

resource "aws_internet_gateway" "igw_c" {
  provider = aws.west
  vpc_id   = aws_vpc.vpc_c.id

  tags = {
    Name = "MyVPCc-igw"
  }
}

resource "aws_route_table" "rt_c" {
  provider = aws.west
  vpc_id   = aws_vpc.vpc_c.id

  tags = {
    Name = "MyVPCc-rt"
  }
}

resource "aws_route" "route_c" {
  provider              = aws.west
  route_table_id        = aws_route_table.rt_c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_c.id
}

resource "aws_route_table_association" "rta_c" {
  provider      = aws.west
  subnet_id     = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.rt_c.id
}

resource "aws_security_group" "sg_c" {
  provider     = aws.west
  name         = "MyVPCc-sg"
  description  = "Allow SSH and HTTP"
  vpc_id       = aws_vpc.vpc_c.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVPCc-sg"
  }
}

resource "aws_instance" "instance_c" {
  provider                     = aws.west
  ami                          = "ami-0e449927258d45bc4"
  instance_type                = "t3.micro"
  subnet_id                    = aws_subnet.subnet_c.id
  vpc_security_group_ids       = [aws_security_group.sg_c.id]
  associate_public_ip_address  = true

  user_data = <<-EOF
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
  EOF

  tags = {
    Name = "MyVPCc-instance"
  }
}

##########################
# VPC 4 - MyVPCd (us-west-2b)
##########################

# (Repetimos para MyVPCd, igual que MyVPCc, pero AZ "us-west-2b" y CIDR 10.3.0.0/16) ya da pereza
