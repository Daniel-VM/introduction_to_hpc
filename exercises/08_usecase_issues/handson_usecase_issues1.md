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

```

```

Recomendaciones:

#### 4. Interpreción de logs

Vamos a interpretar algunos logs generados por el sistema y por los trabajos

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 5. Ganglia

Vamos a ver como se puede emplear [**Ganglia**](http://ganglia.isciii.es/) como herramienta de diagnóstico y monitorización. Ganglia es una herramienta de monitorización y diagnóstico de sistemas, muy usada en entornos de HPC (High Performance Computing) y clústeres. Ganglia recopila métricas de cada nodo del clúster como: Uso de CPU, memoria, red, carga del sistema (load average), espacio en disco, y otras métricas personalizadas. Se visualiza a través de una interfaz web con gráficos históricos y en tiempo real. Para qué sirve:

- Detectar sobrecarga en un nodo.
- Ver tendencias de consumo de recursos.
- Diagnosticar cuellos de botella.
- Comprobar si los trabajos se están ejecutando correctamente o si saturan el sistema.

Observamos:

```

```

Recomendaciones:

#### 6. Problemas de memoria

En ocasiones cuando estemos trabajando en el HPC podemos observar este error `PONER AQUI EL ERROR`. Este se debe a que la memoria de alguna de las particiones que estamos empleando está llena. Vamos a revisar el tamaño de las particiones para gestionar el almacenamiento de forma eficiente.

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 7. Permisos de las distintas particiones

Como todos sabemos en este punto, par partición de `/scratch/` tiene permisos de lectura, pero no permisos de escritura. Si no trabajamos con las rutas correctas nos vamos a encontrar con problemas de permisos cuando estemos trabajando en el HPC.

Vamos a ver que pasa si intentamos crear un archivo en `/scratch/bi`:

```bash
cd /scratch/bi/
touch test_file.txt
```

Observamos:

```
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

```
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

```

```

Recomendaciones:

#### 9. Lanzar un pipeline de Nextflow: Ejecución, revisión e interpretación

En este ejercicio vamos a ejecutar el pipeline de [**nf-core/bacass**]() indicando todos los pasos a seguir:

- Crear la carpeta de trabajo
- Preparar los archivos necesarios
- Ejecutar el pipeline
- Revisar los logs y resultados
- Revisar la carpeta `work`

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones: