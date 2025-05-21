<img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg" height="100">

# Terraform

## En este espacio os ofrecemos los recursos que hemos elaborado para Terraform:

### [Presentación con los conocimientos básicos sobre Terraform](https://formacioncloud.github.io/borradores_trabajo/03_inicial_gil) y que abarca:
  ⚪ Instalación y configuración básica de Terraform
  ⚪ Estructura básica de un proyecto<br>
  ⚪ Lenguaje HCL<br>
  ⚪ Terraform CLI<br>
  ⚪ Variables (Local Values, Input Variables), Outputs<br>
  ⚪ Providers, Resources, DataSources<br>
  ⚪ Mapeo y gráfico de dependencias y grafico<br>
  ⚪ Gestión del estado<br>
  ⚪ Workspaces<br>
  ⚪ Aspectos avanzados (I): Modules, Expressions, Functions<br>
  ⚪ Aspectos avanzados (II): Provisioners<br>

### Práctica **[Terraform en AWS – Infraestructura para aplicación web](./practica-terraform-aws/Readme.md)**
  En esta práctica construiremos desde cero una infraestructura en AWS usando Terraform. 
  
  **Desplegaremos una aplicación web (WordPress) de alta disponibilidad**: 
    -Infraestructura de red y Nat Gateway 
    -Cortafuegos
    -Servidores web EC2 en múltiples AZs
    -Un balanceador de carga sobre Target Group
    -Un Autoscaling group asociado 
    -Base de datos gestionada (Amazon RDS) 
    -Sistema de archivos compartido (Amazon EFS) que contendrá tanto código como assets. 

![Arquitectura final](./practica-terraform-aws/imagenes/infraestructura_final.jpg)
  
  A lo largo del proceso, **reforzaremos conceptos claves de Terraform** (proveedores, recursos, variables, estado, etc.) y de AWS (VPC, subredes, grupos de seguridad, roles IAM, autoescalado, balanceador de carga, EC2, RDS, user-data, etc.), y tareas extra para resolver.

### Práctica **Terraform en Azure – Infraestructura para aplicación web**
  Misma infraestructura traducida a Azure, la cual analizaremos en relación a la anterior.
  
