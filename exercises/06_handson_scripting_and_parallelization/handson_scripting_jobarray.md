# HandsOn: JobArrays (Slurm)

## Descripción

En esta práctica vamos a aprender a como construir un JobArray y saber cuándo utilizarlos. Ahora tienes más de 20 muestras (FASTQ) que procesar y necesitas utilizar el mismo comando, por ejemplo `fastqc`. Comúnmente pensaríamos en utilizar un `for loop` o similar para ejectar el comando en cada una de las muestras. Pero este es un procedimiento lento y no óptimizado para trabajar en una infraestructura HPC. 

En su lugar, los **Job Arrays** te permiten enviar un único trabajo que se divide en N tareas (una por muestra), ejecutadas en paralelo y gestionadas por el *job scheduler* de Slurm. Cada tarea recibe su propio índice (**$SLURM_ARRAY_TASK_ID**) y puede escribir sus logs y resultados por separado. Ventajas frente a un for manual:

Ventajas del array:

- Paraleliza tareas.
- Reservas CPU/Mem/Tiempo por tarea (uso justo y reproducible).
- Logs separados → depuración más fácil.

## Notas importantes

* Un array es 1 job con N tareas (índices): SLURM_ARRAY_TASK_ID = 1..N.
* Usa %A (JobID del array) y %a (índice) en --output/--error para tener un log por tarea.
* Limita concurrencia con %K en --array=1-N%K (evita saturar la cola).
* Variables útiles en el script:
* SLURM_ARRAY_JOB_ID, SLURM_ARRAY_TASK_ID, SLURM_ARRAY_TASK_COUNT.



# Ejercicio 1 — Job Arrays intro

Vamos a trabajar con unos ficheros FASTQ llamados sample1.fastq.gz, sample2.fastq.gz, … en `data/`. El objetivo es construir un Job Array que ejecute el mismo comando entre N tareas y que cada muestra (sample1, sample2...) se procese en cada una de estas tareas. 

Recordemos los Job Arrays crean una tarea y cada tarea se le asigna un número. Podemos acceder al número de la tarea utilizando la variable de entorno `${SLURM_ARRAY_TASK_ID}`.

Guarda como ``array_intro.sbatch``:

```bash
#!/bin/bash
#SBATCH --job-name=array_intro                  # Nombre del job (visible en la cola)
#SBATCH --chdir=/scratch/bi/TESTS/daniel_vm/intro_to_hpc  # Carpeta de trabajo (ajústala a tu ruta)
#SBATCH --partition=short_idx                   # Partición/cola a usar
#SBATCH --array=1-9%3                           # Índices del array: 1..10, máx. 3 tareas simultáneas
#SBATCH --cpus-per-task=1                       # Hilos por tarea (FastQC usa 1 por defecto)
#SBATCH --mem=2G                                # RAM por tarea (ajusta si hace falta)
#SBATCH --time=00:05:00                         # Límite de tiempo por tarea
#SBATCH --output=logs/intro_%A_%a.out           # Log STDOUT por tarea  (%A=ArrayID, %a=TaskID)
#SBATCH --error=logs/intro_%A_%a.err            # Log STDERR por tarea  (%A=ArrayID, %a=TaskID)

# Carga del software necesario (módulo de FastQC)
module load FastQC/0.11.9-Java-11

# Asegura que existen las carpetas de logs y resultados
mkdir -p logs results/intro
OUTDIR="results/intro"

# Ejecuta FastQC sobre el par R1/R2 correspondiente al índice de la tarea
fastqc -o "$OUTDIR" "data/sample0${SLURM_ARRAY_TASK_ID}_R1.fastq.gz" "data/sample0${SLURM_ARRAY_TASK_ID}_R2.fastq.gz"

# Cada tarea del array procesa un par de archivos:
# data/sample${SLURM_ARRAY_TASK_ID}_R1.fastq.gz  y  data/sample${SLURM_ARRAY_TASK_ID}_R2.fastq.gz
echo "[INFO] JobID=${SLURM_ARRAY_JOBID}; Task=${SLURM_ARRAY_TASK_ID}; End=$(date)"
```

Lanzar y monitorizar

```bash
sbatch array_intro.sbatch
watch squeue --me
sacct -j <ARRAY_ID> -o JobID,JobName,State,Elapsed,MaxRSS,NodeList
```

**PREGUNTAS**

- ¿Qué valores ves de ArrayID y TaskID en los logs (logs/intro_%A_%a.out)?
- ¿Qué fichero procesa la tarea 7?
- ¿Cuántas tareas aparecen en R a la vez?.
- ¿Qué MaxRSS típico ves por tarea en `sacct`? ¿Encaja con --mem=2G descrito en la cabecera del archivo sbatch?


## Ejercicio 2 - Job Array real - QC

## Pasos para crear un JobArray

Supongamos, que los archivos que tenemos que procesar no tienen en su nombre un índice que nos permita asignar la tarea del Job Array a este mismo (tal y como hemos visto en el ejemplo anterior). Este va a ser el escenario que nos encontremos el 99% de las veces. Para afrontarlo debemos:

- Generar una lista de los archivos que participarán en el JobArray.

```bash
ls data/*R1.fastq.gz | sort > data/filelist_R1.txt
```
> Explora el contenido de filelist_R1.txt

- Distribuir las líneas del archivo `data/filelist.txt` a cada tarea utilizando `sed`:

```bash
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" data/filelist_R1.txt)
```
> Este comando hace que cada tarea del array lea su línea correspondiente en el archivo `data/filelist.txt`. Por ejemplo, cuando se ejecute el script la tarea `3` del array leerá la línea número 3 del archivo filelist.


Ahora veamos cómo construir el archivo sbatch para este escenario (llamemos a este archivo ``fastqc_array.sbatch`).

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_array
#SBATCH --chdir=/scratch/bi/TESTS/daniel_vm/intro_to_hpc
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --array=1-10
#SBATCH --output=logs/array_%A_%a.out  # %A JobID array, %a índice
#SBATCH --error=logs/array_%A_%a.err

module load FastQC/0.11.9-Java-11

# Definimos 1 linea de filelist por tarea utilizando la variable de entorno SLURM_ARRAY_TASK_ID
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" data/filelist_R1.txt)
OUTDIR="results/fastqc_array_${SLURM_ARRAY_JOB_ID}"
echo $INPUT
mkdir -p "$OUTDIR"
mkdir -p "logs"

# Ejecutamos el comando
fastqc -o "$OUTDIR" "$INPUT"
echo "[INFO] Task ${SLURM_ARRAY_TASK_ID}  End:   $(date)"
```

Ahora ejecutaremos el array lanzando el comando sbatch:

```bash
sbatch fastqc_array.sbatch
```

Monitoriza la ejecución utilizando los comandos `squeue --me` y `sacct`

**PREGUNTA:**
- ¿Qué JOBID y TaskID has obtanido? ¿Serías capaz de encontrar sus correspondientes log/err y visualizar el contenido?

- ¿Cuál ha sido el tiempo y el MaxRSS de las taréas según `sacct`?
> Nota: puedes utilizar el comando: `sacct -j 22300 --format=JobID,JobName,State,Elapsed,MaxRSS`


# Best practices


Como habrás podido notar, es necesario saber cuántas muestras queremos procesar para poder definir correctamente el parámetro --array en la cabecera del script sbatch. Bueno, pues hay un truco. Para evitar estar contando el número de muestras y ponerlo manualmente, podemos recurrir a utilizar una combinación de comandos que nos permitan, automáticamente, poner la dimensión del array de acuerdo a la longitud del archivo `filelist`:

```bash
sbatch --array=1-$(wc -l < data/filelist_R1.txt) fastqc_array.sbatch
```
> Nota: Recordemos que la asignación de parámetros de Slurm podemos hacerla tanto dentro de la cabecera del script utilizando `#SBATCH --nombre_parametro` como a nivel de línea de comando como se muestra arriba.


TODO: Podemos terminar esto con una situacion en donde tengamos que encadenar 2 job array tipi FastQC >>> FastP
