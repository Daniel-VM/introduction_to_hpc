# Curso Práctico HPC - Scripting Sbatch
BU-ISCIII

## Práctica A: Scripting con Slurm (`sbatch`)

### Descripción
En esta práctica aprenderás a **enviar tu primer trabajo** al clúster con Slurm usando `sbatch`, y a **monitorizarlo** con `squeue`, `scontrol` y `sacct`. Trabajaremos con **FastQC** sobre un FASTQ de ejemplo.

### Notas importantes
- **Nunca** ejecutes trabajos pesados en el nodo de *login*; envíalos con `sbatch` al sistema de colas.
- Los nombres de módulos (`module load ...`) pueden variar según el HPC. Sustitúyelos si tu entorno usa otros.
- Crea una estructura de trabajo clara. Por ejemplo: `~/hpc101/{raw,results,logs,scripts}`.

### Cheats
- Enviar trabajo: `sbatch script.sbatch`
- Ver cola: `squeue --me`
- Ver detalles: `scontrol show job <jobid>`
- Histórico/consumo: `sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS,TotalCPU`

---
[TODO]: <may not be necesary>
### 0) Preparación de datos “dummy”
```bash
mkdir -p ~/hpc101/{raw,results,logs,scripts}
cd ~/hpc101
# 1 archivo FASTQ pequeño de ejemplo
base64 /dev/urandom | head -c 200000 > raw/sample_01.fq
gzip -f raw/sample_01.fq
ls -lh raw/
```

<details>
<summary>Salida esperada (ejemplo)</summary>

```
-rw-r--r-- 1 alumno alumnos 20K ... sample_01.fq.gz
```
</details>

---

### 1) Crear el script `sbatch`
Guarda el archivo **`scripts/fastqc_single.sbatch`** con este contenido:

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_single
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --chdir=~/hpc101
#SBATCH --output=logs/fastqc_%j.out
#SBATCH --error=logs/fastqc_%j.err

module load fastqc/0.12.1

INPUT="raw/sample_01.fq.gz"
OUTDIR="results/fastqc_single"
mkdir -p "$OUTDIR"

echo "Running FastQC on $INPUT"
fastqc -o "$OUTDIR" "$INPUT"
echo "Done."
```

> Da permisos de ejecución si quieres ejecutar localmente (no obligatorio para `sbatch`): `chmod +x scripts/fastqc_single.sbatch`

---

### 2) Enviar y monitorizar

**Enviar:**
```bash
sbatch scripts/fastqc_single.sbatch
# Submitted batch job 12345
```

**Ver en cola/ejecución:**
```bash
squeue --me
```
<details>
<summary>Salida ejemplo</summary>

```
JOBID  PARTITION  NAME            ST  TIME  NODES  NODELIST(REASON)
12345  short_idx  fastqc_single    R  0:12      1  ideafix03
```
</details>

**Detalles (si tarda o está PD):**
```bash
scontrol show job 12345 | egrep "JobName=|Partition=|NumCPUs=|NumNodes=|RunTime=|Reason=|AllocNode:"
```
<details>
<summary>Salida ejemplo</summary>

```
JobName=fastqc_single Partition=short_idx NumNodes=1 NumCPUs=1
RunTime=00:00:31 Reason=None AllocNode: ideafix03
```
</details>

**Histórico/consumo al terminar:**
```bash
sacct -j 12345 --format=JobID,JobName,Partition,State,Elapsed,MaxRSS,TotalCPU
```
<details>
<summary>Salida ejemplo</summary>

```
JobID   JobName        Partition  State      Elapsed   MaxRSS   TotalCPU
12345   fastqc_single  short_idx  COMPLETED  00:00:42   132M     00:00:41
```
</details>

---

### 3) Revisar resultados y logs
```bash
ls -lh results/fastqc_single/
# sample_01_fastqc.html  sample_01_fastqc.zip

tail -n +1 logs/fastqc_12345.out logs/fastqc_12345.err
```
<details>
<summary>¿Qué debería ver?</summary>

- El informe HTML y el ZIP de FastQC en `results/fastqc_single/`.
- En `logs/`, mensajes “Running FastQC…” y ningún error.
</details>

---

### 4) Preguntas de control
<details>
<summary>¿Qué pasa si no indico <code>--time</code>?</summary>
En algunos clústeres es **obligatorio**. Si no lo indicas, Slurm aplica un máximo por defecto que puede hacer que tu job tarde más en arrancar.
</details>

<details>
<summary>Si aparece <code>PD</code> mucho tiempo, ¿qué miro?</summary>
`scontrol show job <jobid>` y revisa `Reason=...` (prioridad, falta de recursos, límites de partición, etc.).
</details>
