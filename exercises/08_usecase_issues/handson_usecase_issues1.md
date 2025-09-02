# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

BU-ISCIII

## Práctica 10: Casos Prácticos y Problemas conocidos

### Descripción

En esta práctica se trabajará con situaciones reales y problemas comunes que pueden aparecer en entornos de computación de alto rendimiento (HPC). El objetivo es aprender a identificar, diagnosticar y resolver incidencias, así como adoptar buenas prácticas en la gestión de recursos y ejecución de trabajos.

### Ejercicios

#### 1. Reservar más recursos de los disponibles

Vamos a intentar reservar más recursos de los disponibles para comprobar cómo el trabajo no entra en cola.

Para ver los recursos límite de los nodos de los que disponemos podemos ejecutar: `sinfo -o "%25N  %10c  %20m  %30G"`:

```bash
NODELIST                                            CPUS        MEMORY                GRES                           
ideafix[01-32]                                      32          385000+               local_scratch:880G
```

Para ver las la información de las particiones ejecutamos `sinfo`:

```bash
$ sinfo 
PARTITION  AVAIL  TIMELIMIT  NODES  STATE NODELIST
long_idx      up 10-00:00:0      7  drain ideafix[01,04,08,10-13]
long_idx      up 10-00:00:0      1    mix ideafix16
long_idx      up 10-00:00:0     24   idle ideafix[02-03,05-07,09,14-15,17-32]
middle_idx    up 2-00:00:00      7  drain ideafix[01,04,08,10-13]
middle_idx    up 2-00:00:00      1    mix ideafix16
middle_idx    up 2-00:00:00     24   idle ideafix[02-03,05-07,09,14-15,17-32]
short_idx*    up   12:00:00      7  drain ideafix[01,04,08,10-13]
short_idx*    up   12:00:00      1    mix ideafix16
short_idx*    up   12:00:00     24   idle ideafix[02-03,05-07,09,14-15,17-32]
tmp_idx       up   infinite      7  drain ideafix[01,04,08,10-13]
tmp_idx       up   infinite      1    mix ideafix16
tmp_idx       up   infinite     24   idle ideafix[02-03,05-07,09,14-15,17-32]
```

Podemos ver que tenemos un máximo de 32 cpus y un máximo de memoria de 385000Mb, además tenemos 4 tipos de colas, las long, con un tiempo límite de 10 días, las middle con un tiempo limite de 2 días, las short con un tiempo límite de 12h y las tmp que no tienen tiempo límite.

Para ver el estado de mis trabajos en la cola con información útil:

```bash
squeue -o "%7i %75j %8T %10u %5a %10P %8Q %5D %11l %8M %7C %7m %R"
```

Si lanzamos un trabajo reservando más recursos de los que disponemos ejecutando:

Más CPUs:

```bash
srun --cpus-per-task 33 --output MORE_CPUS.%j.log --job-name MORE_CPUS sleep 1
```

Observamos:

```bash
srun: error: CPU count per node can not be satisfied
srun: error: Unable to allocate resources: Requested node configuration is not available
```

Más memoria:

```bash
# Más memoria
srun --output MORE_MEM.%j.log --mem 3850000M --job-name MORE_MEM sleep 1
```

Observamos:

```bash
srun: error: Memory specification can not be satisfied
srun: error: Unable to allocate resources: Requested node configuration is not available
```

Más tiempo:

```bash
# Más memoria
srun --output MORE_TIME.%j.log --partition short_idx --time 2-00:00:00 --job-name MORE_TIME sleep 1 &
```

Observamos:

```bash
srun: Requested partition configuration not available now
srun: job 4787287 queued and waiting for resources
```

Pero si observamos nuestra cola veremos:

```bash
4787287 MORE_TIME                                                                   PENDING  s.varona   bi    short_idx  17928    1     2-00:00:00  0:00     1       4G      (PartitionTimeLimit)
```

Nos sale `PartitionTimeLimit` y nunca va a ejecutarse. Hay que matar el trabajo con `scancel 4787287`. El numero es el JOB_ID del gestor de colas.

Recomendaciones:

- Revisar siempre el numero máximo de recursos disponibles
- Reservar siempre lo que creamos que va a necesitar un proceso:
  - Reservar más recursos hará que tengamos menos prioridad en la cola
  - Reservar menos recursos hará que el proceso se pare y tengamos que volver a empezar

#### 2. Un trabajo utiliza más memoria de la solicitada

Vamos a ejecutar un trabajo que utilice más memoria de la solicitada para observar el comportamiento del sistema.

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

##### 3. Load average

Vamos a simular un **load average** elevado y analizar su impacto.

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

#### 4. Interpreción de logs

Vamos a interpretar algunos logs generados por el sistema y por los trabajos

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

#### 5. Ganglia

Vamos a ver como se puede emplear [**Ganglia**](http://ganglia.isciii.es/) como herramienta de diagnóstico y monitorización. Ganglia es una herramienta de monitorización y diagnóstico de sistemas, muy usada en entornos de HPC (High Performance Computing) y clústeres. Ganglia recopila métricas de cada nodo del clúster como: Uso de CPU, memoria, red, carga del sistema (load average), espacio en disco, y otras métricas personalizadas. Se visualiza a través de una interfaz web con gráficos históricos y en tiempo real. Para qué sirve:

- Detectar sobrecarga en un nodo.
- Ver tendencias de consumo de recursos.
- Diagnosticar cuellos de botella.
- Comprobar si los trabajos se están ejecutando correctamente o si saturan el sistema.

Observamos:

```bash

```

Recomendaciones:

#### 6. Problemas de memoria

En ocasiones cuando estemos trabajando en el HPC podemos observar este error `No space left on device`. Este se debe a que la memoria de alguna de las particiones que estamos empleando está llena. Vamos a revisar el tamaño de las particiones para gestionar el almacenamiento de forma eficiente.

Ejecutamos:

```bash
df -h
```

Observamos:

```bash
Filesystem                          Size  Used Avail Use% Mounted on
tmpfs                                16G  4.4G   12G  29% /
devtmpfs                             16G     0   16G   0% /dev
tmpfs                                16G  571M   15G   4% /dev/shm
tmpfs                                16G  746M   15G   5% /run
tmpfs                                16G     0   16G   0% /sys/fs/cgroup
IP:/HPC_UI_ACTIVE                    60T   54T  6.7T  89% /data
IP:/HPC_Home                        200G  149G   52G  75% /home
IP:/HPC_UCCT_BI_ACTIVE               30T   19T   12T  62% /data/ucct/bi
IP:/HPC_Scratch                     7.4T  7.4T  0.0T 100% /data/ucct/bi/scratch_tmp
IP:/HPC_Scratch                     7.4T  7.4T  0.0T 100% /scratch
//IP7/hpc-bioinfo/                  1.0T  713G  312G  70% /data/ucct/bi/sftp
IP:/HPC_Soft                        350G  295G   56G  85% /soft
IP:/HPC_UCCT_ME_ARCHIVED             42T   38T  4.2T  91% /archived/ucct/me
IP:/HPC_UCCT_BI_ARCHIVED             50T   37T   14T  74% /archived/ucct/bi
IP:/HPC_Opt                         100G   15G   86G  15% /opt
IP:/NGS_Data_FastQ_Active            15T  8.0T  7.1T  54% /srv/fastq_repo
//IP7/hpc-genvigies/                1.0T  436G  589G  43% /sftp/genvigies
tmpfs                               3.1G     0  3.1G   0% /run/user/3009
tmpfs                               3.1G     0  3.1G   0% /run/user/3014
tmpfs                               3.1G     0  3.1G   0% /run/user/3015
tmpfs                               3.1G     0  3.1G   0% /run/user/3030
tmpfs                               3.1G     0  3.1G   0% /run/user/3022
tmpfs                               3.1G     0  3.1G   0% /run/user/3029
tmpfs                               3.1G     0  3.1G   0% /run/user/1218
tmpfs                               3.1G     0  3.1G   0% /run/user/1311
tmpfs                               3.1G     0  3.1G   0% /run/user/1000
tmpfs                               3.1G     0  3.1G   0% /run/user/3006
tmpfs                               3.1G     0  3.1G   0% /run/user/3013
tmpfs                               3.1G     0  3.1G   0% /run/user/1212
tmpfs                               3.1G     0  3.1G   0% /run/user/3039
tmpfs                               3.1G     0  3.1G   0% /run/user/3017
```

Aquí podemos ver que el uso de `/scratch` y `/data/ucct/bi/scratch_tmp` es del 100% y que no queda espacio libre en la memoria. `/scratch` tiene 7Tb de memoria para compartir entre todos los usuarios del HPC. No es una unidad de almacenamiento sino una unidad de computo, por lo que debe permanecer nada ahí que no se vaya a computar a corto plazo (24 horas) ya que el almacenamiento es limitado.

En estos casos habría que observar qué carpetas son las que más especio ocupan para borrarlas lo antes posible. Esto se realiza con el siguiente comando:

```bash
du -sh ./*
```

Observamos:

```bash
4.0K    ./00-reads
81G     ./20250728_ANALYSIS02_METAGENOMIC_HUMAN
78G     ./20250728_ANALYSIS05_TAXPROFILER
4.0K    ./lablog_taxprofiler
40K     ./lablog_viralrecon
0       ./samples_id.txt
0       ./samples_ref.txt
```

La primera columna es el espacio (en K, M o G) que ocupa un archivo o carpeta y la segunda es el nombre del archivo o carpeta. Es este ejemplo concreto tendríamos que revisar las carpetas `./20250728_ANALYSIS02_METAGENOMIC_HUMAN` y `./20250728_ANALYSIS05_TAXPROFILER` para ver si alguno de los archivos que tienen dentro se puede borrar. Esto solo en el caso de que siga necesitando computar con estos archivos, si no, habría que copiar la carpeta a una unidad de almacenamiento a largo plazo y borrarlo de `/scratch/bi`

Recomendaciones:

- Siempre que hayamos terminado un análisis, eliminar las carpetas temporales (work, tmp...)
- Evitar almacenar archivos grandes redundantes (.bam, .sorted.bam, .sorted.trimmed.bam...)
- Siempre que hayamos terminado con una carpeta, copiarla a una unidad de almacenamiento a largo plazo.

#### 7. Permisos de las distintas particiones

Como todos sabemos en este punto, par partición de `/scratch/` tiene permisos de lectura, pero no permisos de escritura. Si no trabajamos con las rutas correctas nos vamos a encontrar con problemas de permisos cuando estemos trabajando en el HPC.

Vamos a ver que pasa si intentamos crear un archivo en `/scratch/bi`:

```bash
cd /scratch/bi/
touch test_file.txt
```

Observamos:

```bash
touch: cannot touch 'test_file.txt': Read-only file system
```

Nos dice que es un directorio solo de lectura, por lo que no podemos crear un archivo

Vamos a ver que pasa si intentamos crear un archivo en `/data/ucct/bi/scratch_tmp/bi`:

```bash
cd /data/ucct/bi/scratch_tmp/bi/
touch test_file.txt
ls
```

Observamos que el fichero se ha creado correctamente.

¿Por qué trabajar en `/scratch/bi` si no tenemos permisos de escritura, si en `/data/ucct/bi/scratch_tmp/bi` si que los tenemos? Porque `/data/ucct/bi/scratch_tmp/bi` es la carpeta `/scratch/bi` montada y `/data/ucct/bi/scratch_tmp/bi` no existe en los nodos de computo.

Que pasa si lanzo un trabajo desde `/data/ucct/bi/scratch_tmp/bi`?

```bash
cd /data/ucct/bi/scratch_tmp/bi/
srun --output SCRATCH_TMP.%j.log --job-name SCRATCH_TMP cat test_file.txt &
```

Observamos:

```bash
srun: error: ideafix09: task 0: Exited with exit code 1
```

Tenemos que leer el archivo .log para ver que está ocurriendo:

```bash
cat SCRATCH_TMP.log 
slurmstepd-ideafix09: error: couldn't chdir to `/data/ucct/bi/scratch_tmp/bi': No such file or directory: going to /tmp instead
slurmstepd-ideafix09: error: couldn't chdir to `/data/ucct/bi/scratch_tmp/bi': No such file or directory: going to /tmp instead
/usr/bin/cat: test_file.txt: No such file or directory
```

Como `/data/ucct/bi/scratch_tmp/bi` no existe en los nodos de computo, se mueve por defecto a `/tmp`, pero ahí no existe el archivo que hemos creado antes.

Para que podamos crear archivis en `/data/ucct/bi/scratch_tmp/bi` y procesarlos en los nodos de computo en `/scratch/bi`, tenemos que emplear rutas relativas para los archivos, y usar el parámetro `chdir` en el `srun`.

Primero escribimos algo dentro de `test_file.txt` como control positivo. Después ejecutamos:

```bash
cd /data/ucct/bi/scratch_tmp/bi/
srun --output SCRATCH_TMP.%j.log --chdir /scratch/bi/ --job-name SCRATCH_TMP cat test_file.txt &
```

Al terminar el trabajo deberiamos leer el contenido del archivo .log y confirmar que sale el contenido de `test_file.txt`. Aquí lo que ha ocurrido es que en lugar de moverse a `/tmp` se ha movido a `/scratch/bi/`, donde si existe el archivo que habíamos creado a mano desde `/data/ucct/bi/scratch_tmp/bi`.

#### 8. Gestión de ficheros

En este ejercicio vamos a ir creando algunos scripts "tipo" para que podáis guardarlos y emplearlos como buenas prácticas para la gestión de ficheros.

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

#### 9. Lanzar un pipeline de Nextflow: Ejecución, revisión e interpretación

En este ejercicio vamos a ejecutar el pipeline de [**nf-core/bacass**](https://github.com/nf-core/bacass) indicando todos los pasos a seguir:

- Crear la carpeta de trabajo
- Preparar los archivos necesarios
- Ejecutar el pipeline
- Revisar los logs y resultados
- Revisar la carpeta `work`

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:
