  #!/usr/bin/env bash
  set -euo pipefail

  # Defaults
  BASE="/scratch/hpc_course"
  DAYS=2
  MODE="temps"      # temps|stale
  FORCE=0
  KEEP_PATTERNS=()   # Only applies to 'stale' (name patterns to keep)

  # Slurm: default configuration (overridable via environment variables)
  SRUN_PART="${SRUN_PART:-short_idx}"
  SRUN_TIME="${SRUN_TIME:-00:10:00}"
  SRUN_CPUS="${SRUN_CPUS:-1}"
  SRUN_MEM="${SRUN_MEM:-1G}"
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
Usage: $(basename "$0") [options]

  -m, --mode   Cleanup mode: temps (default) or stale
  -d, --days   Age in days (default: 2). With 0, no age filter (list all)
  -b, --base   Base directory (default: /scratch/hpc_course)
  -k, --keep   Name pattern to keep (repeatable; stale mode only)
  -f, --force  Perform deletion (default: dry-run)
  -h, --help   Show this help

Examples:
  # Old temporaries (dry-run)
  cleanup_scratch.sh -m temps -d 3

  # Top-level folders not modified in >2 days (dry-run)
  cleanup_scratch.sh -m stale

  # Actually delete, keeping folders matching "refs" or "important*"
  cleanup_scratch.sh -m stale -f -k refs -k 'important*'
EOF
  }

  # Colors (enabled for TTYs with >=8 colors)
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors) -ge 8 ]]; then
    BOLD="$(tput bold)"; RESET="$(tput sgr0)"
    RED="$(tput setaf 1)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; BLUE="$(tput setaf 4)"; MAGENTA="$(tput setaf 5)"; CYAN="$(tput setaf 6)"
  else
    BOLD=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
  fi

  # Simple flags parsing
  while [[ ${1:-} ]]; do
    case "$1" in
      -m|--mode) MODE="$2"; shift 2 ;;
      -d|--days) DAYS="$2"; shift 2 ;;
      -b|--base) BASE="$2"; shift 2 ;;
      -k|--keep) KEEP_PATTERNS+=("$2"); shift 2 ;;
      -f|--force) FORCE=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unrecognized option: $1"; usage; exit 1 ;;
    esac
  done

  # Safety: require BASE under /scratch
  if [[ "$BASE" != /scratch/* ]]; then
    echo "ERROR: BASE must be under /scratch (current: $BASE)" >&2
    exit 1
  fi

  # Helper: confirm and execute deletion
  confirm_and_delete() {
    local prompt="$1"; shift
    local del_cmd=("$@")

    if (( FORCE )); then
      read -rp "$prompt [y/N] " ans
      [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "Cancelled"; return 0; }
      "${del_cmd[@]}"
    else
      echo "(simulation mode: add --force to delete)"
    fi
  }

  # Build -mtime expression if DAYS>0; with DAYS=0 no age filter
  MTIME_EXPR=()
  if [[ ${DAYS} -gt 0 ]]; then
    MTIME_EXPR=( -mtime +"$DAYS" )
  fi
  # Human-readable age description
  if [[ ${DAYS} -gt 0 ]]; then
    AGE_DESC="older than ${DAYS} days"
  else
    AGE_DESC="without age filter"
  fi

  if [[ "$MODE" == "temps" ]]; then
    echo "${CYAN}[srun:${SRUN_PART}]${RESET} Searching temporary folders (${AGE_DESC}) in ${BASE} (work*, tmp*, .nextflow*) excluding .Trash-*, lost+found, .snapshot(s)"
    # Collect candidates (listing on compute node)
    mapfile -t CANDIDATES < <(
      srun "${SRUN_ARGS[@]}" \
        find "$BASE" -maxdepth 3 \
          \( -path '*/.Trash-*' -o -name 'lost+found' -o -path '*/.snapshot' -o -path '*/.snapshots' \) -prune -o \
          \( -name 'work' -o -name 'work_*' -o -name 'tmp' -o -name 'tmp_*' -o -name '.nextflow*' \) \
          -type d ${MTIME_EXPR[@]:-} -print | sort
    )

    if ((${#CANDIDATES[@]}==0)); then
      echo "${YELLOW}No temporary candidates to delete.${RESET}"
      exit 0
    fi

    # Permission precheck: writable+executable parent + subdirectories require w+x
    DELETABLE=()
    BLOCKED_REPORT=()
    for d in "${CANDIDATES[@]}"; do
      parent_dir="$(dirname "$d")"
      if ! srun "${SRUN_ARGS[@]}" bash -lc "test -w \"$parent_dir\" -a -x \"$parent_dir\""; then
        who=$(srun "${SRUN_ARGS[@]}" stat -c '%U:%G %A' "$parent_dir" 2>/dev/null || echo '?')
        BLOCKED_REPORT+=("$d|NON-WRITABLE PARENT: $parent_dir [$who]")
        continue
      fi

      first_block=$(srun "${SRUN_ARGS[@]}" bash -lc "find \"$d\" -type d \
        \( ! -writable -o ! -executable \) -printf '%M %u:%g %p\n' -quit" 2>/dev/null || true)
      if [[ -n "$first_block" ]]; then
        BLOCKED_REPORT+=("$d|INNER DIR WITHOUT PERMS: $first_block")
        continue
      fi

      immutable_path=$(srun "${SRUN_ARGS[@]}" bash -lc "command -v lsattr >/dev/null 2>&1 && lsattr -Rd \"$d\" 2>/dev/null | awk '/\si\s/ {sub(/^.*\s/ , \"\"); print; exit}' || true")
      if [[ -n "$immutable_path" ]]; then
        BLOCKED_REPORT+=("$d|IMMUTABLE ATTRIBUTE: $immutable_path (+i)")
        continue
      fi

      DELETABLE+=("$d")
    done

    echo "${BOLD}Candidates:${RESET} ${#CANDIDATES[@]}"
    echo "${GREEN}Deletable:${RESET} ${#DELETABLE[@]}"
    if ((${#DELETABLE[@]} > 0)); then
      printf '  %s\n' "${DELETABLE[@]}"
    fi
    echo "${YELLOW}Blocked:${RESET} ${#BLOCKED_REPORT[@]}"
    if ((${#BLOCKED_REPORT[@]} > 0)); then
      for line in "${BLOCKED_REPORT[@]}"; do
        IFS='|' read -r base reason <<<"$line"
        echo "  ${YELLOW}$base${RESET} -> $reason"
      done
      echo "${BLUE}Hint:${RESET} ask the indicated owner or support to adjust permissions/ACLs or delete the folder."
    fi

    if (( FORCE )); then
      read -rp "${RED}Delete the deletable directories?${RESET} [y/N] " ans
      [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "${YELLOW}Cancelled${RESET}"; exit 0; }
      if ((${#DELETABLE[@]} > 0)); then
        DEL_FILE="$(pwd)/.cleanup_scratch.to_delete.$USER.$$"
        printf '%s\0' "${DELETABLE[@]}" > "$DEL_FILE"
        echo "${CYAN}[srun:${SRUN_PART}]${RESET} Deleting ${#DELETABLE[@]} directories on compute node"
        srun "${SRUN_ARGS[@]}" bash -lc "xargs -0 rm -rf < \"$DEL_FILE\""
        rm -f -- "$DEL_FILE"
      else
        echo "${YELLOW}No deletable directories (insufficient permissions).${RESET}"
      fi
    else
      echo "${BLUE}(simulation mode: add --force to delete)${RESET}"
    fi

  elif [[ "$MODE" == "stale" ]]; then
    echo "${CYAN}[srun:${SRUN_PART}]${RESET} Searching top-level folders ${AGE_DESC} in ${BASE} (excluding .Trash-*, lost+found, .snapshot(s))"
    # Collect top-level candidates (listing on compute node)
    mapfile -t CANDIDATES < <(
      srun "${SRUN_ARGS[@]}" \
        find "$BASE" -mindepth 1 -maxdepth 1 \
          \( -name 'lost+found' -o -name '.snapshot' -o -name '.snapshots' -o -name '.Trash-*' \) -prune -o \
          -type d ${MTIME_EXPR[@]:-} -print | sort
    )

    # Filter by name patterns to keep
    TO_DELETE=()
    for d in "${CANDIDATES[@]:-}"; do
      name="$(basename "$d")"
      keep=0
      for pat in "${KEEP_PATTERNS[@]:-}"; do
        if [[ "$name" == $pat ]]; then
          keep=1; break
        fi
      done
      (( keep )) || TO_DELETE+=("$d")
    done

    if ((${#TO_DELETE[@]}==0)); then
      echo "${YELLOW}No candidate folders to delete.${RESET}"
      exit 0
    fi

    # Permission precheck: writable+executable parent + subdirectories require w+x
    DELETABLE=()
    BLOCKED_REPORT=()
    for d in "${TO_DELETE[@]}"; do
      parent_dir="$(dirname "$d")"
      if ! srun "${SRUN_ARGS[@]}" bash -lc "test -w \"$parent_dir\" -a -x \"$parent_dir\""; then
        who=$(srun "${SRUN_ARGS[@]}" stat -c '%U:%G %A' "$parent_dir" 2>/dev/null || echo '?')
        BLOCKED_REPORT+=("$d|NON-WRITABLE PARENT: $parent_dir [$who]")
        continue
      fi

      first_block=$(srun "${SRUN_ARGS[@]}" bash -lc "find \"$d\" -type d \
        \( ! -writable -o ! -executable \) -printf '%M %u:%g %p\n' -quit" 2>/dev/null || true)
      if [[ -n "$first_block" ]]; then
        BLOCKED_REPORT+=("$d|INNER DIR WITHOUT PERMS: $first_block")
        continue
      fi

      immutable_path=$(srun "${SRUN_ARGS[@]}" bash -lc "command -v lsattr >/dev/null 2>&1 && lsattr -Rd \"$d\" 2>/dev/null | awk '/\si\s/ {sub(/^.*\s/ , \"\"); print; exit}' || true")
      if [[ -n "$immutable_path" ]]; then
        BLOCKED_REPORT+=("$d|IMMUTABLE ATTRIBUTE: $immutable_path (+i)")
        continue
      fi

      DELETABLE+=("$d")
    done

    echo "${BOLD}Candidates:${RESET} ${#TO_DELETE[@]}"
    echo "${GREEN}Deletable:${RESET} ${#DELETABLE[@]}"
    if ((${#DELETABLE[@]} > 0)); then
      printf '  %s\n' "${DELETABLE[@]}"
    fi
    echo "${YELLOW}Blocked:${RESET} ${#BLOCKED_REPORT[@]}"
    if ((${#BLOCKED_REPORT[@]} > 0)); then
      for line in "${BLOCKED_REPORT[@]}"; do
        IFS='|' read -r base reason <<<"$line"
        echo "  ${YELLOW}$base${RESET} -> $reason"
      done
      echo "${BLUE}Hint:${RESET} ask the indicated owner or support to adjust permissions/ACLs or delete the folder."
    fi

    # Deletion
    if (( FORCE )); then
      read -rp "${RED}Delete the listed directories?${RESET} [y/N] " ans
      [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "${YELLOW}Cancelled${RESET}"; exit 0; }
      if ((${#DELETABLE[@]} > 0)); then
        # Generate list in a shared file under BASE to process on compute node
        DEL_FILE="$(pwd)/.cleanup_scratch.to_delete.$USER.$$"
        printf '%s\0' "${DELETABLE[@]}" > "$DEL_FILE"
        echo "${CYAN}[srun:${SRUN_PART}]${RESET} Deleting ${#DELETABLE[@]} directories on compute node"
        srun "${SRUN_ARGS[@]}" bash -lc "xargs -0 rm -rf < \"$DEL_FILE\""
        rm -f -- "$DEL_FILE"
      else
        echo "${YELLOW}No deletable directories (insufficient permissions).${RESET}"
      fi
    else
      echo "${BLUE}(simulation mode: add --force to delete)${RESET}"
    fi

  else
    echo "${RED}ERROR:${RESET} unrecognized mode: $MODE (use temps|stale)" >&2
    exit 1
  fi
