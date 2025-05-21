terraform {
 required_version = ">= 1.3.0"
required_providers {
aws = {
      source  = "hashicorp/aws"
      version = ">= 4.44.0"}
}
}
provider "aws" {
region = var.aws_region
# No especificamos credenciales explícitamente: Terraform usará las credenciales
# del entorno (rol LabRole) para autenticarse en AWS.
}
