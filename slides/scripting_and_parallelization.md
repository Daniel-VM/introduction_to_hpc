# Talk 6: Scripting and parallelization

## Scripting

La idea principal de esta parte del curso es aprender a **delegar trabajo** en el clúster. En lugar de ejecutar cada comando a mano, escribimos un pequeño guion que Slurm interpreta y ejecuta por nosotros. Así podemos irnos a casa y dejar que los ordenadores hagan su trabajo.

### SBATCH: la puerta de entrada

#### ¿Qué es `sbatch`?

- Es la orden de **Slurm** que envía un script a la cola del clúster para que se ejecute cuando haya recursos disponibles, algo parecido a dejar un paquete en correos para que lo entreguen cuando puedan.
- En bioinformática resulta útil para lanzar análisis como `FastQC`, alineamientos o ensamblados sobre tus archivos de secuenciación sin hacerlo manualmente.
- Permite enviar trabajos para que se ejecuten en segundo plano en el clúster `short_idx` (nodos `ideafix[01-10]`), liberando tu ordenador personal para otras tareas.

#### ¿Para qué sirve?

- Automatiza la ejecución de tareas sin necesidad de que permanezcas conectado al clúster.
- Reserva CPU, memoria y tiempo de ejecución, garantizando que cada análisis disponga de los recursos adecuados.
- Guarda un registro de la actividad y los resultados de cada trabajo, lo que facilita revisar qué ocurrió en cada paso.
- Facilita repetir un mismo análisis con parámetros diferentes simplemente editando un archivo.

#### ¿Cómo se organiza un script `sbatch`?

Un archivo `sbatch` es un documento de texto que sigue la estructura:

```bash
#!/bin/bash                  # 1) La primera línea indica con qué intérprete se ejecutará
#SBATCH --option=valor       # 2) Directivas que piden recursos a Slurm
# Aquí empieza la parte que tú quieres ejecutar
comando_1
comando_2
```

1. **Shebang (`#!/bin/bash`)** – define el intérprete.
2. **Directivas `#SBATCH`** – comienzan con `#SBATCH` y se usan para reservar recursos o configurar el trabajo.
3. **Comandos** – las órdenes que se ejecutarán cuando haya hueco en la cola.

##### Parámetros habituales

```bash
#!/bin/bash
#SBATCH --chdir=/ruta/al/directorio/de/trabajo  # Carpeta donde se ejecutará el análisis
#SBATCH --job-name=mi_trabajo                   # Nombre reconocible
#SBATCH --cpus-per-task=1                       # Número de núcleos
#SBATCH --mem=1G                                # Memoria RAM
#SBATCH --time=00:10:00                         # Tiempo máximo
#SBATCH --partition=short_idx                   # Cola o partición
#SBATCH --output=slurm-%j.out                   # Guardar la salida estándar
#SBATCH --error=slurm-%j.err                    # Guardar los errores
```

En este ejemplo el trabajo `mi_trabajo` se ejecutará en el directorio indicado, reservando una CPU y 1 GB de memoria durante un máximo de diez minutos dentro de la partición `short_idx`. Los archivos de salida (`slurm-<jobid>.out` y `.err`) permiten revisar después qué ocurrió.

##### Otros parámetros útiles

- `--mail-type` y `--mail-user`: recibir un correo al empezar o terminar.
- `--dependency=afterok:<jobid>`: esperar a que otro trabajo termine correctamente.
- `--array`: para crear **job arrays** (los veremos en la siguiente sección).

#### Cargar módulos y preparar el entorno

Los nodos del clúster suelen tener un sistema de módulos para activar software. Antes de ejecutar un programa es habitual cargarlo:

```bash
module load fastqc/0.12.1   # Cargar la versión 0.12.1 de FastQC

fastqc datos.fq.gz          # Comando real a ejecutar
```

De esta forma garantizamos que el software correcto esté disponible.

#### Lanzar el trabajo

```bash
sbatch mi_script.sh
```

El comando devuelve un número (`Submitted batch job 12345`), que es el identificador del trabajo. Guárdalo, ya que lo usaremos para consultar su estado.

#### Explorar la ejecución en Slurm

```bash
squeue --me                   # Ver los trabajos pendientes o en ejecución
scontrol show job <jobid>     # Información detallada de un trabajo
sacct -j <jobid> --format=JobID,State,Elapsed  # Histórico si el trabajo ya terminó
```

`squeue` funciona como la lista de espera, mientras que `scontrol` y `sacct` aportan detalles sobre la ejecución.

#### Revisar los resultados

- Los archivos especificados en `--output` y `--error` recogen la salida estándar y los errores.
- Si el trabajo generó ficheros (por ejemplo, un informe `FastQC`), los encontrarás en el directorio de trabajo.
- Es recomendable comprobar el uso de recursos con `sacct -j <jobid> -o MaxRSS,Elapsed` para ajustar futuras ejecuciones.

#### Consejos y buenas prácticas

- Asigna **nombres descriptivos** a tus trabajos (`--job-name`), así será más fácil encontrarlos.
- No pidas más recursos de los necesarios: un uso responsable evita colas largas.
- Incluye comentarios en tu script explicando cada paso; tus "yo" del futuro lo agradecerán.
- Guarda tus scripts en un repositorio para reutilizarlos en otros proyectos.

---

### Job Arrays: mismos pasos, múltiples muestras

#### ¿Qué son?

- Son una forma de lanzar muchos trabajos similares con una sola orden, como analizar varios archivos FASTQ con el mismo script.
- Cada tarea del *array* recibe un identificador (`SLURM_ARRAY_TASK_ID`) para distinguirse del resto. Podemos verlo como repartidores que llevan paquetes similares pero a distintas direcciones.

#### ¿Cuándo usarlos?

- Análisis repetitivos sobre múltiples muestras o parámetros, por ejemplo ejecutar un alineador para cada muestra de un experimento.
- Simulaciones que sólo cambian en un número de entrada.

#### Variables externas

- Dentro del script puedes acceder a:
  - `$SLURM_ARRAY_JOB_ID` – identificador del array.
  - `$SLURM_ARRAY_TASK_ID` – identificador de cada tarea.
- Útil para seleccionar archivos de entrada: `input_${SLURM_ARRAY_TASK_ID}.txt`.

#### Ejecución

```bash
sbatch --array=1-20 mi_array.sh
```

El parámetro `--array=1-20` lanza veinte tareas numeradas del 1 al 20. Cada una ejecutará el mismo script pero podrá trabajar con datos distintos.

#### Monitorización

- `squeue --me` mostrará todas las tareas del array.
- `gstat` ofrece una vista resumida del uso de recursos (cuando esté disponible).
- `sacct -j <array_jobid>` enumera el estado de cada tarea del array.

#### Ejemplo completo

```bash
#!/bin/bash
#SBATCH --job-name=array_fastqc
#SBATCH --array=1-3
#SBATCH --time=00:05:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

module load fastqc/0.12.1

fastqc muestra_${SLURM_ARRAY_TASK_ID}.fq.gz
```

En este caso se lanzan tres tareas que analizan `muestra_1.fq.gz`, `muestra_2.fq.gz` y `muestra_3.fq.gz`. Todas comparten recursos y parámetros, lo que permite procesarlas en paralelo de forma sencilla.

#### Consejos rápidos

- Usa rangos discontínuos si lo necesitas: `--array=1-3,7,9-12`.
- Controla cuántas tareas pueden ejecutarse a la vez con `--array=1-100%10` (máximo 10 simultáneas).
- Combina job arrays con `--dependency` para construir pequeños flujos de trabajo.

<!-- TODO: añadir ilustraciones y esquemas sobre el flujo de trabajos -->

---

## Próximos pasos

En la segunda mitad de este talk abordaremos los conceptos básicos de **paralelización** con MPI y OpenMP, y veremos cómo todo esto se integra en un workflow reproducible con Nextflow.

