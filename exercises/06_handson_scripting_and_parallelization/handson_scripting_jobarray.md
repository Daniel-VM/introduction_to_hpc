# Curso Práctico de Iniciación al uso del Entorno de Alta Computación  
BU-ISCIII

## Práctica B: Job Arrays con Slurm

### Descripción
Vas a ejecutar el **mismo comando** (FastQC) sobre **varios FASTQ** usando un **Job Array** en Slurm. Aprenderás a **limitar concurrencia**, a **navegar por logs por tarea** y a interpretar el **histórico** del array.

### Notas importantes
- Un **array** es 1 job con N **tareas** (`task index`).
- Usa patrones `%A` (JobID del array) y `%a` (índice) en los logs para separarlos.

### Cheats
- Array: `#SBATCH --array=1-5%2` (1..5, máx. 2 concurrentes)
- Logs por tarea: `--output=logs/fastqc_%A_%a.out`

---
[TODO]: <add array file list example>

### 0) Preparación
Genera 5 FASTQ de juguete si no los tienes:
```bash
mkdir -p ~/hpc101/{raw,results,logs,scripts}
cd ~/hpc101
for i in {01..05}; do base64 /dev/urandom | head -c 200000 > raw/sample_${i}.fq; gzip -f raw/sample_${i}.fq; done
ls -lh raw/
```

---

### 1) Script `sbatch` del array
Guarda **`scripts/fastqc_array.sbatch`**:

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_array
#SBATCH --partition=short_idx
#SBATCH --array=1-5%3            # 5 tareas; máx. 3 simultáneas
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:07:00
#SBATCH --chdir=~/hpc101
#SBATCH --output=logs/fastqc_%A_%a.out
#SBATCH --error=logs/fastqc_%A_%a.err

module load fastqc/0.12.1

ID=$(printf "%02d" ${SLURM_ARRAY_TASK_ID})
INPUT="raw/sample_${ID}.fq.gz"
OUTDIR="results/fastqc_array"
mkdir -p "$OUTDIR"

echo "[$SLURM_ARRAY_TASK_ID] FastQC -> $INPUT"
fastqc -o "$OUTDIR" "$INPUT"
echo "[$SLURM_ARRAY_TASK_ID] Done."
```

---

### 2) Enviar y monitorizar
**Enviar:**
```bash
sbatch scripts/fastqc_array.sbatch
# Submitted batch job 22300
```

**squeue (ejemplo recortado):**
```bash
squeue --me
```
<details>
<summary>Salida ejemplo (10 líneas máx.)</summary>

```
JOBID     PARTITION  NAME          ST  TIME  NODES  NODELIST(REASON)
22300_1   short_idx  fastqc_array   R  0:03      1  ideafix02
22300_2   short_idx  fastqc_array   R  0:02      1  ideafix05
22300_3   short_idx  fastqc_array   R  0:01      1  ideafix03
22300_4   short_idx  fastqc_array  PD  0:00      1  (Priority)
22300_5   short_idx  fastqc_array  PD  0:00      1  (Resources)
```
</details>

**Detalles de una tarea:**
```bash
scontrol show job 22300_2 | egrep "ArrayJobId=|ArrayTaskId=|JobName=|NodeList=|RunTime=|Reason="
```

**Histórico del array:**
```bash
sacct -j 22300 --format=JobID,JobName,State,Elapsed,MaxRSS
```
<details>
<summary>Interpretación</summary>
Cada línea corresponde a una tarea del array: `22300_1`, `22300_2`, etc., con su estado y recursos.
</details>

---

### 3) Resultados
```bash
ls -lh results/fastqc_array/
# sample_01_fastqc.html ... sample_05_fastqc.html
tail -n +1 logs/fastqc_22300_*.out | sed -n '1,10p'
```

---

### 4) Preguntas de control
<details>
<summary>¿Cómo limito cuántas tareas corren a la vez?</summary>
Con `%N` en `--array`, p. ej. `--array=1-100%10` limita a 10 tareas simultáneas.
</details>

<details>
<summary>Si dos tareas escriben al mismo archivo, ¿qué puede pasar?</summary>
Condiciones de carrera y corrupción de salida. Usa nombres separados por `%a`/`$SLURM_ARRAY_TASK_ID`.
</details>
