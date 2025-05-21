
# SG para el Load Balancer - permite tráfico web desde internet
resource "aws_security_group" "alb_sg" {
name = "${var.project_name}-alb-sg"
description = "Permitir HTTP desde Internet al ALB"
vpc_id = aws_vpc.main_vpc.id

# Regla de entrada: HTTP (80)  desde cualquier origen
ingress {
  description = "HTTP desde Internet"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


# Salida: permitir todo (regla default implícita de SG)
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
description = "Allow all outbound"
}

tags = {
Name = "${var.project_name}-alb-sg"
}
}

# SG para las instancias EC2 (servidores web)
resource "aws_security_group" "web_sg" {
name = "${var.project_name}-web-sg"
description = "Permitir acceso al servidor web desde ALB"
vpc_id = aws_vpc.main_vpc.id

ingress {
description = "HTTP desde el ALB"
from_port = 80
to_port = 80
protocol = "tcp"
security_groups = [aws_security_group.alb_sg.id] # permitido desde SG del ALB
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
description = "Allow all outbound"
}

tags = {
Name = "${var.project_name}-web-sg"
}
}

# SG para la base de datos (RDS)
resource "aws_security_group" "db_sg" {
name = "${var.project_name}-db-sg"
description = "Permitir acceso MySQL desde servidores web"
vpc_id = aws_vpc.main_vpc.id

ingress {
description = "MySQL desde Web SG"
from_port = 3306
to_port = 3306
protocol = "tcp"
security_groups = [aws_security_group.web_sg.id] # solo desde instancias con web_sg
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "${var.project_name}-db-sg"
}
}

# SG para EFS (sistema de archivos)
resource "aws_security_group" "efs_sg" {
name = "${var.project_name}-efs-sg"
description = "Permitir acceso NFS (EFS) desde servidores web"
vpc_id = aws_vpc.main_vpc.id
ingress {
description = "NFS desde Web SG"
from_port = 2049
to_port = 2049
protocol = "tcp"
security_groups = [aws_security_group.web_sg.id]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}


tags = {
Name = "${var.project_name}-efs-sg"
}
}

