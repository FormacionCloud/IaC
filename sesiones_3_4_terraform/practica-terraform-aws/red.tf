resource "aws_vpc" "main_vpc" {
cidr_block = var.vpc_cidr
enable_dns_hostnames = true # habilitar DNS dentro de la VPC (necesariopara resoluciones internas/SSM)
enable_dns_support = true
tags = {
Name = "${var.project_name}-vpc"
}
}

# Gateway de Internet para la VPC (permite salida a Internet)
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main_vpc.id
tags = {
Name = "${var.project_name}-igw"
}
}

# Crear subredes públicas en las dos primeras AZ de la región
resource "aws_subnet" "public" {
count = length(var.public_subnets_cidrs)
vpc_id = aws_vpc.main_vpc.id
cidr_block = var.public_subnets_cidrs[count.index]
map_public_ip_on_launch = true # asignar IP pública automáticamente ainstancias en esta subred
availability_zone = "${var.aws_region}${tolist(["a","b"])[count.index]}"
tags = {
Name = "${var.project_name}-public-${count.index + 1}"
}
}

# Crear subredes privadas en las dos primeras AZ de la región
resource "aws_subnet" "private" {
count = length(var.private_subnets_cidrs)
vpc_id = aws_vpc.main_vpc.id
cidr_block = var.private_subnets_cidrs[count.index]
map_public_ip_on_launch = false
availability_zone = "${var.aws_region}${tolist(["a","b"])[count.index]}"
tags = {
Name = "${var.project_name}-private-${count.index + 1}"
}
}

# Tabla de enrutamiento para subredes públicas
resource "aws_route_table" "public_rt" {
vpc_id = aws_vpc.main_vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = {
Name = "${var.project_name}-public-rt"
}
}

# Asociar subredes públicas a la tabla de enrutamiento publica
resource "aws_route_table_association" "public_assoc" {
count = length(var.public_subnets_cidrs)
subnet_id = aws_subnet.public[count.index].id
route_table_id = aws_route_table.public_rt.id
}

# (Opcional) Tabla de enrutamiento privada 
resource "aws_route_table" "private_rt" {
vpc_id = aws_vpc.main_vpc.id
tags = {
Name = "${var.project_name}-private-rt"
}
}

# Asociar subredes privadas a la tabla de enrutamiento privada
resource "aws_route_table_association" "private_assoc" {
count = length(var.private_subnets_cidrs)
subnet_id = aws_subnet.private[count.index].id
route_table_id = aws_route_table.private_rt.id
}

# Elastic IP para el NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway en la primera subred pública
resource "aws_nat_gateway" "nat" {
allocation_id = aws_eip.nat_eip.id
subnet_id = aws_subnet.public[0].id # desplegar NAT en la primera subred pública (AZ "a")
tags = {
Name = "${var.project_name}-natgw"
}
depends_on = [aws_internet_gateway.igw] # necesita IGW operativo
}

# Agregar ruta por defecto en la tabla privada apuntando al NAT (para salidaa internet desde privadas)
resource "aws_route" "private_nat_route" {
route_table_id = aws_route_table.private_rt.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id
}
