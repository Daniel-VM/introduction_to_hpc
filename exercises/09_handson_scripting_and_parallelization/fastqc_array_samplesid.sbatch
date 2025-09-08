#!/bin/bash
#SBATCH --job-name=fastqc_from_ids
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/09-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --array=1-10                    # Ajusta el rango o pásalo al enviar con --array
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module load FastQC/0.11.9-Java-11

# Rutas de entrada y ficheros auxiliares
IDS_FILE="/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/samples_id.txt"
READS_DIR="/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/00-reads"

# Carpeta de resultados por ejecución del array
RESULTS_ROOT="02-fastqc-array-results"
mkdir -p "$RESULTS_ROOT"
OUTDIR="${RESULTS_ROOT}/fastqc_from_ids_${SLURM_ARRAY_JOB_ID}"
mkdir -p "$OUTDIR/logs"

# Redirige stdout/err a la carpeta de logs por tarea del array
LOG_SUFFIX="${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}"
exec >"${OUTDIR}/logs/${SLURM_JOB_NAME}-${LOG_SUFFIX}.out" 2>"${OUTDIR}/logs/${SLURM_JOB_NAME}-${LOG_SUFFIX}.err"

# Selecciona la muestra correspondiente a esta tarea
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$IDS_FILE")

R1="${READS_DIR}/${SAMPLE}_R1.fastq.gz"
R2="${READS_DIR}/${SAMPLE}_R2.fastq.gz"

# Ejecuta FastQC para el par R1/R2
fastqc -o "$OUTDIR" "$R1" "$R2"

echo "[INFO] Sample=${SAMPLE} R1=${R1} R2=${R2}"
echo "[INFO] Task ${SLURM_ARRAY_TASK_ID} End: $(date)"

