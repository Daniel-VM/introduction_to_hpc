# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

BU-ISCIII

## Práctica 1: Acceso y transferencia de datos al clúster

## Índice

- [Curso Práctico de Iniciación al uso del Entorno de Alta Computación](#curso-práctico-de-iniciación-al-uso-del-entorno-de-alta-computación)
  - [Práctica 1: Acceso y transferencia de datos al clúster](#práctica-1-acceso-y-transferencia-de-datos-al-clúster)
  - [Índice](#índice)
    - [Descripción](#descripción)
    - [Notas importantes](#notas-importantes)
    - [Ejercicio 1: Conexión SSH](#ejercicio-1-conexión-ssh)
    - [Ejercicio 2: Exploración del entorno](#ejercicio-2-exploración-del-entorno)
    - [Ejercicio 3: Configuración de clave SSH](#ejercicio-3-configuración-de-clave-ssh)
    - [Ejercicio 4: Transferencia de datos](#ejercicio-4-transferencia-de-datos)
      - [Subir archivo con `scp`](#subir-archivo-con-scp)
      - [Descargar archivo con `scp`](#descargar-archivo-con-scp)
      - [Sincronizar carpeta con `rsync`](#sincronizar-carpeta-con-rsync)
      - [Sincronizar carpeta con WinScp](#sincronizar-carpeta-con-winscp)
      - [Sincronizar carpeta con Filezilla](#sincronizar-carpeta-con-filezilla)
    - [Ejercicio 5: Verificación de integridad](#ejercicio-5-verificación-de-integridad)
    - [Ejercicio 6: Organización de proyecto](#ejercicio-6-organización-de-proyecto)

### Descripción

En esta práctica aprenderás a:

- Conectarte al clúster HPC usando SSH.
- Explorar el entorno de trabajo.
- Configurar intercambio de claves SSH para no tener que introducir la contraseña en cada conexión.
- Transferir datos entre tu equipo y el clúster utilizando diferentes herramientas (línea de comandos y programas con interfaz gráfica).
- Verificar la integridad de los ficheros transferidos mediante checksums.
- Construir una estructura de directorios para organizar un proyecto.

### Notas importantes

- El acceso se realiza al nodo de login `portutatis.isciii.es` mediante el puerto `32122`.
- No se deben ejecutar cálculos en el nodo de login, solo gestionar ficheros y enviar trabajos a la cola.
- Los datos de usuario se organizan en diferentes espacios de trabajo:

  - `/home/usuario` → scripts y ficheros pequeños.
  - `/data/unidad` → datos y resultados de proyectos.
  - `/scratch/unidad` → ejecución temporal de trabajos (se eliminan ficheros inactivos a los 5 días).
  - `/local_scratch` → espacio temporal en cada nodo, se elimina al terminar el trabajo.
- No almacenar información no relacionada con los cálculos autorizados.

### Ejercicio 1: Conexión SSH

- Lo primero que vamos a hacer es conectarnos al clúster con nuestras credenciales personales.

```bash
ssh -p 32122 usuario@portutatis.isciii.es
```

Output:

```bash
usuario@portutatis.isciii.es's password:
Last login: Tue Aug 20 10:21:45 2025 from 192.168.1.10
[usuario@portutatis ~]$
```

El sistema solicita la contraseña del usuario. Tras introducirla, accedemos al nodo de login, donde aparece el `prompt` con nuestro nombre de usuario y la ruta `~` que corresponde al directorio `/home/usuario`.

### Ejercicio 2: Exploración del entorno

- Ahora vamos a familiarizarnos con los directorios del clúster.

```bash
pwd
ls -l /
```

Output:

```bash
/home/usuario

drwxr-xr-x  10 root   root   4096 Jul 10 10:00 bin
...  
drwxr-xr-x   5 usuario unidad 4096 Jul 20 12:34 data
...  
drwxr-xr-x   5 usuario unidad 4096 Jul 20 12:34 scratch
```

El comando `pwd` muestra la ruta actual. El comando `ls -l /` permite visualizar qué directorios principales existen: `/home`, `/data`, `/scratch`, etc. Estos son los sistemas de ficheros disponibles en el clúster.

### Ejercicio 3: Configuración de clave SSH

- Ahora vamos a configurar nuestra key ssh para poder conectarnos sin necesidad de escribir contraseña en cada acceso.
- Debemos generar la clave ssh-key desde nuestro ordenador local y copiarla a portutatis.isciii.es

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -p 32122 usuario@portutatis.isciii.es
```

Output:

```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/home/local/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
...
Number of keys added: 1
Now try logging into the machine, with:   ssh 'usuario@portutatis.isciii.es'
```

El comando `ssh-keygen` genera una nueva clave pública/privada en el directorio `~/.ssh/`. Con `ssh-copy-id` copiamos la clave al clúster. A partir de este momento, las conexiones SSH se autentican sin pedir la contraseña.

### Ejercicio 4: Transferencia de datos

- En este ejercicio vamos a tranferir archivos desde nuestro ordenador local al hpc con varias opciones: `scp`, `rsync`, WinSCP o FileZilla.

#### Subir archivo con `scp`

```bash
scp -P 32122 archivo.txt usuario@portutatis.isciii.es:/data/unidad/
```

Output:

```bash
archivo.txt                               100%   12KB  1.2MB/s   0:00
```

#### Descargar archivo con `scp`

```bash
scp -P 32122 usuario@portutatis.isciii.es:/data/unidad/archivo.txt ./
```

Output:

```bash
archivo.txt                               100%   12KB  1.2MB/s   0:00
```

#### Sincronizar carpeta con `rsync`

```bash
rsync -avz -e "ssh -p 32122" carpeta/ usuario@portutatis.isciii.es:/data/unidad/carpeta/
```

Output:

```bash
sending incremental file list
./
archivo1.txt
archivo2.txt
sent 1.23K bytes  received 45 bytes  2.55K bytes/sec
total size is 34.5K  speedup is 27.62
```

#### Sincronizar carpeta con WinScp

- Abrimos WinSCP

#### Sincronizar carpeta con Filezilla

- Abrimos Filezilla

- `scp` copia archivos individuales de manera directa.
- `rsync` sincroniza directorios y solo transfiere cambios, lo que ahorra tiempo en transferencias repetidas.
- --WinSCP-- y --FileZilla-- ofrecen interfaz gráfica, con arrastrar y soltar. La configuración requiere: `host = portutatis.isciii.es`, `puerto = 32122`, `usuario = usuario`.

---

### Ejercicio 5: Verificación de integridad

--Objetivo:-- Comprobar que los archivos no se corrompen al transferirse.

--Comandos:--

```bash
md5sum archivo.txt > archivo.txt.md5
scp -P 32122 archivo.txt.md5 usuario@portutatis.isciii.es:/data/unidad/
ssh -p 32122 usuario@portutatis.isciii.es "cd /data/unidad && md5sum -c archivo.txt.md5"
```

--Output esperado (correcto):--

```bash
archivo.txt: OK
```

--Output esperado (fallido):--

```bash
archivo.txt: FAILED
md5sum: WARNING: 1 computed checksum did NOT match
```

--Explicación:--
Un checksum es un valor hash generado a partir del contenido de un archivo. Si el archivo se modifica durante la transferencia, el valor no coincide y se detecta el error.

---

### Ejercicio 6: Organización de proyecto

--Objetivo:-- Crear una estructura de directorios estándar para organizar datos.

--Comandos:--

```bash
mkdir -p /data/unidad/ejemplo_proyecto/{raw_data,analysis,results,scripts}
ls -R /data/unidad/ejemplo_proyecto
```

--Output esperado:--

```bash
/data/unidad/ejemplo_proyecto:
analysis  raw_data  results  scripts

/data/unidad/ejemplo_proyecto/analysis:

/data/unidad/ejemplo_proyecto/raw_data:

/data/unidad/ejemplo_proyecto/results:

/data/unidad/ejemplo_proyecto/scripts:
```

--Explicación:--
La organización clara de los proyectos permite localizar fácilmente los datos, compartir con colaboradores y evitar problemas de almacenamiento.
