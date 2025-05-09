<img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg" width=200/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" width=100/>

# Despliegue en AWS mediante Terraform desde entorno Cloud9

Este proyecto contiene la definición de infraestructura para desplegar una **LAMP stack en AWS** usando **Terraform**, ejecutado desde un entorno **Cloud9 basado en Amazon Linux 2023**.

---

## 🛠 Pasos desde Cloud9

### 1. Instalar Terraform

Amazon Linux 2023 **no trae Terraform preinstalado**. Instálalo así:

```bash
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf install -y terraform
```

Verifica que se ha instalado correctamente:

```bash
terraform -v
```

---

### 2. Preparar entorno Cloud9

Terraform en Cloud9 utiliza automáticamente las credenciales del entorno, gracias al rol IAM adjunto a la instancia.

Comprueba que puedes ejecutar comandos sin error:

```bash
aws sts get-caller-identity
```

Esto debe devolver tu cuenta, usuario o rol actual.  
No necesitas configurar manualmente `aws configure` ni exportar variables de entorno. 
En otros entornos podría coger las credencias haciendo exports:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."  # (solo si usas credenciales temporales)
```

---

### 3. Clonar el repositorio y acceder

```bash
git clone https://github.com/tuusuario/tu-repo.git
cd tu-repo
```

---

### 4. Inicializar Terraform

```bash
terraform init
```

Esto descargará los plugins necesarios.

---

### 5. Planificar y aplicar la infraestructura

```bash
terraform plan
terraform apply
```

Confirma con `yes`.

Esto creará los siguientes recursos:

- VPC (`10.0.0.0/16`) en `us-east-1`
- Subred pública (`10.0.1.0/24`) en `us-east-1a`
- Internet Gateway + tabla de rutas
- Grupo de seguridad con puertos 22 y 80 abiertos
- Instancia EC2 `t3.micro` (Amazon Linux 2023) con IP pública
- Apache, PHP y MariaDB instalados mediante `user_data`
- Archivo `phpinfo()` en `/var/www/html/index.php`

Una vez desplegado, ve a la consola de AWS → EC2 → copia la **IP pública** de la instancia y accede por navegador a:

```
http://<IP>
```

Deberías ver la pantalla de información de PHP.

---

### 6. Simular un drift (cambio fuera de Terraform)

1. Ve a la consola de AWS → EC2 → Grupos de seguridad.
2. Edita el grupo de seguridad creado por Terraform.
3. Añade una nueva **regla de entrada** que permita **todo el tráfico (0.0.0.0/0)**.

---

### 7. Detectar y corregir el drift

Para detectar cambios hechos fuera de Terraform:

```bash
terraform plan
```

Verás que Terraform detecta la nueva regla y propone eliminarla.

Para corregirlo:

```bash
terraform apply
```

Esto restaurará el grupo de seguridad al estado definido en el código.

➡️ Luego, vuelve a la **consola de AWS → EC2 → Grupos de seguridad** y verifica que la regla extra ya no está.

---

### 8. (Opcional) Refrescar el estado sin aplicar cambios

```bash
terraform refresh
```

Esto actualizará el `.tfstate` con el estado actual de AWS, sin modificar la infraestructura.

---

### 9. (Opcional) Destruir todo

```bash
terraform destroy
```

Confirma con `yes` para eliminar todos los recursos creados.
