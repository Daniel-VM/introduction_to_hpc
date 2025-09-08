#!/bin/bash
#SBATCH --job-name=array_intro                  # Nombre del job (visible en la cola)
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/06-scripting-and-parallelization
#SBATCH --partition=short_idx                   # Partición/cola a usar
#SBATCH --array=1-9%3                           # Índices del array: 1..10, máx. 3 tareas simultáneas
#SBATCH --cpus-per-task=1                       # Hilos por tarea (FastQC usa 1 por defecto)
#SBATCH --mem=2G                                # RAM por tarea (ajusta si hace falta)
#SBATCH --time=00:05:00                         # Límite de tiempo por tarea
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Carga del software necesario (módulo de FastQC)
module load FastQC/0.11.9-Java-11

# Asegura que existe la carpeta de resultados
mkdir -p 02-fastqc-array-results
OUTDIR="02-fastqc-array-results/intro_${SLURM_ARRAY_JOB_ID}"
mkdir -p "$OUTDIR"

# Ejecuta FastQC sobre el par R1/R2 correspondiente al índice de la tarea
fastqc -o "$OUTDIR" "data/sample0${SLURM_ARRAY_TASK_ID}_R1.fastq.gz" "data/sample0${SLURM_ARRAY_TASK_ID}_R2.fastq.gz"

# Cada tarea del array procesa un par de archivos:
# data/sample${SLURM_ARRAY_TASK_ID}_R1.fastq.gz  y  data/sample${SLURM_ARRAY_TASK_ID}_R2.fastq.gz

echo "[INFO] JobID=${SLURM_ARRAY_JOBID}; Task=${SLURM_ARRAY_TASK_ID}; End=$(date)"

