  #!/usr/bin/env bash
  set -euo pipefail

  # Valores por defecto
  BASE="/scratch/hpc_course"
  DAYS=2
  MODE="temps"      # temps|stale
  FORCE=0
  KEEP_PATTERNS=()   # Solo aplica a modo 'stale' (patrones de nombre a conservar)

  # Slurm: configuración por defecto (sobre-escribible vía variables de entorno)
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
    # Permite pasar flags extra como cadena (p.ej. "--qos short --constraint NVME")
    read -r -a _EXTRA_ARR <<< "$SRUN_EXTRA"
    SRUN_ARGS+=("${_EXTRA_ARR[@]}")
  fi

  usage() {
    cat <<EOF
Uso: $(basename "$0") [opciones]

  -m, --mode   Modo de limpieza: temps (por defecto) o stale
  -d, --days   Días de antigüedad (por defecto: 2)
  -b, --base   Directorio base (por defecto: /scratch/hpc_course)
  -k, --keep   Patrón de nombre a conservar (repetible; solo en modo stale)
  -f, --force  Ejecuta el borrado (por defecto dry-run)
  -h, --help   Muestra esta ayuda

Ejemplos:
  # Temporales antiguos (dry-run)
  cleanup_scratch.sh -m temps -d 3

  # Carpetas a primer nivel sin tocar en >2 días (dry-run)
  cleanup_scratch.sh -m stale

  # Borrar de verdad, conservando carpetas cuyo nombre case con "refs" o "important*"
  cleanup_scratch.sh -m stale -f -k refs -k 'important*'
EOF
  }

  # Parseo simple de flags
  while [[ ${1:-} ]]; do
    case "$1" in
      -m|--mode) MODE="$2"; shift 2 ;;
      -d|--days) DAYS="$2"; shift 2 ;;
      -b|--base) BASE="$2"; shift 2 ;;
      -k|--keep) KEEP_PATTERNS+=("$2"); shift 2 ;;
      -f|--force) FORCE=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Opción no reconocida: $1"; usage; exit 1 ;;
    esac
  done

  # Salvaguarda: exigir ruta en /scratch
  if [[ "$BASE" != /scratch/* ]]; then
    echo "ERROR: BASE debe estar bajo /scratch (actual: $BASE)" >&2
    exit 1
  fi

  # Función auxiliar: confirma y ejecuta borrado
  confirm_and_delete() {
    local prompt="$1"; shift
    local del_cmd=("$@")

    if (( FORCE )); then
      read -rp "$prompt [y/N] " ans
      [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "Cancelado"; return 0; }
      "${del_cmd[@]}"
    else
      echo "(modo simulación: añade --force para borrar)"
    fi
  }

  if [[ "$MODE" == "temps" ]]; then
    echo "[srun:${SRUN_PART}] Buscando temporales (> ${DAYS} días) en ${BASE} (work*, tmp*, .nextflow*) excluyendo .Trash-*, lost+found, .snapshot(s)"
    # Listado en nodo de cómputo
    srun "${SRUN_ARGS[@]}" \
      find "$BASE" -maxdepth 3 \
        \( -path '*/.Trash-*' -o -name 'lost+found' -o -path '*/.snapshot' -o -path '*/.snapshots' \) -prune -o \
        \( -name 'work' -o -name 'work_*' -o -name 'tmp' -o -name 'tmp_*' -o -name '.nextflow*' \) \
        -type d -mtime +"$DAYS" -print

    # Borrado en nodo de cómputo
    confirm_and_delete "¿Eliminar los directorios listados?" \
      srun "${SRUN_ARGS[@]}" \
        find "$BASE" -maxdepth 3 \
          \( -path '*/.Trash-*' -o -name 'lost+found' -o -path '*/.snapshot' -o -path '*/.snapshots' \) -prune -o \
          \( -name 'work' -o -name 'work_*' -o -name 'tmp' -o -name 'tmp_*' -o -name '.nextflow*' \) \
          -type d -mtime +"$DAYS" -exec rm -rf {} +

  elif [[ "$MODE" == "stale" ]]; then
    echo "[srun:${SRUN_PART}] Buscando carpetas de primer nivel sin modificación en > ${DAYS} días en ${BASE} (excluyendo .Trash-*, lost+found, .snapshot(s))"
    # Recogemos candidatas de primer nivel (listado en nodo de cómputo)
    mapfile -t CANDIDATES < <(
      srun "${SRUN_ARGS[@]}" \
        find "$BASE" -mindepth 1 -maxdepth 1 \
          \( -name 'lost+found' -o -name '.snapshot' -o -name '.snapshots' -o -name '.Trash-*' \) -prune -o \
          -type d -mtime +"$DAYS" -print | sort
    )

    # Filtrado por patrones a conservar
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
      echo "No hay carpetas candidatas para borrar."
      exit 0
    fi

    printf '%s\n' "${TO_DELETE[@]}"

    # Borrado
    if (( FORCE )); then
      read -rp "¿Eliminar las carpetas listadas? [y/N] " ans
      [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "Cancelado"; exit 0; }
      # Generar lista en fichero compartido dentro de BASE para procesar en el nodo
      DEL_FILE="$BASE/.cleanup_scratch.to_delete.$USER.$$"
      printf '%s\0' "${TO_DELETE[@]}" > "$DEL_FILE"
      echo "[srun:${SRUN_PART}] Borrando ${#TO_DELETE[@]} carpetas en nodo de cómputo"
      srun "${SRUN_ARGS[@]}" bash -lc "xargs -0 rm -rf < \"$DEL_FILE\""
      rm -f -- "$DEL_FILE"
    else
      echo "(modo simulación: añade --force para borrar)"
    fi

  else
    echo "ERROR: modo no reconocido: $MODE (usa temps|stale)" >&2
    exit 1
  fi
