# Despliegue en Azure con Terraform desde entorno Cloud9

Este proyecto permite desplegar una infraestructura equivalente a una LAMP stack en **Microsoft Azure**, utilizando **Terraform** desde un entorno **AWS Cloud9**.

---

## 🛠 Pasos desde Cloud9

### 1. Instalar Azure CLI en Amazon Linux 2023

Amazon Linux 2023 no es compatible con los scripts para Debian/Ubuntu. Utiliza este procedimiento:

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo tee /etc/yum.repos.d/azure-cli.repo > /dev/null <<EOF
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf install -y azure-cli
```

Verifica que esté correctamente instalada:

```bash
az version
```

---

### 2. Autenticarse y obtener datos necesarios

Autentícate con:

```bash
az login
```

Una vez dentro, obtén `subscription_id` y `tenant_id` con:

```bash
az account show --query id -o tsv
az account show --query tenantId -o tsv
```

---

### 3. Configurar variables de entorno

En lugar de hardcodear `subscription_id` y `tenant_id` en `main.tf`, se recomienda exportarlos como variables de entorno:

```bash
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
```

Opcional a futuro: puedes automatizar esto creando un script por ejemplo `set-azure-env.sh` con un contenido así:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
```

---

### 4. Clonar el repositorio y entrar

```bash
git clone https://github.com/tuusuario/tu-repo-azure.git
cd tu-repo-azure
```

---

### 5. Variables y seguridad

La contraseña de la máquina virtual se define como **variable sensible** (`admin_password`). Terraform te la pedirá si no está definida.

Recomendamos exportarla también como variable de entorno:

```bash
export TF_VAR_admin_password="TuPasswordSegura123!"
```

Esto evita tener que escribirla en cada `terraform apply`.

---

### 6. Inicializar y desplegar infraestructura

```bash
terraform init
terraform plan
terraform apply
```

Confirma con `yes`.

---

### 7. Recursos creados

- Resource Group
- Virtual Network (10.0.0.0/16)
- Subred pública (10.0.1.0/24)
- Public IP (Standard SKU con método `Static`, obligatorio)
- Network Security Group (puertos 22 y 80 abiertos)
- Network Interface
- Asociación NSG → NIC (más cercano al modelo de AWS)
- VM Ubuntu 22.04 LTS
- Apache, PHP, MariaDB y `phpinfo()` desplegado en `/var/www/html/index.php`

---

### 8. Verificar resultado

Desde el portal de Azure:
- Ve al recurso VM → copia la IP pública
- Accede a:

```
http://<IP>
```

Deberías ver el `phpinfo()`.

---

### 9. Simular un drift

En el portal de Azure:
1. Ve al NSG asociado a la NIC.
2. Agrega una regla de entrada que permita **todo el tráfico** (`*` a `*`).

---

### 10. Detectar drift

Terraform no detecta drift automáticamente. Para verlo:

```bash
terraform plan
```

Terraform mostrará cambios como nuevas reglas en el NSG.

---

### 11. Opcional: Verificar sin tocar estado

```bash
terraform plan -refresh=false
```

⚠️ Desde Terraform 1.6, `plan` y `apply` ya hacen `refresh` automático por defecto.

---

### 12. Corregir drift

Para revertir los cambios hechos fuera de Terraform:

```bash
terraform apply
```

---

### 13. Verificar que se ha corregido

Desde el portal de Azure:
- Entra en el NSG de la NIC.
- Verifica que la regla extra ha sido eliminada.

---

### 14. Destruir recursos

```bash
terraform destroy
```

---

## 📦 Estructura del proyecto modular incluido en el ZIP

Se ha colgado también en un archivo zip un ejemplo de cómo se podría escribir este proyecto organizado en estructura moderna, en lugar de estar todo en un main.tf:

- **main.tf**: Entrypoint (estructurado para futuras mejoras).
- **versions.tf**: Restricción de versiones de Terraform y providers.
- **networking.tf**: Definición de red (VNet, Subnet, NSG, NIC).
- **vm.tf**: Definición de la máquina virtual Ubuntu Server 22.04 LTS.
- **variables.tf**: Variables de entrada sensibles (como contraseña).
- **outputs.tf**: Muestra la IP pública de la VM tras desplegar.

