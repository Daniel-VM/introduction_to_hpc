#!/bin/bash
#SBATCH --job-name=nf_bacass
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/10-scientific-workflows-nextflow
#SBATCH --partition=short_idx
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --output=logs/%x-%j.logs

# You need to modify the --chdir above to point to your ANALYSIS directory
module purge
module load Nextflow/24.04.2
module load singularity

mkdir -p 02-nextflow-bacass-results
nextflow run nf-core/bacass \
    -profile test,singularity \
    -c nextflow.config \
    --input samplesheet.csv \
    --outdir 02-nextflow-bacass-results \
    -resume
