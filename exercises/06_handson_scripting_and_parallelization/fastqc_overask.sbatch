#!/bin/bash
#SBATCH --job-name=fastqc_overask
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/06-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=2                <<<<
#SBATCH --mem=530G                       <<<<
#SBATCH --time=00:05:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Carga dependencias
module load FastQC/0.11.9-Java-11

# Info útil para el log
echo "[INFO] Node: $(hostname)"
echo "[INFO] Starting FastQC at $(date)"

mkdir -p 02-fastqc-array-results
fastqc data/sample_R1.fastq.gz data/sample_R2.fastq.gz -o 02-fastqc-array-results

echo "[INFO] Finished at $(date)"

