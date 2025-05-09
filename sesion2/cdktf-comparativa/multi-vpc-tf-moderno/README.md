# Multi-VPC en AWS en Terraform modular

Este proyecto permite desplegar **cuatro VPCs** distribuidas en dos regiones de AWS utilizando **Terraform modular**. Cada VPC contiene una infraestructura mínima lista para ejecutar una instancia EC2 con una pila LAMP preinstalada.

## 📁 Estructura del proyecto

```
multi-vpc-terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── modules/
    └── vpc-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### 🔹 `main.tf`

Invoca el módulo `vpc-instance` para cada VPC definida en `terraform.tfvars`, utilizando `for_each` para crear múltiples instancias del módulo con distinta configuración (nombre, CIDR, AZ, región).

### 🔹 `providers.tf`

Define dos proveedores de AWS:

- `aws`: para la región `us-east-1`
- `aws.west`: para la región `us-west-2`

Esto permite desplegar recursos en múltiples regiones.

### 🔹 `variables.tf`

Declara la variable `vpcs`, que es una lista de objetos con los parámetros necesarios para cada despliegue: nombre, CIDR, región y zona de disponibilidad.

### 🔹 `terraform.tfvars`

Define los valores concretos para la variable `vpcs`, es decir, las cuatro VPCs a desplegar.

### 🔹 `outputs.tf`

Expone como salida la IP pública de cada instancia EC2 creada, identificada por el nombre de la VPC.

---

## 📦 Módulo: `modules/vpc-instance/`

Este módulo encapsula la lógica para crear todos los recursos asociados a una única VPC.

### Contenido:

- **`variables.tf`**: recibe `name`, `cidr`, `region`, `az` como parámetros de entrada.
- **`main.tf`**:
  - VPC
  - Subred pública con IP pública automática
  - Internet Gateway (IGW)
  - Tabla de rutas + asociación
  - Grupo de seguridad (puertos 22 y 80 abiertos)
  - Instancia EC2 tipo `t3.micro` con Amazon Linux 2023 y LAMP stack
- **`outputs.tf`**: expone la IP pública de la instancia EC2.

---

## ✅ Funcionalidad

Cada ejecución del módulo genera:

- Una VPC en la región y AZ especificadas.
- Una subred pública (`/24`) dentro de esa VPC.
- Un Internet Gateway asociado y correctamente enrutable.
- Un grupo de seguridad abierto a todo tráfico en puertos 22 y 80.
- Una instancia EC2 Amazon Linux 2023 (`t3.micro`) con un script de `user_data` que instala una pila LAMP.
