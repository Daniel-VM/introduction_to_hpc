# HandsOn: Envío de trabajos con `sbatch` (Slurm)

## Descripción

En esta práctica aprenderás a crear un script `sbatch` y a enviarlo al sistema de colas del HPC. Además, **monitorizarás** la ejecución con Slurm y diagnosticarás el resultado usando los ficheros de log (`slurm-<jobid>.out/.err`) y los comandos `squeue`, `scontrol` y `sacct`. Partiremos de un **script base** que ejecuta **FastQC** sobre dos FASTQ pequeños y crearemos **3 variantes** para observar: (1) ejecución correcta, (2) fallo del comando por entrada inexistente y (3) trabajo atascado en **PD** por pedir **recursos imposibles**.

## Notas importantes

* **No** ejecutes trabajos pesados en el nodo de login. Usa siempre `sbatch` (o `srun`).
* Ajusta `--time`, `--cpus-per-task` y `--mem` a lo **mínimo razonable**.
* Los **JOBID** cambian en cada envío; **toma nota** del número que te devuelve `sbatch`.
* Si tu entorno no tiene FastQC o los FASTQ de prueba, pide al docente la ruta de datos del curso.
* Comandos clave: `sbatch`, `squeue`, `scontrol show job <jobid>`, `sacct -j <jobid> -o ...`, `less`, `tail -n +1`.

---


TODOOOOOO: PARAMETRIXACIÓN EN CLI DE SBATCH
## Script base

Guarda como **`fastqc_demo.sbatch`**:

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_demo
#SBATCH --chdir=/scratch/bi/TESTS/daniel_vm/intro_to_hpc
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

# Carga dependencias
module load FastQC/0.11.9-Java-11

# Info útil para el log
echo "[INFO] Node: $(hostname)"
echo "[INFO] Starting FastQC at $(date)"

mkdir -p fastqc_results
fastqc data/sample_R1.fastq.gz data/sample_R2.fastq.gz -o fastqc_results

echo "[INFO] Finished at $(date)"
```

---

## Ejercicio 1

### Objetivo

Ejecutar el script tal cual, comprobar el nodo, los logs y el estado final.

### Pasos

1. Enviar el trabajo

```bash
$ sbatch fastqc_demo.sbatch
Submitted batch job 10421
```

2. Monitorizar en cola

```bash
$ squeue --me
$ squeue -j 10421
```

3. Ver detalles (nodo, recursos, razón si está en PD)

```bash
$ scontrol show job 10421 | grep 'JobName\|NumNodes\|NumCPUs\|TRES\|Nodes\|Reason\|Submit\|Start\|TimeLimit'
```

4. Al finalizar, revisar histórico y uso

```bash
$ sacct -j 10421 -o JobID,State,Elapsed,MaxRSS,TotalCPU,ExitCode
```

5. Leer logs

```bash
$ less slurm-10421.out
$ less slurm-10421.err
```

**PREGUNTA:**
¿En qué **nodo** se ejecutó el trabajo y cuánto **tiempo** tardó? ¿Qué **pico de RAM** muestra `MaxRSS` y qué **estado final** aparece en `sacct`?

> Nota (estados típicos): **PD** (PENDING), **R** (RUNNING), **CG** (COMPLETING), **CD** (COMPLETED), **F** (FAILED), **TO** (TIMEOUT), **CA** (CANCELLED), **NF** (NODE\_FAIL).

---

## Ejercicio 2 — **Fallo** del comando (archivo inexistente)

### Objetivo

Forzar un error de ejecución para explorar el `stderr` y el `ExitCode`.

Vamos a modificar el script fastqc_demo.sbatch. En esta ocasión, actualzaremos el comando que vamos a lanzar y llamaremos al archivo `fastqc_failcmd.sbatch`:


```bash
#!/bin/bash
#SBATCH --job-name=fastqc_demo
#SBATCH --chdir=/scratch/bi/TESTS/daniel_vm/intro_to_hpc
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

# Carga dependencias
module load FastQC/0.11.9-Java-11

# Info útil para el log
echo "[INFO] Node: $(hostname)"
echo "[INFO] Starting FastQC at $(date)"

mkdir -p fastqc_results
fastp data/sample_R1.fastq.gz data/sample_R2.fastq.gz -o fastqc_results # <<<<  Comando modificado

echo "[INFO] Finished at $(date)"
```

### Envío y análisis

```bash
$ sbatch fastqc_failcmd.sbatch
Submitted batch job 10437

$ squeue -j 10437
# (Suele pasar muy rápido a estado final)

# Histórico y código de salida:
$ sacct -j 10437 -o JobID,State,Elapsed,ExitCode

# Logs: el .err debe contener el mensaje de error del comando
$ tail slurm-10437.err
```

*Ejemplo orientativo de líneas en `.err` (puede variar):*

```
Failed to execute: command not found
```

**PREGUNTA:**
¿Qué **mensaje de error** aparece en `slurm-<jobid>.err` y qué **ExitCode** ves en `sacct`? ¿Qué **cambio mínimo** haría que el trabajo funcione?

---

## Ejercicio 3 — **Pendiente** por recursos imposibles (over-ask)

### Objetivo

A continuación, vamso a explorar qué sucede cuando definimos una configuración de la cabecera SBATCH errónea o no compatible con las características del nodo del HPC en donde vamos a ejecutar las tareas. Este escenario es común cuando soliciamos más recursos de los disponibles. Como consecuencia, al ejecutar la tarea podemos observar que permanece en estado **PD (Pending)** (columna: **NODELIST(REASON)** del comando `squeue`). 


Vamos a preparar una réplica del ejemplo con el que venimos trabajando llamado `fastqc_overask.sbatch`: 

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_demo
#SBATCH --chdir=/scratch/bi/TESTS/daniel_vm/intro_to_hpc
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=2                <<<<
#SBATCH --mem=530G                       <<<<
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

# Carga dependencias
module load FastQC/0.11.9-Java-11

# Info útil para el log
echo "[INFO] Node: $(hostname)"
echo "[INFO] Starting FastQC at $(date)"

mkdir -p fastqc_results
fastqc data/sample_R1.fastq.gz data/sample_R2.fastq.gz -o fastqc_results

echo "[INFO] Finished at $(date)"
```

### Envío y análisis

```bash
$ sbatch fastqc_overask.sbatch
Submitted batch job 10458

# Ver la cola y la razón de espera (formato con REASON)
$ squeue -j 10458 -o "%.18i %.10P %.20j %.2t %.10M %.6D %R"

# Detalle completo del motivo de espera:
$ scontrol show job 10458 | egrep 'Reason|Req|MinCPUs|TRES|Nodes|Partition|QOS'
```

*Razones típicas (pueden variar):* `Resources`, `ReqNodeNotAvail`, `QOSMaxCpuPerJobLimit`, `PartitionNodeLimit`, `Priority`.

**PREGUNTA:**
¿Qué **Reason** muestra el trabajo en **PD**? ¿Qué **parámetro(s)** ajustarías (y a qué orden de magnitud) para que **empiece**?
