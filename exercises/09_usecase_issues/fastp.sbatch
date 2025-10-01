#!/usr/bin/env bash
#SBATCH --job-name=fastp
#SBATCH --chdir="/scratch/hpc_course/20250929_HPC-COURSE-FASTP_profesor00/ANALYSIS/01-fastp"
#SBATCH --partition=short_idx
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --array=1-3
#SBATCH --output="logs/logs_%x-%j.log"

set -euo pipefail

module load singularity

sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "../samples_id.txt")
singularity exec --bind /scratch/hpc_course/20250929_HPC-COURSE-FASTP_profesor00/ ./fastp.img fastp -c 2 -i ../00-reads/${sample}_R1.fastq.gz -I ../00-reads/${sample}_R2.fastq.gz -o ../01-fastp/trimmed_${sample}_R1.fastq.gz -O ../01-fastp/trimmed_${sample}_R2.fastq.gz 