<picture>
  <source srcset="https://www.pulumi.com/images/logo/logo-on-black.svg" media="(prefers-color-scheme: dark)">
  <img src="https://www.pulumi.com/images/logo/logo-on-white.svg" alt="Pulumi Logo" width="200"/>
</picture>

# Despliegue en AWS mediante Pulumi desde entorno Cloud9

Este proyecto crea infraestructura en AWS utilizando **Pulumi** con **TypeScript**, ejecutándose desde un entorno **AWS Cloud9**.  
Incluye: VPC, subred pública, tabla de rutas, security group con reglas individuales (SSH y HTTP), e instancia EC2 con user-data para LAMP stack (Amazon Linux 2023).

##  Archivos del proyecto

Los siguientes archivos deben estar presentes en el repositorio:

- `Pulumi.yaml`: define el nombre del proyecto, lenguaje usado (typescript) y la configuración base de Pulumi.
- `index.ts`: contiene el código fuente IaC que despliega los recursos AWS.
- `package.json`: define las dependencias del proyecto y scripts npm.
- `package-lock.json`: bloquea versiones específicas de dependencias instaladas.
- `tsconfig.json`: configuración del compilador TypeScript para este proyecto.

---

##  Pasos detallados para desplegar en AWS Cloud9

### 1. Acceder a la carpeta del proyecto en el repositorio clonado

```bash
cd pulumi-aws-deploy
```

---

### 2. Instalar Pulumi

```bash
curl -fsSL https://get.pulumi.com | sh
```

>  Después de la instalación, añade Pulumi al `PATH`:
```bash
echo 'export PATH=$PATH:/home/ec2-user/.pulumi/bin' >> ~/.bashrc
source ~/.bashrc
```

---

### 3. Iniciar sesión local (sin usar Pulumi Cloud)

Pulumi, por defecto, intenta conectarse a Pulumi Cloud para guardar los estados de despliegue. Si prefieres trabajar **completamente local**:

```bash
pulumi login --local
```
o bien
```bash
pulumi login --local --plaintext
```

La diferencia es que con la primera, Pulumi te pedirá una contraseña opcional para cifrar los secretos guardados (como contraseñas o claves API) y cona la segunda estará todo en texto plano.

---

### 4. Instalar dependencias del proyecto

```bash
npm install
```

---

### 5. Seleccionar o crear un stack

```bash
pulumi stack init dev
```

> El stack es el contenedor lógico de los recursos. `dev` es el nombre recomendado para un entorno de desarrollo.

---

### 6. Establecer la región AWS

```bash
pulumi config set aws:region us-east-1
```

---

### 7. Desplegar la infraestructura

```bash
pulumi up
```

- Revisa el plan mostrado.
- Escribe `yes` para confirmar.

Pulumi desplegará:
- VPC
- Subred
- Tabla de rutas
- Internet Gateway
- Security Group
- Reglas de SSH (22) y HTTP (80)
- Instancia EC2 con Apache + PHP funcionando

Pulumi mostrará al final la IP pública y DNS de la instancia.

---

### 8. Verificar despliegue inicial

Accede desde el navegador a:

```
http://<IP_PUBLICA>
```

deberías ver la página de `phpinfo()` generada automáticamente.

---

##  Comprobación de Drift

### 1. Simular un drift manual

- Accede a la consola de AWS.
- Localiza el **Security Group** creado.
- Añade manualmente una regla nueva que permita **Todo el tráfico (All Traffic)** desde cualquier IP (`0.0.0.0/0`).

### 2. Detectar el drift

- **Importante**: las reglas de seguridad están programadas como `SecurityGroupRule` individuales. Esto permite a Pulumi detectar cualquier cambio manual.

Si se hubieran definido directamente en la propiedad `ingress` del `SecurityGroup`, **Pulumi no detectaría** nuevas reglas añadidas manualmente.

#### Opciones para ver cambios:

- **Actualizar solo estado (no corrige):**

```bash
pulumi refresh
```
- Esto actualiza el estado local para reflejar la infraestructura real.

- **Ver diferencias (sin corregir nada):**

```bash
pulumi preview --diff
```
- Esto muestra qué cambiaría, sin actualizar el estado ni modificar recursos.

### 3. Corregir el drift

Para corregir el drift (volver al estado definido en el código):

```bash
pulumi up
```

- Revisa el plan.
- Confirma con `yes`.

Pulumi eliminará la regla "All Traffic" agregada manualmente.

Finalmente, puedes comprobar en la consola de AWS que la regla manual ha desaparecido.

---

##  Destrucción de recursos

Para eliminar todos los recursos creados:

```bash
pulumi destroy
```

>  Pulumi destruye los recursos en el orden correcto. Sin embargo, **mantiene** el historial y la configuración del stack (`Pulumi.dev.yaml`).


### Eliminar también el stack (opcional)

Si quieres eliminar también el stack y todo su rastro localmente:

```bash
pulumi stack rm dev
```

> Pulumi te pedirá confirmación escribiendo el nombre del stack para borrarlo.

Esto elimina:
- La configuración `Pulumi.dev.yaml`
- Historial de despliegues
- Estado local del stack

El código fuente (`index.ts`, `Pulumi.yaml`, etc.) **no se borra**.

---

##  Seguridad

- Si trabajas con secretos (`pulumi config set --secret`), recuerda usar una contraseña segura al iniciar sesión local.
- Guarda bien tu contraseña: si la pierdes, no podrás recuperar los valores cifrados.

---

##  Referencias adicionales

- [Documentación Pulumi AWS](https://www.pulumi.com/registry/packages/aws/)
- [Documentación Pulumi CLI](https://www.pulumi.com/docs/reference/cli/)
