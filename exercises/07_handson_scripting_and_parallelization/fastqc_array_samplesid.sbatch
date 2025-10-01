#!/bin/bash
#SBATCH --job-name=fastqc_from_ids
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

module load FastQC/0.11.9-Java-11

IDS_FILE="../samples_id.txt"
READS_DIR="../00-reads"

RESULTS_ROOT="03-fastqc-array-results"
mkdir -p "$RESULTS_ROOT"
OUTDIR="${RESULTS_ROOT}/fastqc_from_ids_${SLURM_ARRAY_JOB_ID}"
mkdir -p "$OUTDIR/logs"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$IDS_FILE")
R1="${READS_DIR}/${SAMPLE}_R1.fastq.gz"
R2="${READS_DIR}/${SAMPLE}_R2.fastq.gz"

fastqc -o "$OUTDIR" "$R1" "$R2"
echo "[INFO] Sample=${SAMPLE} R1=${R1} R2=${R2}"