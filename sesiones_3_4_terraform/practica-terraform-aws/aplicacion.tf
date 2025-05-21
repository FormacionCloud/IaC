
# Sistema de archivos EFS
resource "aws_efs_file_system" "wordpress_fs" {
provisioned_throughput_in_mibps = 0
throughput_mode = "bursting"
encrypted = false
tags = {
Name = "${var.project_name}-efs"
}
}

# Crear un Mount Target de EFS en cada subred privada
resource "aws_efs_mount_target" "efs_mount" {
count = length(var.private_subnets_cidrs)
file_system_id = aws_efs_file_system.wordpress_fs.id
subnet_id = aws_subnet.private[count.index].id
security_groups = [aws_security_group.efs_sg.id]
}


# Subnet Group para RDS (usar subredes privadas)
resource "aws_db_subnet_group" "rds_subnets" {
name = "${var.project_name}-rds-subnetgrp"
subnet_ids = aws_subnet.private[*].id
tags = {
Name = "${var.project_name}-rds-subnetgrp"
}
}

resource "aws_db_instance" "wordpress_db" {
  identifier             = "${var.project_name}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "${var.project_name}-db"
  }
}

# Load Balancer (Application LB) público
resource "aws_lb" "app_lb" {
name = "${var.project_name}-alb"
load_balancer_type = "application"
subnets = aws_subnet.public[*].id # colocar en subredes públicas (una IP en cada AZ pública)
security_groups = [aws_security_group.alb_sg.id]
idle_timeout = 60
enable_deletion_protection = false
tags = {
Name = "${var.project_name}-alb"
}
}

# Target Group para los servidores web
resource "aws_lb_target_group" "web_tg" {
name = "${var.project_name}-tg"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.main_vpc.id
target_type = "instance"
health_check {
path = "/"
protocol = "HTTP"
interval = 30
timeout = 5
healthy_threshold = 3
unhealthy_threshold = 3
}
tags = {
Name = "${var.project_name}-tg"
}
}

# Listener HTTP en el ALB (puerto 80 -> target group)
resource "aws_lb_listener" "alb_listener_http" {
load_balancer_arn = aws_lb.app_lb.arn
port = 80
protocol = "HTTP"
default_action {
type = "forward"
target_group_arn = aws_lb_target_group.web_tg.arn
}
}



# Obtener la última AMI de Amazon Linux 2023 desde el Parameter Store de AWS
data "aws_ssm_parameter" "amzn2" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}



# Launch Template para instancias web
resource "aws_launch_template" "web_lt" {
name_prefix = "${var.project_name}-lt-"
image_id = data.aws_ssm_parameter.amzn2.value
instance_type = var.instance_type
key_name = var.key_name != "" ? var.key_name : null
# Solo asignamos key pair si se proporcionó; si var.key_name es "", ponemos null (ninguna key)
vpc_security_group_ids = [aws_security_group.web_sg.id]
iam_instance_profile {
  name = "LabInstanceProfile"
}
user_data = base64encode(templatefile("${path.module}/userdata/staging-web.sh", {
  efs_id        = aws_efs_file_system.wordpress_fs.id
  region        = var.aws_region
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = var.db_password
  db_host       = aws_db_instance.wordpress_db.address
  DOMAIN_NAME   = var.DOMAIN_NAME
  DEMO_USERNAME = var.DEMO_USERNAME
  DEMO_PASSWORD = var.DEMO_PASSWORD
  DEMO_EMAIL    = var.DEMO_EMAIL
}))
tag_specifications {
resource_type = "instance"
tags = {
Name = "${var.project_name}-web"
}
}
}



# Auto Scaling Group para las instancias web
resource "aws_autoscaling_group" "web_asg" {
name_prefix = "${var.project_name}-asg-"
launch_template {
id = aws_launch_template.web_lt.id
version = "$Latest"
}
vpc_zone_identifier = aws_subnet.private[*].id
target_group_arns = [aws_lb_target_group.web_tg.arn]
desired_capacity = 1

min_size = 1
max_size = 2
health_check_type = "EC2"
health_check_grace_period = 90
tag {
key = "Name"
value = "${var.project_name}-web"
propagate_at_launch = true
}
}
