# Aplicación serverless para redimensionar imágenes que se suban a un bucket S3

## Instrucciones
Abrir el entorno de IDE Cloud de la cuenta de laboratorio de AWS.

En un terminal, acceder a la carpeta `src` e instalar dependencias:
```bash
cd src
npm install
```

A continuación, volver al directorio raíz del repositorio y lanzar el comando para desplegar la aplicación:
```bash
cd ..
sam deploy --guided
```

Aceptar las opciones por defecto con la excepción del __nombre del bucket__ , el __email para suscribirse__ a las notificaciones (debes tener acceso a él) y el __Allow SAM CLI IAM role creation__ (que se pone a "N") . Para el nombre S3 se debe elegir un nombre de bucket único a nivel de la región. Recomendación: elegir `nombre + apellidos + número aleatorio` (elegir únicamente letras minúsculas y números).

## Prueba de la aplicación
Primeramente, revisa tu email para confirmar la suscripción SNS.

Acceder a la consola, al servicio S3. Localizar el bucket creado. Crear una carpeta llamada `original` y subir un fichero de imagen en su interior. Por último, comprobar que se genera un fichero con el mismo nombre en la ruta `resized/` dentro del bucket.

En el servicio Lambda, sección "Applications" estará la aplicación como un conjunto de recursos, por si se desea explorar su estructura.

## Borrado de recursos
En la consola de S3, localizar el bucket creado. Seleccionarlo y vaciarlo (opción _Empty_).

Una vez vaciado el bucket, ejecutar el siguiente comando en IDE Cloud:
```bash
sam delete
```

Y pulsar `y` en las dos preguntas que indica.
