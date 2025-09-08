# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

BU-ISCIII

## Práctica 10: Casos Prácticos y Problemas conocidos

- [Curso Práctico de Iniciación al uso del Entorno de Alta Computación](#curso-práctico-de-iniciación-al-uso-del-entorno-de-alta-computación)
  - [Práctica 10: Casos Prácticos y Problemas conocidos](#práctica-10-casos-prácticos-y-problemas-conocidos)
    - [Descripción](#descripción)
    - [Ejercicios](#ejercicios)
      - [1. Reservar más recursos de los disponibles](#1-reservar-más-recursos-de-los-disponibles)
      - [2. Un trabajo utiliza más memoria de la solicitada](#2-un-trabajo-utiliza-más-memoria-de-la-solicitada)
        - [3. Load average](#3-load-average)
      - [4. Ganglia](#4-ganglia)
      - [5. Problemas de memoria](#5-problemas-de-memoria)
      - [6. Permisos de las distintas particiones](#6-permisos-de-las-distintas-particiones)
      - [7. Gestión de ficheros](#7-gestión-de-ficheros)
      - [9. Lanzar un pipeline de Nextflow: Ejecución, revisión e interpretación](#9-lanzar-un-pipeline-de-nextflow-ejecución-revisión-e-interpretación)
      - [10. Interpretación de logs](#10-interpretación-de-logs)

### Descripción

En esta práctica se trabajará con situaciones reales y problemas comunes que pueden aparecer en entornos de computación de alto rendimiento (HPC). El objetivo es aprender a identificar, diagnosticar y resolver incidencias, así como adoptar buenas prácticas en la gestión de recursos y ejecución de trabajos.

### Ejercicios

#### 1. Reservar más recursos de los disponibles

Vamos a intentar reservar más recursos de los disponibles para comprobar cómo el trabajo no entra en cola.

Para ver los recursos límite de los nodos de los que disponemos podemos ejecutar: `sinfo -o "%25N  %10c  %20m  %30G"`:

```bash
NODELIST                                            CPUS        MEMORY                GRES                           
ideafix[01-32]                                      32          385000+               local_scratch:880G
```

Para ver las la información de las particiones ejecutamos `sinfo`:

```bash
$ sinfo 
PARTITION  AVAIL  TIMELIMIT  NODES  STATE NODELIST
long_idx      up 10-00:00:0      7  drain ideafix[01,04,08,10-13]
long_idx      up 10-00:00:0      1    mix ideafix16
long_idx      up 10-00:00:0     24   idle ideafix[02-03,05-07,09,14-15,17-32]
middle_idx    up 2-00:00:00      7  drain ideafix[01,04,08,10-13]
middle_idx    up 2-00:00:00      1    mix ideafix16
middle_idx    up 2-00:00:00     24   idle ideafix[02-03,05-07,09,14-15,17-32]
short_idx*    up   12:00:00      7  drain ideafix[01,04,08,10-13]
short_idx*    up   12:00:00      1    mix ideafix16
short_idx*    up   12:00:00     24   idle ideafix[02-03,05-07,09,14-15,17-32]
tmp_idx       up   infinite      7  drain ideafix[01,04,08,10-13]
tmp_idx       up   infinite      1    mix ideafix16
tmp_idx       up   infinite     24   idle ideafix[02-03,05-07,09,14-15,17-32]
```

Podemos ver que tenemos un máximo de 32 cpus y un máximo de memoria de 385000Mb, además tenemos 4 tipos de colas, las long, con un tiempo límite de 10 días, las middle con un tiempo limite de 2 días, las short con un tiempo límite de 12h y las tmp que no tienen tiempo límite.

Para ver el estado de mis trabajos en la cola con información útil:

```bash
squeue -o "%7i %75j %8T %10u %5a %10P %8Q %5D %11l %8M %7C %7m %R"
```

Si lanzamos un trabajo reservando más recursos de los que disponemos ejecutando:

Más CPUs:

```bash
srun --cpus-per-task 33 --output MORE_CPUS.%j.log --job-name MORE_CPUS sleep 1
```

Observamos:

```bash
srun: error: CPU count per node can not be satisfied
srun: error: Unable to allocate resources: Requested node configuration is not available
```

Más memoria:

```bash
# Más memoria
srun --output MORE_MEM.%j.log --mem 3850000M --job-name MORE_MEM sleep 1
```

Observamos:

```bash
srun: error: Memory specification can not be satisfied
srun: error: Unable to allocate resources: Requested node configuration is not available
```

Más tiempo:

```bash
# Más memoria
srun --output MORE_TIME.%j.log --partition short_idx --time 2-00:00:00 --job-name MORE_TIME sleep 1 &
```

Observamos:

```bash
srun: Requested partition configuration not available now
srun: job 4787287 queued and waiting for resources
```

Pero si observamos nuestra cola veremos:

```bash
4787287 MORE_TIME                                                                   PENDING  s.varona   bi    short_idx  17928    1     2-00:00:00  0:00     1       4G      (PartitionTimeLimit)
```

Nos sale `PartitionTimeLimit` y nunca va a ejecutarse. Hay que matar el trabajo con `scancel JOB_ID`. El numero es el JOB_ID del gestor de colas.

Recomendaciones:

- Revisar siempre el numero máximo de recursos disponibles
- Reservar siempre lo que creamos que va a necesitar un proceso:
  - Reservar más recursos hará que tengamos menos prioridad en la cola
  - Reservar menos recursos hará que el proceso se pare y tengamos que volver a empezar

#### 2. Un trabajo utiliza más memoria de la solicitada

Vamos a ejecutar un trabajo que utilice más memoria de la solicitada para observar el comportamiento del sistema.

Ejecutamos:

```bash
srun --partition=short_idx --time=00:05:00 --mem=300M bash -lc 'python3 -c "import time; b=[]; [ (b.append(bytearray(5*1024*1024)), time.sleep(0.1)) for _ in range(200) ]"'
```

Observamos:

```bash
slurmstepd-ideafix03: error: Detected 1 oom_kill event in StepId=4833316.0. Some of the step tasks have been OOM Killed.
srun: error: ideafix03: task 0: Out Of Memory
```

Recomendaciones:

- Revisar siempre el numero máximo de recursos disponibles
- Reservar siempre lo que creamos que va a necesitar un proceso:
  - Reservar más recursos hará que tengamos menos prioridad en la cola
  - Reservar menos recursos hará que el proceso se pare y tengamos que volver a empezar

##### 3. Load average

Vamos a simular un **load average** elevado y analizar su impacto.

Ejecutamos:

```bash
# Reserva 4 CPUs pero lanza 24 procesos CPU-bound
# Nota: mantén N <= 32 para no saturar el nodo
srun --partition=short_idx --time=00:03:00 -c 4 --chdir="$HOME" --pty bash -lc '
  echo "CPUs reservadas: $SLURM_CPUS_PER_TASK"
  echo $(hostname)
  N=16
  # Lanzamos N procesos que consumen CPU
  for i in $(seq 1 $N); do yes > /dev/null & done
  # Observamos la carga durante ~90s para que suba el promedio de 1 min
  for i in {1..90}; do uptime; sleep 5; done
  # Limpiamos solo los hijos creados en este shell
  pkill -P $$ yes || true
'
```

Observamos:

```bash
# Salida orientativa de uptime (puede variar)
 14:22:17 up 10 days,  2:03,  1 user,  load average: 6.10, 3.00, 1.50
 14:22:47 up 10 days,  2:03,  1 user,  load average: 12.30, 5.80, 2.20
 14:23:17 up 10 days,  2:04,  1 user,  load average: 18.00, 9.00, 3.90
```

- Además podemos entrar al nodo de cómputo para ver el `load-average` y cómo se están ejecutando en `htop`

```bash
srun --partition=short_idx --nodelist=NODO_DE_COMPUTO --cpus-per-task=2 --mem=2G --time=00:30:00 --pty bash
```

Veríamos algo así:
![htop_loadaverage](htop_loadaverage.png)

Recomendaciones:

- Ajustar `--cpus-per-task (-c)` al paralelismo real del trabajo.
- Evitar oversubscription: no lanzar más hilos/procesos de los CPUs reservados.
- En OpenMP, alinear `OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK`.
- En MPI/Multithread, revisar mapeo/afinidad (p. ej. `--cpu-bind`, `--hint=nomultithread`).
- Si el `load average` sostenido supera los cores del nodo (p. ej. > 32), el nodo puede pasar a estado no disponible/`drain` por las políticas de salud. Avisar a soporte si ocurre.

Nota: el `load average` es un promedio exponencial (1/5/15 min). El valor de 1 minuto tarda decenas de segundos en reflejarse; por eso alargamos la observación a ~90s. Si necesitas superar 4 antes, incrementa `N` (siempre ≤ 32) o prolonga el tiempo de observación.

#### 4. Ganglia

Vamos a ver como se puede emplear [**Ganglia**](http://ganglia.isciii.es/) como herramienta de diagnóstico y monitorización. Ganglia es una herramienta de monitorización y diagnóstico de sistemas, muy usada en entornos de HPC (High Performance Computing) y clústeres. Ganglia recopila métricas de cada nodo del clúster como: Uso de CPU, memoria, red, carga del sistema (load average), espacio en disco, y otras métricas personalizadas. Se visualiza a través de una interfaz web con gráficos históricos y en tiempo real. Para qué sirve:

- Detectar sobrecarga en un nodo.
- Ver tendencias de consumo de recursos.
- Diagnosticar cuellos de botella.
- Comprobar si los trabajos se están ejecutando correctamente o si saturan el sistema.

Observamos:

```bash

```

Recomendaciones:

#### 5. Problemas de memoria

En ocasiones cuando estemos trabajando en el HPC podemos observar este error `No space left on device`. Este se debe a que la memoria de alguna de las particiones que estamos empleando está llena. Vamos a revisar el tamaño de las particiones para gestionar el almacenamiento de forma eficiente.

Ejecutamos:

```bash
df -h
```

Observamos:

```bash
Filesystem                          Size  Used Avail Use% Mounted on
tmpfs                                16G  4.4G   12G  29% /
devtmpfs                             16G     0   16G   0% /dev
tmpfs                                16G  571M   15G   4% /dev/shm
tmpfs                                16G  746M   15G   5% /run
tmpfs                                16G     0   16G   0% /sys/fs/cgroup
IP:/HPC_UI_ACTIVE                    60T   54T  6.7T  89% /data
IP:/HPC_Home                        200G  149G   52G  75% /home
IP:/HPC_UCCT_BI_ACTIVE               30T   19T   12T  62% /data/courses/hpc_course
IP:/HPC_Scratch                     7.4T  7.4T  0.0T 100% /scratch
//IP7/hpc-bioinfo/                  1.0T  713G  312G  70% /data/courses/hpc_course/sftp
IP:/HPC_Soft                        350G  295G   56G  85% /soft
IP:/HPC_UCCT_ME_ARCHIVED             42T   38T  4.2T  91% /archived/ucct/me
IP:/HPC_UCCT_BI_ARCHIVED             50T   37T   14T  74% /archived/ucct/bi
IP:/HPC_Opt                         100G   15G   86G  15% /opt
IP:/NGS_Data_FastQ_Active            15T  8.0T  7.1T  54% /srv/fastq_repo
//IP7/hpc-genvigies/                1.0T  436G  589G  43% /sftp/genvigies
tmpfs                               3.1G     0  3.1G   0% /run/user/3009
tmpfs                               3.1G     0  3.1G   0% /run/user/3014
tmpfs                               3.1G     0  3.1G   0% /run/user/3015
tmpfs                               3.1G     0  3.1G   0% /run/user/3030
tmpfs                               3.1G     0  3.1G   0% /run/user/3022
tmpfs                               3.1G     0  3.1G   0% /run/user/3029
tmpfs                               3.1G     0  3.1G   0% /run/user/1218
tmpfs                               3.1G     0  3.1G   0% /run/user/1311
tmpfs                               3.1G     0  3.1G   0% /run/user/1000
tmpfs                               3.1G     0  3.1G   0% /run/user/3006
tmpfs                               3.1G     0  3.1G   0% /run/user/3013
tmpfs                               3.1G     0  3.1G   0% /run/user/1212
tmpfs                               3.1G     0  3.1G   0% /run/user/3039
tmpfs                               3.1G     0  3.1G   0% /run/user/3017
```

Aquí podemos ver que el uso de `/scratch` es del 100% y que no queda espacio libre en la memoria. `/scratch` tiene 7Tb de memoria para compartir entre todos los usuarios del HPC. No es una unidad de almacenamiento sino una unidad de cómputo, por lo que no debe permanecer nada ahí que no se vaya a computar a corto plazo (24 horas) ya que el almacenamiento es limitado.

En estos casos habría que observar qué carpetas son las que más especio ocupan para borrarlas lo antes posible. Esto se realiza con el siguiente comando:

```bash
du -sh ./*
```

Observamos:

```bash
4.0K    ./00-reads
81G     ./20250728_ANALYSIS02_METAGENOMIC_HUMAN
78G     ./20250728_ANALYSIS05_TAXPROFILER
4.0K    ./lablog_taxprofiler
40K     ./lablog_viralrecon
0       ./samples_id.txt
0       ./samples_ref.txt
```

La primera columna es el espacio (en K, M o G) que ocupa un archivo o carpeta y la segunda es el nombre del archivo o carpeta. Es este ejemplo concreto tendríamos que revisar las carpetas `./20250728_ANALYSIS02_METAGENOMIC_HUMAN` y `./20250728_ANALYSIS05_TAXPROFILER` para ver si alguno de los archivos que tienen dentro se puede borrar. Esto solo en el caso de que siga necesitando computar con estos archivos; si no, habría que copiar la carpeta a una unidad de almacenamiento a largo plazo y borrarlo de `/scratch/hpc_course`.

Recomendaciones:

- Siempre que hayamos terminado un análisis, eliminar las carpetas temporales (work, tmp...)
- Evitar almacenar archivos grandes redundantes (.bam, .sorted.bam, .sorted.trimmed.bam...)
- Siempre que hayamos terminado con una carpeta, copiarla a una unidad de almacenamiento a largo plazo.

#### 6. Permisos de las distintas particiones

El área `/scratch` está pensada para E/S rápida en los nodos de cómputo. En muchos clústeres se monta como solo lectura en el nodo de acceso (login), por lo que desde login no podrás crear archivos bajo `/scratch`. Sin embargo, una vez dentro de un nodo de cómputo, sí podrás escribir en tu subcarpeta de trabajo (por ejemplo `/scratch/hpc_course`).

Comprobemos ambos casos usando la ruta `/scratch/hpc_course`:

1. Intento de escritura desde el nodo de acceso (login):

```bash
cd /scratch/hpc_course
touch test_file.txt
```

Observamos un error (solo lectura o permisos):

```bash
touch: cannot touch 'test_file.txt': Read-only file system
```

2. Escritura desde un nodo de cómputo (sesión interactiva):

```bash
srun --partition=short_idx --cpus-per-task=2 --mem=2G --time=00:30:00 --pty bash
hostname
cd /scratch/hpc_course
touch test_file.txt
ls -l test_file.txt
```

Observamos que ahora el fichero se crea correctamente en el nodo de cómputo. Para dejarlo limpio, podemos borrar el fichero y salir:

```bash
rm -f /scratch/hpc_course/test_file.txt
exit
```

Recomendaciones:

- Trabajar en `/scratch` solo desde nodos de cómputo (interactivos o de jobs).
- Si lanzas trabajos por lotes, usa `--chdir /scratch/hpc_course` y rutas absolutas o relativas a esa carpeta.
- No uses `/scratch` como almacenamiento a largo plazo; limpia archivos temporales al terminar.

#### 7. Gestión de ficheros

En este ejercicio vamos a crear scripts y alias reutilizables para trabajar de forma cómoda y segura con `/scratch/hpc_course` y `/data/courses/hpc_course`.

Scripts y alias propuestos (guardar en `~/bin` o añadir a `~/.bashrc`):

- Script `hpc_cp.sh`: copiar entre scratch y data con rsync

  Guardar como `~/bin/hpc_cp.sh` y dar permisos: `chmod +x ~/bin/hpc_cp.sh`.

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail

  DATA_BASE="/data/courses/hpc_course"
  SCRATCH_BASE="/scratch/hpc_course"

  usage() {
    echo "Uso: $(basename "$0") [scratch->data|data->scratch] <ruta_relativa> [--dry-run]"
    echo "Ej.: $(basename "$0") scratch->data resultados/run42/"
    exit 1
  }

  MODE="${1:-}"; REL_PATH="${2:-}"; OPT="${3:-}"
  [[ -z "$MODE" || -z "$REL_PATH" ]] && usage

  RSYNC_OPTS=(-avh --info=stats2 --progress)
  [[ "$OPT" == "--dry-run" ]] && RSYNC_OPTS+=(--dry-run)

  case "$MODE" in
    scratch->data)
      src="${SCRATCH_BASE}/${REL_PATH}"; dst="${DATA_BASE}/${REL_PATH}" ;;
    data->scratch)
      src="${DATA_BASE}/${REL_PATH}";   dst="${SCRATCH_BASE}/${REL_PATH}" ;;
    *) usage ;;
  esac

  mkdir -p "$(dirname "$dst")"
  echo "Sincronizando: $src -> $dst"
  rsync "${RSYNC_OPTS[@]}" "$src" "$dst"
  ```

  - Ejemplos:
    - `hpc_cp.sh scratch->data folder/` copia `/scratch/hpc_course/run01/` a `/data/courses/hpc_course/run01/`.
    - `hpc_cp.sh data->scratch folder/` copia `/data/courses/hpc_course/refs/` a `/scratch/hpc_course/refs/`.

- Alias para colas: `sq` (squeue) y `si` (sinfo)

  Añadir al final de `~/.bashrc` y recargar con `source ~/.bashrc`:

  ```bash
  # Formatos "completos" usados en la práctica
  alias sq='squeue -o "%7i %75j %8T %10u %5a %10P %8Q %5D %11l %8M %7C %7m %R" -u $USER'
  alias si='sinfo  -o "%20P %5D %14F %8z %10m %10d %11l %16f %N"'
  ```

- Función `scratch()`: abre sesión interactiva ya colocada en `/scratch/hpc_course`

  ```bash
  scratch() {
    srun --partition=short_idx \
         --time=00:30:00 \
         --cpus-per-task=2 \
         --mem=4G \
         --chdir /scratch/hpc_course \
         --pty bash -l
  }
  ```

- Script `cleanup_scratch.sh`: limpieza segura con dos modos

  - Modo `temps`: busca temporales (p. ej. `work*`, `tmp*`, `.nextflow*`) antiguos.
  - Modo `stale`: busca carpetas de primer nivel en `BASE` sin modificación reciente.

  Por defecto solo muestra lo que borraría (modo "dry-run"). Para ejecutar el borrado, añade `--force`.

  Guardar como `~/bin/cleanup_scratch.sh` y dar permisos: `chmod +x ~/bin/cleanup_scratch.sh`.

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail

  # Valores por defecto
  BASE="/scratch/hpc_course"
  DAYS=2
  MODE="temps"      # temps|stale
  FORCE=0
  KEEP_PATTERNS=()   # Solo aplica a modo 'stale' (patrones de nombre a conservar)

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
    echo "Buscando temporales (> ${DAYS} días) en ${BASE} (work*, tmp*, .nextflow*)"
    # Listado
    find "$BASE" -maxdepth 3 \
      \( -name "work" -o -name "work_*" -o -name "tmp" -o -name "tmp_*" -o -name ".nextflow*" \) \
      -type d -mtime +"$DAYS" -print

    # Borrado
    confirm_and_delete "¿Eliminar los directorios listados?" \
      find "$BASE" -maxdepth 3 \
        \( -name "work" -o -name "work_*" -o -name "tmp" -o -name "tmp_*" -o -name ".nextflow*" \) \
        -type d -mtime +"$DAYS" -exec rm -rf {} +

  elif [[ "$MODE" == "stale" ]]; then
    echo "Buscando carpetas de primer nivel sin modificación en > ${DAYS} días en ${BASE}"
    # Recogemos candidatas de primer nivel
    mapfile -t CANDIDATES < <(find "$BASE" -mindepth 1 -maxdepth 1 -type d -mtime +"$DAYS" -print | sort)

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
      rm -rf -- "${TO_DELETE[@]}"
    else
      echo "(modo simulación: añade --force para borrar)"
    fi

  else
    echo "ERROR: modo no reconocido: $MODE (usa temps|stale)" >&2
    exit 1
  fi
  ```

- Plantilla mínima de job SLURM (batch)

  Guardar como `job.slurm` en tu proyecto y ajustar recursos según necesidad.

  ```bash
  #!/usr/bin/env bash
  #SBATCH --job-name=EJEMPLO
  #SBATCH --partition=short_idx
  #SBATCH --time=00:30:00
  #SBATCH --cpus-per-task=2
  #SBATCH --mem=4G
  #SBATCH --chdir=/scratch/hpc_course
  #SBATCH --output=logs/%x.%j.out
  #SBATCH --error=logs/%x.%j.err

  set -euo pipefail
  mkdir -p logs
  echo "Nodo: $(hostname)"; date

  # Cargar módulos si procede
  # module load singularity

  # Trabajo principal
  srun bash -lc 'echo "Hola SLURM"; sleep 10'
  ```

Recomendaciones:

- Usar rutas consistentes entre scratch y data para facilitar sincronización.
- Mantener `logs/` en data y solo temporales/pesados en scratch.
- Automatizar con `rsync` y revisar siempre en modo `--dry-run` antes de borrar.

#### 9. Lanzar un pipeline de Nextflow: Ejecución, revisión e interpretación

En este ejercicio vamos a ejecutar el pipeline de [**nf-core/bacass**](https://github.com/nf-core/bacass) indicando todos los pasos a seguir:

- Crear la carpeta de trabajo
- Preparar los archivos necesarios
- Ejecutar el pipeline
- Revisar los logs y resultados
- Revisar la carpeta `work`

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

#### 10. Interpretación de logs

Vamos a interpretar algunos logs generados por el sistema y por los trabajos

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:
