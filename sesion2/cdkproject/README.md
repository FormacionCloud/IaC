<picture>
  <source srcset="https://i.imgur.com/B24wVrC.png" media="(prefers-color-scheme: dark)">
  <img src="https://i.imgur.com/B24wVrC.png" alt="CDK Logo" width="200"/>
</picture>
# Despliegue de infraestructura con AWS CDK en entorno Cloud9 (sin IAM ni bootstrap)

## 📦 Recursos generados

Este despliegue crea los siguientes recursos en AWS:

- **VPC personalizada** con CIDR `10.0.0.0/16`
- **Subred pública** en `us-east-1a` con CIDR `10.0.0.0/24`
- **Internet Gateway** con ruta por defecto `0.0.0.0/0`
- **Route Table** asociada a la subred
- **Security Group** que permite:
  - Entrada en puerto **22 (SSH)** desde `0.0.0.0/0`
  - Entrada en puerto **80 (HTTP)** desde `0.0.0.0/0`
- **Instancia EC2 t2.micro** con:
  - AMI de **Amazon Linux 2023**
  - IP pública
  - **User Data** que instala una pila LAMP
  - Archivo `/var/www/html/index.php` con `phpinfo()`

---

# Despliegue de infraestructura con AWS CDK en entorno Cloud9 (sin IAM ni bootstrap)

Este documento describe paso a paso cómo desplegar una infraestructura con AWS CDK desde un entorno Cloud9 con permisos limitados, como los entornos de AWS Academy o similares. 

---

## ✅ 1. Preparación del entorno Cloud9

### 1.1 Actualizar e instalar herramientas necesarias

```bash
sudo yum update -y
sudo yum install -y git
```

### 1.2 Instalar AWS CDK

Es necesario usar `--force` porque Cloud9 ya tiene instaladas versiones previas de CDK:

```bash
sudo npm install -g aws-cdk --force
```

### 1.3 Inicializar proyecto CDK

```bash
mkdir cdkproject && cd cdkproject
cdk init app --language=typescript
```

### 1.4 Instalar dependencias de CDK

```bash
npm install aws-cdk-lib constructs
```

---

## 🚫 2. Limitaciones en entornos como AWS Academy

Los entornos limitados no permiten operaciones sobre IAM. Esto impide:
- Ejecutar `cdk bootstrap`
- Usar recursos que necesiten "lookups" automáticos (por ejemplo: `Vpc.fromLookup`, `AvailabilityZone`, etc.)

### ❌ ¿Qué es `cdk bootstrap`?
CDK bootstrap crea una pila especial (`CDKToolkit`) con roles IAM, buckets y permisos usados para deploys modernos ("modern synthesis").

### ❌ ¿Qué es un lookup?
Es una operación donde CDK consulta en AWS información en tiempo de compilación (por ejemplo: AZs, VPCs existentes). Requiere IAM y acceso a SSM.

### ✅ Soluciones aplicadas

#### A) Evitamos el bootstrap:
Editamos `cdk.json` para forzar modo "legacy" (que no necesita bootstrap):

```json
{
  "app": "npx ts-node --prefer-ts-exts bin/cdkproject.ts",
  "context": {
    "@aws-cdk/core:newStyleStackSynthesis": false
  }
}
```

#### B) Evitamos lookups:
Creamos los recursos manualmente usando `CfnXxx` en lugar de clases de alto nivel (`Vpc`, `Subnet`, etc.), evitando accesos implícitos.

---

## ⚡ 3. Configuración de credenciales AWS en Cloud9

Cloud9 usa un perfil por defecto con credenciales que genera el propio servicio.
Puedes verificar que está activo con:

```bash
aws sts get-caller-identity
```

No es necesario configurar `~/.aws/credentials` manualmente.

---

## 📆 4. Despliegue de infraestructura

### 4.1 Compilar el proyecto

```bash
npm run build
```

### 4.2 Desplegar

Antes de desplegar, asegúrate de que el archivo `cdk.json` ha sido modificado correctamente para evitar el uso de `cdk bootstrap`. Este cambio es esencial para que el despliegue funcione sin necesidad de permisos IAM.

**Cambios necesarios en `cdk.json`:**

```json
{
  "app": "npx ts-node --prefer-ts-exts bin/cdkproject.ts",
  "context": {
    "@aws-cdk/core:newStyleStackSynthesis": false
  }
}
```

Este cambio fuerza a CDK a usar el modo clásico de síntesis, lo cual elimina la dependencia de recursos creados por `cdk bootstrap` (como roles IAM o parámetros en SSM).

Una vez realizado este cambio, puedes desplegar con:

```bash
cdk deploy
```

(No es necesario `--bootstrapless` gracias al cambio en `cdk.json`)

### 4.3 Verificación

1. Entra en la [consola de EC2](https://console.aws.amazon.com/ec2/)
2. Copia la IP pública de la instancia creada
3. Accede en el navegador a `http://IP_PUBLICA`
4. Deberías ver la página con `phpinfo()`

### 4.4 Comprobación desde CloudFormation

- Ve a [CloudFormation](https://console.aws.amazon.com/cloudformation/)
- Busca el stack `CdkprojectStack`
- Explora los recursos creados y eventos

---

## 🛡️ 5. Simulación de drift (desviación de configuración)

### 5.1 Simular un cambio manual

- Ve a EC2 > Security Groups
- Edita el grupo de la instancia
- Añade una regla inbound: `All traffic`, origen `0.0.0.0/0`

Esto genera un **drift**, porque el estado real ya no coincide con lo que CDK desplegó.

### 5.2 Detección de drift

**No es automática.** Debes detectarlo manualmente:

Desde la consola:
- Ir a CloudFormation
- Seleccionar el stack
- `Actions > Detect drift`

Desde CLI:
```bash
aws cloudformation detect-stack-drift --stack-name CdkprojectStack
```

Y para consultar resultados:
```bash
aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id <id>
```

### 5.3 Corregir drift

Corre simplemente:
```bash
cdk deploy
```

CDK volverá a dejar el estado real como el declarado en código.

---

## ❌ 6. Eliminación de la infraestructura

```bash
cdk destroy
```

Confirmar con `y` cuando lo solicite.

---

## 📁 Estructura típica del proyecto

```
cdkproject/
├── bin/
│   └── cdkproject.ts
├── lib/
│   └── cdkproject-stack.ts  ← código de infraestructura
├── package.json
├── cdk.json
├── tsconfig.json
```

---

Este README está pensado para entornos formativos como AWS Academy, donde no se permite IAM, y está probado paso a paso en CDK 2.x.
