#!/bin/bash
#SBATCH --job-name=raxml_mpi
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/09-scripting-and-parallelization
#SBATCH --partition=short_idx
#SBATCH --nodes=2                 # <-- nº de nodos
#SBATCH --ntasks=8                # total procesos MPI
#SBATCH --ntasks-per-node=4       # <-- nº procesos MPI por nodo
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module load RAxML/8.2.12-gompi-2020a-hybrid-avx2

RUNNAME="ML_bootstrap"
mkdir -p 01-openmp-mpi-results
RESULTS_DIR="01-openmp-mpi-results/raxml_${SLURM_JOB_ID}"
mkdir -p "$RESULTS_DIR"

mpirun -np "$SLURM_NTASKS" raxmlHPC \
    -s data/datos.phy \
    -m GTRGAMMA \
    -p 12345 \
    -# 20 \
    -T "$SLURM_CPUS_PER_TASK" \
    -n "$RUNNAME" \
    -w "$RESULTS_DIR"
