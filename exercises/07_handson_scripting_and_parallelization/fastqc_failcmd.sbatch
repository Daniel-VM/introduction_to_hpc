#!/bin/bash
#SBATCH --job-name=fastqc_fail
#SBATCH --chdir=/scratch/hpc_course/*HPC-COURSE_${USER}/ANALYSIS/07-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "[INFO] Node: $(hostname)"
echo "[INFO] Starting FastQC at $(date)"

mkdir -p 01-fastqc-demo-results
fastp \
  /scratch/hpc_course/*HPC-COURSE_${USER}/ANALYSIS/00-reads/virus1_R1.fastq.gz \
  /scratch/hpc_course/*HPC-COURSE_${USER}/ANALYSIS/00-reads/virus1_R2.fastq.gz \
  -o 01-fastqc-demo-results

echo "[INFO] Finished at $(date)"