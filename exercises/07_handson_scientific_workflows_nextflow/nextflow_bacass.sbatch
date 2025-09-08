#!/bin/bash
#SBATCH --job-name=nf_bacass
#SBATCH --chdir=/scratch/hpc_course/HPC-COURSE-${USER}/ANALYSIS/07-scientific-workflows-nextflow
#SBATCH --partition=short_idx
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module purge
module load Nextflow/23.10.0
module load singularity/3.7.1

mkdir -p 02-nextflow-bacass-results
nextflow run nf-core/bacass \
    -profile test,singularity \
    -c nextflow.config \
    --input samplesheet.csv \
    --outdir 02-nextflow-bacass-results \
    -resume

