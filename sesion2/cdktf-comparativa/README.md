# Comparativa CDKTF vs Terraform clásico

Este repositorio contiene una comparativa práctica entre Terraform clásico (HCL) y CDKTF (CDK for Terraform) para desplegar múltiples entornos de red en AWS. El objetivo es mostrar cómo CDKTF puede reducir drásticamente la repetición de código y mejorar la mantenibilidad al aprovechar estructuras de programación modernas como bucles y objetos.

---

## 🧱 Infraestructura objetivo (independientemente del enfoque)

Se desea desplegar las siguientes VPCs en AWS:

- **Región us-east-1**
  - `MyVPCa` con CIDR `10.0.0.0/16` y una subred pública `/24` en `us-east-1a`
  - `MyVPCb` con CIDR `10.1.0.0/16` y una subred pública `/24` en `us-east-1b`

- **Región us-west-2**
  - `MyVPCc` con CIDR `10.2.0.0/16` y una subred pública `/24` en `us-west-2a`
  - `MyVPCd` con CIDR `10.3.0.0/16` y una subred pública `/24` en `us-west-2b`

Para cada VPC se debe crear:

- Un Internet Gateway asociado
- Una tabla de rutas con una ruta por defecto (`0.0.0.0/0`) hacia el IGW
- Una subred pública con asignación de IP pública
- Un grupo de seguridad que permita tráfico entrante en los puertos **22 (SSH)** y **80 (HTTP)**
- Una instancia **EC2 t3.micro** con Amazon Linux 2023 (`ami-0e449927258d45bc4`), que instala automáticamente una pila **LAMP** mediante un script de `user_data`

---

## 🧾 `main.tf` — Terraform clásico (HCL plano)

Este archivo contiene una implementación completamente expandida y sin modularizar de los recursos necesarios para las 4 VPCs.

- Todo el código está **repetido manualmente** para cada VPC y cada recurso.
- Aunque es funcional, **no es eficiente** ni mantenible a medida que el número de entornos crece.
- Ideal para mostrar cómo puede volverse **verborreico y propenso a errores** el uso de Terraform sin módulos ni bucles.

---

## 🧾 `main.ts` — CDKTF (CDK for Terraform)

Este archivo contiene una implementación equivalente usando **TypeScript + CDKTF**.

- Se define una lista de objetos que representan las VPCs con sus parámetros clave (nombre, CIDR, región, AZ).
- Se usa un **bucle `forEach`** para generar dinámicamente todos los recursos para cada VPC.
- Esto permite mantener el código muy compacto, limpio y **fácilmente escalable**.
- CDKTF traduce esta lógica a Terraform plano (`.tf.json`) al ejecutar `cdktf synth`.

Este enfoque demuestra la **ventaja real de CDKTF**: escribir infraestructura como si fuera código real, con bucles, objetos y lógica de programación moderna.

---

## ✅ Conclusión

La infraestructura desplegada es exactamente la misma en ambos casos, pero:

- **Terraform clásico** requiere cientos de líneas de código repetidas
- **CDKTF** lo resuelve con una estructura clara, reutilizable y programática

Esto hace que CDKTF sea más adecuado para proyectos medianos o grandes, o cuando se requiere lógica condicional o generativa.
