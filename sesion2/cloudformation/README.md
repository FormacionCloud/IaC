<picture>
  <source srcset="https://cloud-icons.onemodel.app/aws/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-CloudFormation_64.svg" media="(prefers-color-scheme: dark)">
  <img src="https://cloud-icons.onemodel.app/aws/Architecture-Service-Icons_01312023/Arch_Management-Governance/64/Arch_AWS-CloudFormation_64.svg" alt="Cloudformation Logo" width="100"/>
</picture>

# Stack de infraestructura LAMP con CloudFormation

Este repositorio contiene una plantilla YAML de CloudFormation diseñada para desplegar una infraestructura básica en AWS. La plantilla fue generada con **AWS Console-to-Code** y ligeramente corregida para adaptarse a una implementación sencilla y funcional.

## Objetivo

Con esta plantilla se desplegará:

- Una **VPC** con CIDR `10.0.0.0/16`.
- Una **subred pública**.
- Una instancia EC2 `t3.micro` con un **stack LAMP** (Linux, Apache, MySQL, PHP).
- Un **grupo de seguridad** que abre los puertos **80 (HTTP)** y **22 (SSH)**.

## Entorno Cloud9

Este ejercicio se ejecutará desde un entorno **Cloud9** provisto por **AWS Academy**, el cual ya incluye:

- AWS CLI preinstalada.
- Credenciales temporales precargadas.

Puedes verificar las credenciales activas con el siguiente comando:

```bash
aws sts get-caller-identity
```

## Despliegue de la plantilla

### Opción 1: Desde la consola web

1. Accede a CloudFormation en la consola.
2. Haz clic en **“Create stack” → “With new resources (standard)”**.
3. Selecciona **“Upload a template file”**, elige el archivo `ejemplo_inicial.yml` y haz clic en **Next**.
4. Asigna un nombre al stack (por ejemplo: `LAMPStack`).
5. Acepta los valores por defecto, excepto para User Data, que tienes el valor del script en el fichero "userdata-base64.txt" y haz clic en **Next** → **Next** → **Create stack**.

Nota: puedes "descubrir" el contenido del script de user-data usando algún servicio online de decodificación como https://www.base64decode.org/ 

### Opción 2: Desde la CLI

En Cloud9, sitúate en la carpeta donde está la plantilla y ejecuta:

```bash
aws cloudformation create-stack \
  --stack-name LAMPStack \
  --template-body file://ejemplo_inicial.yml \
  --parameters ParameterKey=UserData,ParameterValue="$(< userdata-base64.txt)"

```

## Seguimiento del despliegue

Una vez lanzado el stack, puedes seguir su progreso:

- En la consola de CloudFormation → selecciona el stack → pestaña **"Events"** para ver el timeline.
- También puedes acceder al **diagrama gráfico** de los recursos creados desde la pestaña **"Stack Info" → "View in Designer"**.

## Añadir una regla de grupo de seguridad para permitir todo el tráfico para generar drift

### Opción 1: Desde la consola web

1. Ve a EC2 → **Security Groups**.
2. Busca el grupo de seguridad creado por el stack (`LAMP-GS`).
3. Ve a la pestaña **Inbound rules** → **Edit inbound rules**.
4. Agrega una nueva regla:
   - **Type:** All traffic
   - **Protocol:** All
   - **Port range:** All
   - **Source:** `0.0.0.0/0`

### Opción 2: Desde la CLI

Reemplaza `sg-xxxxxxxx` por el ID real del grupo de seguridad:

```bash
aws ec2 authorize-security-group-ingress   --group-id sg-xxxxxxxx   --protocol -1   --cidr 0.0.0.0/0
```

## Detección de drift

### Desde la consola:

1. Entra a la consola de CloudFormation.
2. Selecciona el stack.
3. Haz clic en **“Actions” → “Detect drift”**.
4. Tras unos segundos, aparecerá el estado de drift en los recursos individuales.

### Desde la CLI:

```bash
aws cloudformation detect-stack-drift --stack-name LAMPStack
```

Luego con el id de la detección puedes ver los resultados con:

```bash
aws cloudformation describe-stack-drift-detection-status   --stack-drift-detection-id xxxxxxxx
```

## Limitación importante

A diferencia de herramientas como **Terraform** o **AWS CDK**, **CloudFormation no reconcilia automáticamente el estado del recurso con la plantilla**. Si se detecta drift:

- CloudFormation lo indica en su detección.
- Pero **no revierte los cambios manuales** a menos que se haga una actualización o recreación explícita, eliminando y volviendo a crear.
- Habitualmente se suele derivar esto a un entorno de trabajo en el que AWS Config detecta cambios 'non-compliance' predefinidos que desencadenan acciones medidas.

## Eliminación del stack

### Desde la consola:

1. Ve a la consola de CloudFormation.
2. Selecciona el stack `LAMPStack`.
3. Haz clic en **“Delete”** → **“Delete stack”**.

### Desde la CLI:

```bash
aws cloudformation delete-stack --stack-name LAMPStack
```

Puedes confirmar el progreso con:

```bash
aws cloudformation describe-stacks --stack-name LAMPStack
```

