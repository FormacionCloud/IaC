![CDK](https://i.imgur.com/B24wVrC.png)
# Despliegue de infraestructura con AWS CDK en entorno Cloud9 (versión con Bootstrap)

Esta plantilla despliega recursos de alto nivel con AWS CDK.

## Recursos generados

Este despliegue crea los siguientes recursos en AWS:

- **VPC personalizada** con CIDR `10.0.0.0/16`
- **2 subredes públicas**
- **Internet Gateway** con ruta por defecto `0.0.0.0/0`
- **Route Table** asociada a la subred
- **Security Group** que permite:
  - Entrada en puerto **22 (SSH)** desde `0.0.0.0/0`
  - Entrada en puerto **80 (HTTP)** desde `0.0.0.0/0`
- **Instancia EC2 t3.micro** con:
  - AMI de **Amazon Linux 2023**
  - IP pública
  - **User Data** que instala una pila LAMP
  - Archivo `/var/www/html/index.php` con `phpinfo()`

---

# Despliegue de infraestructura con AWS CDK en entorno Cloud9 (versión con Bootstrap)
Este documento describe paso a paso cómo desplegar una infraestructura con AWS CDK desde un entorno Cloud9 en laboratorios de AWS Academy.

---

## 1. Clonado e instalación de dependencias
En primer lugar es necesario clonar el repositorio en el entorno de Cloud9.

### 1.1 Actualizar AWS CDK (opcional)
Cloud9 incluye por defecto `git` y la herramienta `cdk`. No obstante, se incluyen las instrucciones para actualizar la herramienta `cdk` y para crear una aplicación nueva, paso no necesario si se realiza el clonado de este repositorio.

Es necesario usar `--force` porque Cloud9 ya tiene instaladas versiones previas de CDK:

```bash
sudo npm install -g aws-cdk --force
```

### 1.2 Inicializar proyecto CDK (no necesario si se clona este repositorio)
Si se desea crear una nueva aplicación CDK es necesario realizar el siguiente paso. En caso de utilizar la aplicación de este repositorio, este paso no es necesario.

```bash
mkdir cdkproject && cd cdkproject
cdk init app --language=typescript
```

### 1.3 Instalar dependencias del proyecto 
En la ruta de la carpeta de este proyecto, es necesario ejecutar el siguiente comando para instalar las dependencias de NodeJS:

```bash
npm install
```

---

## 2. Limitaciones en entornos como AWS Academy
AWS Academy no permite la creación de roles. Por tanto, no es posible realizar el _bootstraping_ del proyecto con los valores por defecto (https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html).

Sin embargo, es posible configurar el bootstraping de manera personalizada para utilizar el rol `LabRole` proporcionado en el laboratorio de AWS Academy. Para ello seguiremos las instrucciones indicadas en este repositorio: https://github.com/wongcyrus/aws-cdk-hack-for-aws-academy-learner-lab

La documentación asociada a este procedimiento se puede consultar en estos dos enlaces:
- https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping-customizing.html
- https://docs.aws.amazon.com/cdk/v2/guide/customize-synth.html#bootstrapping-custom-synth-default

En primer lugar, es necesario modificar la plantilla con la que realizar el bootstraping. Para ello se proporciona el fichero `bootstrap_template.yaml`. Se trata de la plantilla por defecto pero eliminando las líneas que crean los roles y el enlace del rol a la clave KMS (se incluyen en la plantilla proporcionada, pero comentadas). Para realizar el bootstraping con esa plantilla, se debe ejecutar el siguiente comando:

```bash
cdk bootstrap --template bootstrap_template.yaml
```
> [!WARNING]
> IMPORTANTE: si falla el proceso de bootstraping, será necesario eliminar manualmente el bucket de S3 antes de ejecutar ese comando por segunda vez.

En segundo lugar, es necesario modificar el fichero `.ts` de la carpeta `./bin` y añadir un objeto `synthesizer` que haga referencia a los roles necesarios sustituyéndolos por `LabRole`. A continuación se muestra un ejemplo de cómo crear dicho objeto:
```ts

import { DefaultStackSynthesizer } from 'aws-cdk-lib';

const defaultStackSynthesizer = new DefaultStackSynthesizer({
  // Name of the S3 bucket for file assets
  fileAssetsBucketName:
    "cdk-${Qualifier}-assets-${AWS::AccountId}-${AWS::Region}",
  bucketPrefix: "",

  // Name of the ECR repository for Docker image assets
  imageAssetsRepositoryName:
    "cdk-${Qualifier}-container-assets-${AWS::AccountId}-${AWS::Region}",

  // ARN of the role assumed by the CLI and Pipeline to deploy here
  deployRoleArn: "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/LabRole",
  deployRoleExternalId: "",

  // ARN of the role used for file asset publishing (assumed from the deploy role)
  fileAssetPublishingRoleArn:
    "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/LabRole",
  fileAssetPublishingExternalId: "",

  // ARN of the role used for Docker asset publishing (assumed from the deploy role)
  imageAssetPublishingRoleArn:
    "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/LabRole",
  imageAssetPublishingExternalId: "",

  // ARN of the role passed to CloudFormation to execute the deployments
  cloudFormationExecutionRole:
    "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/LabRole",

  // ARN of the role used to look up context information in an environment
  lookupRoleArn: "arn:${AWS::Partition}:iam::${AWS::AccountId}:role/LabRole",
  lookupRoleExternalId: "",

  // Name of the SSM parameter which describes the bootstrap stack version number
  bootstrapStackVersionSsmParameter: "/cdk-bootstrap/${Qualifier}/version",

  // Add a rule to every template which verifies the required bootstrap stack version
  generateBootstrapVersionRule: true,
});

```

Por último, es necesario añadir dicho objeto a la creación de la app. Por ejemplo:
```bash
const app = new cdk.App();
new Cdk3Stack(app, 'Cdk3Stack', {
  // Añadir objecto creado como parámetro del stack
  synthesizer: defaultStackSynthesizer
});

```

El código de la aplicación de este repositorio ya incluye dichos cambios, por lo que no es necesario añadirlos.

##  3. Configuración de credenciales AWS en Cloud9
Cloud9 ya incluye unas credenciales que proporcionan acceso a los recursos de la cuenta AWS, por lo que no es necesario configurar `~/.aws/credentials` manualmente.

---

##  4. Despliegue de infraestructura

### 4.1 Compilar el proyecto

```bash
npm run build
```

### 4.2 Desplegar
Para desplegar la aplicación, ejecuta:

```bash
cdk deploy
```

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

##  5. Simulación de drift (desviación de configuración)

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
aws cloudformation detect-stack-drift --stack-name Cdkproject2Stack
```

Y para consultar resultados:
```bash
aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id <id>
```

Existe un comando adicional `npx cdk diff`, que se encarga de comprobar las __diferencias entre la plantilla local y la desplegada en CloudFormation__. Es importante dejar claro que esas diferencias __no incluyen los cambios realizados de manera externa a la plantilla__, como el que nos aplica. A todos los efectos, CDK es igual a CloudFormation en este aspecto.

## Limitación importante
De la misma manera que en CloudFormation, **CloudFormation no reconcilia automáticamente el estado del recurso con la plantilla**. Si se detecta drift habrá que actuar del mismo modo que con CloudFormation:

- CloudFormation lo indica en su detección.
- Pero **no revierte los cambios manuales** a menos que se haga una actualización o recreación explícita, eliminando y volviendo a crear.
- Habitualmente se suele derivar esto a un entorno de trabajo en el que AWS Config detecta cambios 'non-compliance' predefinidos que desencadenan acciones medidas.

---

##  6. Eliminación de la infraestructura

```bash
cdk destroy
```

Confirmar con `y` cuando lo solicite.

---

## Estructura típica del proyecto

```
cdkproject2/
├── bin/
│   └── cdkproject2.ts
├── lib/
│   └── cdkproject2-stack.ts  ← código de infraestructura
├── package.json
├── cdk.json
├── tsconfig.json
```

---

Este README está pensado para entornos formativos como AWS Academy, donde no se permite IAM, y está probado paso a paso en CDK 2.x.
