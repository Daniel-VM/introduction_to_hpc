#!/bin/bash
#SBATCH --job-name=fastqc_array
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/09-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --array=1-10
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module load FastQC/0.11.9-Java-11

mkdir -p 02-fastqc-array-results
OUTDIR="02-fastqc-array-results/fastqc_array_${SLURM_ARRAY_JOB_ID}"
mkdir -p "$OUTDIR/logs"

# Redirige stdout/err a la carpeta de logs de este OUTDIR
LOG_SUFFIX="${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}"
exec >"${OUTDIR}/logs/${SLURM_JOB_NAME}-${LOG_SUFFIX}.out" 2>"${OUTDIR}/logs/${SLURM_JOB_NAME}-${LOG_SUFFIX}.err"

# Definimos 1 linea de filelist por tarea utilizando la variable de entorno SLURM_ARRAY_TASK_ID
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" data/filelist_R1.txt)

echo "$INPUT"

# Ejecutamos el comando
fastqc -o "$OUTDIR" "$INPUT"

echo "[INFO] Task ${SLURM_ARRAY_TASK_ID}  End:   $(date)"
