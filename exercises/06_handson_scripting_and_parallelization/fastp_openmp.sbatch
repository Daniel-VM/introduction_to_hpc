#!/bin/bash
#SBATCH --job-name=fastp_omp
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/06-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=4           # <- nº hilos/threads OpenMP
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module load fastp/0.20.0-GCC-8.3.0
mkdir -p 01-openmp-mpi-results

# Setup de variables
R1=data/sample01_R1.fastq.gz
R2=data/sample01_R2.fastq.gz
OUTR1=01-openmp-mpi-results/sample01.clean.R1.fastq.gz
OUTR2=01-openmp-mpi-results/sample01.clean.R2.fastq.gz

# Ejecutamos el comando
fastp -i "$R1" -I "$R2" -o "$OUTR1" -O "$OUTR2" \
    --thread="$SLURM_CPUS_PER_TASK" \
    --detect_adapter_for_pe

