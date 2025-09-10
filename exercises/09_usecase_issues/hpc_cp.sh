#!/usr/bin/env bash
set -euo pipefail

# Defaults (overridable via flags)
DATA_BASE="/data/courses/hpc_course"
SCRATCH_BASE="/scratch/hpc_course"
DRY_RUN=0

# Slurm defaults (overridable via environment variables)
SRUN_PART="${SRUN_PART:-short_idx}"
SRUN_TIME="${SRUN_TIME:-00:30:00}"
SRUN_CPUS="${SRUN_CPUS:-1}"
SRUN_MEM="${SRUN_MEM:-2G}"
SRUN_ACCOUNT="${SRUN_ACCOUNT:-}"
SRUN_EXTRA="${SRUN_EXTRA:-}"
SRUN_ARGS=(
  --partition="$SRUN_PART"
  --time="$SRUN_TIME"
  --cpus-per-task="$SRUN_CPUS"
  --mem="$SRUN_MEM"
  --quiet
)
if [[ -n "$SRUN_ACCOUNT" ]]; then SRUN_ARGS+=(--account="$SRUN_ACCOUNT"); fi
if [[ -n "$SRUN_EXTRA" ]]; then
  # Allow passing extra flags as string (e.g. "--qos short --constraint NVME")
  read -r -a _EXTRA_ARR <<< "$SRUN_EXTRA"
  SRUN_ARGS+=("${_EXTRA_ARR[@]}")
fi

usage() {
  cat <<EOF
Usage: $(basename "$0") [scratch->data|data->scratch] <relative_path> [options]

Options:
  --data-base PATH     Base path for data (default: $DATA_BASE)
  --scratch-base PATH  Base path for scratch (default: $SCRATCH_BASE)
  --dry-run            Pass --dry-run to rsync
  -h, --help           Show this help

Notes:
  - The copy runs on a compute node via srun to respect scratch policies.
  - The destination parent directory is created on the compute node.

Examples:
  # Copy a run from scratch to data
  $(basename "$0") scratch->data results/run42/ \
    --data-base /data/courses/hpc_course --scratch-base /scratch/hpc_course

  # Copy references from data to scratch (dry-run)
  $(basename "$0") data->scratch refs/ --dry-run
EOF
}

# Parse positional args (mode + relative path), and options
MODE="${1:-}"; REL_PATH="${2:-}"; shift "$(( $#>0 ? 2 : 0 ))" || true

while [[ ${1:-} ]]; do
  case "$1" in
    --data-base) DATA_BASE="$2"; shift 2 ;;
    --scratch-base) SCRATCH_BASE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unrecognized option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "${MODE}" || -z "${REL_PATH}" ]]; then
  usage; exit 1
fi

# Normalize relative path: preserve trailing slash semantics
SRC=""; DST=""
case "$MODE" in
  "scratch->data")
    SRC="${SCRATCH_BASE}/${REL_PATH}"
    DST="${DATA_BASE}/"
    ;;
  "data->scratch")
    SRC="${DATA_BASE}/${REL_PATH}"
    DST="${SCRATCH_BASE}"
    ;;
  *) echo "ERROR: mode must be scratch->data or data->scratch" >&2; exit 1 ;;
esac

# Safety: require scratch base under /scratch
if [[ "$DST" == /scratch/* || "$SRC" == /scratch/* ]]; then
  : # looks fine
fi

# Build rsync options
RSYNC_OPTS=( -avh --info=stats2 --progress )
if (( DRY_RUN )); then RSYNC_OPTS+=( --dry-run ); fi

echo "Mode: $MODE"
echo "Source:      $SRC"
echo "Destination: $DST"

# Run mkdir and rsync on a compute node
PARENT_DIR=$(dirname "$DST")
echo "Creating destination parent on compute node: $PARENT_DIR"
srun "${SRUN_ARGS[@]}" mkdir -p -- "$PARENT_DIR"

echo "Running rsync on compute node..."
srun "${SRUN_ARGS[@]}" rsync "${RSYNC_OPTS[@]}" -- "$SRC" "$DST"

echo "Done."
