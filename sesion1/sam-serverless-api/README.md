# Cliente para interactuar con la plantilla AWS SAM "Serverless API"

## Aplicación SAM (backend)
### Creación de la aplicación
```bash
sam init
```

En el asistente, seleccionar:
1. `Quick Start Template`
2. `Serverless API` (opción 7)
3. Seleccionar `NodeJS 20.x`
4. No activar `X Ray Tracing`
5. No activar `CloudWatch Insights`
5. No activar `Structured Logs`

### Modificación del fichero `template.yaml`
Una vez creada el directorio de la aplicación, modificar el fichero `template.yaml`. Añadir al final el siguiente código para activar CORS (acceso a la API desde un nombre de dominio diferente):
```yaml
Globals:
  Api:
    Cors:
      AllowMethods: "'GET,POST,PUT, OPTIONS'"
      AllowHeaders: "'content-type'"
      AllowOrigin: "'*'"
```

En el caso de lanzar esta aplicación en un __laboratorio de AWS Academy__, modificar también el mismo fichero para añadir un rol para cada una de las __3 funciones Lambda__ creadas. Previamente hay que ir al servicio `IAM` y buscar el `ARN` del rol llamado `LabRole`. Una vez copiado el ARN de dicho rol, hay que añadir la siguiente configuración dentro de la sección `Properties` para cada una de las 3 funciones, respetando los tabuladores. Quedará algo así:
```yaml
Role: arn:aws:iam::XXXXXXXXXXXX:role/LabRole
```

### Modificación del código de las funciones lambda
Para cada una de las funciones lambda creadas, hay que modificar su código fuente y añadir las cabeceras CORS en la respuesta. Por ejemplo, en la función `get-all-items.js` quedará así:
```js
const response = {
        statusCode: 200,
        body: JSON.stringify(items),
        headers: {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET"
        },
    };
```

### Despliegue
Una vez modificados todos los ficheros y guardados los cambios, hay que ejecutar:

```bash
sam deploy
```

Si se produce algún error, habrá que eliminar el stack mediante `sam delete`. A continuación se podrá realizar `sam deploy` otra vez.

Por último, anotar la URL de la API desplegada.

## Instalar frontend en S3

### Creación del bucket de s3
```bash
aws s3 mb s3://MINOMBREDEBUCKET
```

Hay que elegir un nombre de bucket único a nivel global.

### Desactivar protección de acceso público
```bash
aws s3api delete-public-access-block --bucket MINOMBREDEBUCKET
```

### Actualizar política de permisos del bucket
En primer lugar, hay que editar el fichero `bucket-public-policy.json` y poner el nombre del bucket creado. A continuación hay que ejecutar:
```bash
aws s3api put-bucket-policy --bucket MINOMBREDEBUCKET --policy file://bucket-public-policy.json
```

### Copiar archivo del frontend
```bash
aws s3 cp index.html s3://MINOMBREDEBUCKET/index.html 
```


### Configuración de sitio web estático
```bash
aws s3 website s3://MINOMBREDEBUCKET --index-document index.html
```

La URL del sitio web estático será `http://MINOMBREDEBUCKET.s3-website.REGION.amazonaws.com`, sustituyendo `REGION` y `MINOMBREDEBUCKET` por los valores correspondientes.


## Borrado de recursos
- Borrar el contenido del bucket y el bucket
- Ejecutar `sam delete` para borrar las funciones, API y tabla de base de datos
