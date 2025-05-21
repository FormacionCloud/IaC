# **Apartados extra para Terraform en AWS**

Proponemos una serie de ampliaciones y mejoras en la práctica, de las que no proporcionamos resolución directa pero sí indicaciones y que parten de la infraestructura completa, a implementar lógicamente en el código de Terraform y ser aplicadas posteriormente.

## 1. **Alta Disponibilidad en la infraestructura**

Siempre que hablamos de *Alta Disponibilidad*, nos referimos a la **capacidad de tener recursos en centros de datos que dificilmente puedan sufrir interrupciones de servicio simultáneamente**. En el caso de AWS, esto siempre pasa por tener recursos en varias Zonas de Disponibilidad (AZs). 

Actualmente tenemos un grupo de autoescalado con una Launch Template que sería capaz de proveer nuevas instancias repartidas en diferentes grupos de seguridad de forma alterna automáticamente. **¿Cómo se podría configurar en el código que lanzase al menos dos, en lugar de sólo una?**

Por otro lado, el servicio RDS permite una configuración de *Despliegue Multi-AZ* que automáticamente lanza una instancia de base de datos en espera en otra AZ, de forma transparente y sin tener que cambiar el endpoint al que se dirigen las peticiones de base de datos. **¿Cómo se podría configurar en el código que se realizase ese despliegue?**

Revisa el código, introduce las dos modificaciones y aplica los cambios en Terraform para que los refleje en AWS. Comprueba que efectivamente ahora tenemos Alta Disponibilidad, al tener recursos de aplicación web y de base de datos en dos AZs.


## 2. **Servidor seguro HTTPS con certificado válido mediante ACM y Route 53 (acceso por cuenta externa)**

En este caso, se trataría **utilizar un subdominio real para el Wordpress**, en lugar de uno ficticio, y que fuera **accesible mediante HTTPS por el puerto 443**, permitiendo así un portal seguro más acorde con la realidad. Se necesitará un certificado real almacenado en el servicio ACM, así como modificar el código de grupos de seguridad, y listeners, rules y uso del certificado por parte del balanceador de carga.

**El subdominio se registraría manualmente en Route 53**, a partir del añadido en una *hosted zone* de la cuenta completa del docente de la formación, para lo que se facilitaría **credencial IAM de consola en cuenta completa de AWS** con permisos sólo sobre una *hosted zone* de Route 53 para poder añadir un subdominio y las entradas requeridas por ACM.

Para no complicar la realización, **la generación del certificado ACM en el Learner Lab sería también manual**

Primeramente, es importante observar que **no nos valdrá la infraestructura actual (por el dominio ficticio de wordpress)**, así que antes de nada habrá que destruir la infraestructura.

Seguidamente y ya con el identificador del certificado ACM, se procederá a **actualizar el código de grupos de seguridad, y listeners, rules y uso del certificado por parte del balanceador de carga, variables**, y ya con las modificaciones aplicar los cambios en Terraform para que los refleje en AWS. 

Finalmente se puede comprobar que el wordpress es accesible por su nombre DNS real por HTTPS y dispone de un certificado válido.


## 3. **Portabilidad de la infraestructura e interposición de CDN CloudFront (requiere otro Laboratorio)**

Un caso típico es cuando se tiene una infraestructura y se desea trasladarla a otro entorno. En este caso, supondremos que se desea interponer la CDN CloudFront antes del balanceador de carga ALB, con un solo origen y comportamiento global (para mantene la simplicidad, aunque se permite complicarlo más si se desea hacer sólo para datos estáticos). El problema es que **los *AWS Learner Lab* no tienen acceso a CloudFront**, pero otros laboratorios como los *AWS Lab Project - Cloud Web Application Builder* **sí que permiten su uso**.

Así, se trataría de solicitar al formador del curso el alta en uno de esos laboratorios (o usar el que tenemos como *Educator* en AWS Academy) y **montar allí otra infraestructura de Cloud9** con clonado del mismo repositorio. 

Seguidamente y ya dentro del nuevo entorno, añadimos los cambios en el código para interponer la CDN CloudFront y aplicamos Terraform, comprobando que la infraestructura actualizada está en el nuevo laboratorio, habiendo completado la portabilidad.


## 4. **Mejorar la gestión de secretos con AWS Secrets Manager)**

Actualmente, las credenciales sensibles como `db_password` o `DEMO_PASSWORD` están en `variables.tf`, lo cual **no es seguro en producción**. 

En este apartado se pide **usar AWS Secrets Manager para resolver esta situación con plenas garantías de seguridad**. Para dejarlo sencillo, por un lado se pueden realizar acciones manuales en la consola y por otro lado cambios en el código a desplegar:

- Creación de los secretos con nombre lógico (`/wordpress/db_password`, etc.).
- Recuperación de los mismos  con `data "aws_secretsmanager_secret_version"` en el código de Terraform.
- Uso posterior en el código con referencia tipo `value = jsondecode(...)["clave"]`.

Primeramente, es importante observar que **no nos valdrá la infraestructura actual (ya está todo instalado)**, así que antes de nada habrá que destruir la infraestructura.

Seguidamente y ya con los cambios hechos, se procederá a **aplicar los cambios en Terraform para que los refleje en AWS**. 

Finalmente simplemente se comprueba que funciona el Wordpress normalmente y eso será señal de que todo está correcto. *Se puede depurar mediante el propio terraform y los logs del cloud-init de la instancia mediante SSM*.
