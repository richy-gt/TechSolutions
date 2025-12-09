# **TechSolutions – Proyecto de Automatización y Seguridad en Linux**

Este repositorio contiene los módulos de despliegue, mantenimiento y endurecimiento del entorno Linux definidos para la empresa **TechSolutions**, junto con la evidencia del funcionamiento exitoso de cada script.
El objetivo del proyecto es automatizar la instalación de servicios, aplicar buenas prácticas de seguridad y garantizar la disponibilidad mediante respaldos programados.

---

# **1. Guía de Despliegue**

## ✅ **1.1. Clonar el repositorio**

```bash
git clone https://github.com/richy-gt/TechSolutions.git
cd TechSolutions
```

---

## ✅ **1.2. Estructura de carpetas**

```
deploy/          
maintenance/     
security/        
evidence/        
```

---

## ✅ **1.3. Orden estricto de ejecución**

⚠️ Todos los scripts deben ejecutarse como **root** o con `sudo`.

### **1. Primero: Aprovisionamiento**

Ejecuta una de las siguientes opciones según tu sistema:

```bash
sudo ./deploy/setup.sh           # Para distribuciones estándar
sudo ./deploy/setupNobara.sh     # Para Nobara Linux
```

Se hizo un archivo para nobara ya que esa es la distro con la que
trabajo, los archivos cambian ligeramente en solo el apartado de if.

Este módulo:

* Instala dependencias
* Configura Docker y docker-compose
* Crea estructura `/opt/webapp/html`
* Genera el usuario sysadmin
* Despliega la aplicación inicial

---

### **2. Segundo: Endurecimiento de Seguridad**

```bash
sudo ./security/hardening.sh
```

Este módulo:

* Configura reglas de firewall UFW
* Restringe acceso SSH
* Ajusta permisos de archivos críticos

---

### **3. Tercero: Respaldo del sistema**

```bash
sudo ./maintenance/backup.sh
```

Este módulo:

* Comprime el sitio web
* Sincroniza respaldo local
* Realiza prueba de transferencia remota con SCP

---

# **2. Justificación de Seguridad (Unidad VI)**

El endurecimiento del sistema es un proceso fundamental para garantizar la seguridad en entornos productivos. En primer lugar, **deshabilitar el inicio de sesión directo del usuario root** es una práctica esencial porque evita que atacantes exploten una cuenta con privilegios máximos. El usuario root es universal, bien conocido y siempre existe en cualquier sistema Linux, por lo que los intentos de fuerza bruta casi siempre lo toman como primer objetivo. Obligar a los administradores a usar cuentas personales más `sudo` permite registrar auditorías, trazabilidad y reducir el riesgo de escalamiento no autorizado.

Por otra parte, **filtrar puertos mediante firewall** es indispensable para minimizar la superficie de ataque. Un servidor expuesto sin control de tráfico permite accesos indeseados a servicios que no deberían estar disponibles para internet. Limitar estrictamente a puertos necesarios, como SSH (22) o el servicio web (8080), garantiza que solo servicios legítimos estén accesibles. Esta política de “deny by default” es un principio clave de seguridad defensiva, ya que impide conexiones indebidas, reduce vectores de ataque y fortalece la resiliencia del sistema frente a amenazas comunes como escaneo de puertos, bots automatizados o intentos de explotación remota.

---

# **3. Registro de Evidencia**

A continuación se incluyen las capturas almacenadas en la carpeta **evidence/** que verifican el funcionamiento correcto de cada módulo del proyecto.

### **Evidencia 1 – Despliegue inicial (`setup.sh` / `setupNobara.sh`)**

![Evidencia 1](./evidence/ev1.webm)

### **Evidencia 2 – Hardening del sistema (`hardening.sh`)**

![Evidencia 2](./evidence/ev2.webm)

### **Evidencia 3 – Respaldo (`backup.sh`)**

![Evidencia 3](./evidence/ev3.webm)
