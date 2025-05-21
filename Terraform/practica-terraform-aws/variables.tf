# variables.tf
# Región de AWS donde desplegar la infraestructura (por defecto us-east-1)

variable "aws_region" {
description = "Región de AWS donde se desplegarán los recursos"
type = string
default = "us-east-1"
}

# Prefijo para nombres de recursos (por ejemplo, usar tus iniciales oproyecto)
variable "project_name" {
description = "Prefijo identificador para nombres de recursos en AWS"
type = string
default = "tfaws"
}

# VPC CIDR principal
variable "vpc_cidr" {
description = "Bloque CIDR para la VPC"
type = string
default = "10.0.0.0/16"
}

# Subredes públicas (lista de CIDR, una por zona de disponibilidad)
variable "public_subnets_cidrs" {
description = "Lista de bloques CIDR para subredes públicas"
type = list(string)
default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Subredes privadas (para base de datos/servidores privados)
variable "private_subnets_cidrs" {
description = "Lista de bloques CIDR para subredes privadas"
type = list(string)
default = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Nombre de par de claves SSH existente (opcional, si se desea acceso SSH a instancia)
variable "key_name" {
description = "Nombre de la key pair de EC2 para SSH"
type = string
default = "" # dejar vacío si no se usará SSH manual
}

# Tipo de instancia EC2 para los servidores web
variable "instance_type" {
description = "Tipo de instancia EC2 para los servidores web"
type = string
default = "t3.micro"
}

# Parámetros para la base de datos (RDS MySQL)
variable "db_name" {
description = "Nombre de la base de datos de WordPress en RDS"
type = string
default = "wordpress"
}
variable "db_username" {
description = "Usuario administrador de la base de datos RDS"
type = string
default = "admin"
}
variable "db_password" {
description = "Contraseña del usuario de la base de datos RDS"
type = string
default = "PAssw0rd1234" # En entorno real, usar una contraseña segura y no hardcodeada
sensitive = true # Marcar como sensible para no mostrar en salida de Terraform
}

variable "DOMAIN_NAME" {
  type        = string
  description = "Dominio para la instalación de WordPress"
  default     = "wordpress-iac-tf.midemo.com"
}

variable "DEMO_USERNAME" {
  type        = string
  description = "Usuario administrador para WordPress"
  default     = "wpadmin"
}

variable "DEMO_PASSWORD" {
  type        = string
  description = "Contraseña administrador para WordPress"
  default     = "wppassword123"
  sensitive = true # Marcar como sensible para no mostrar en salida de Terraform
}

variable "DEMO_EMAIL" {
  type        = string
  description = "Email administrador para WordPress"
  default     = "admin@midemo.com"
}
