# Cliente para interactuar con la plantilla AWS SAM "Serverless API"

Puedes ejecutar estos comandos en el entorno Cloud9 de la cuenta de AWS Academy Learner Lab.

## Creación del bucket de s3
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
