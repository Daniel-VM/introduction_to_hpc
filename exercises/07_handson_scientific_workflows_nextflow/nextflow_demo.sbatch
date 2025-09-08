#!/bin/bash
#SBATCH --job-name=nf_demo
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/07-scientific-workflows-nextflow
#SBATCH --partition=short_idx
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1                 # Recursos SOLO para el controlador de Nextflow
#SBATCH --mem=2G
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# Carga las dependencias para ejecutar Nextflow
module purge
module load Nextflow/25.04.6
module load singularity/3.7.1

mkdir -p 01-nextflow-demo-results
# Ejecuta nf-core/demo (workflow preparado)
# Importante: le indicamos que lea el archivo de configuración
nextflow run nf-core/demo \
  -profile test,singularity \
  -c nextflow.config \
  --outdir 01-nextflow-demo-results \
  -resume

