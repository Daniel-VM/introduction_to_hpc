Perfecto. Investigaré a fondo cada apartado del temario sobre `sbatch` y job arrays en Slurm, buscando una explicación clara y didáctica orientada a estudiantes con conocimientos muy básicos. Incluiré analogías, ejemplos accesibles y sugerencias pedagógicas para enriquecer tus apuntes manteniendo tu estilo cercano.

Te avisaré en cuanto tenga una versión mejorada para tu revisión.


# Talk 6: Scripting and parallelization

## Scripting

La idea principal de esta parte del curso es aprender a **delegar trabajo** en el clúster. En lugar de ejecutar cada comando manualmente, preparamos un pequeño guion (*script*) que el gestor de colas (Slurm) interpreta y ejecuta por nosotros. De este modo, podemos irnos a casa y dejar que los ordenadores hagan su trabajo sin supervisión directa. Además, trabajar así es más seguro para el sistema: los administradores recomiendan no ejecutar tareas pesadas en el nodo de acceso (*frontend*), sino enviarlas a los nodos de cálculo mediante Slurm. Slurm se encargará de asignar el trabajo a un nodo disponible, controlar su ejecución y evitar conflictos de recursos, garantizando un uso eficiente y justo del clúster.

### SBATCH: la puerta de entrada

#### ¿Qué es `sbatch`?

* `sbatch` es un comando que podremos utilizar desde la terminal, y sirve para dar una orden a **Slurm**. 
* Concretamente, es la orden de **Slurm** para enviar un *script* de trabajo a la cola del clúster. Equivale a dejar un paquete en correos para que lo entreguen cuando puedan: tú entregas el paquete (tu script) en la “oficina” Slurm, y el clúster lo ejecutará cuando haya recursos disponibles.
* En bioinformática y otras áreas, resulta útil para lanzar análisis repetitivos (ej. control de calidad con `FastQC`, alineamientos, ensamblados, etc.) sobre múltiples archivos de secuenciación sin hacerlo de forma interactiva uno por uno.
* Permite enviar trabajos al clúster para que se ejecuten en **segundo plano** (por ejemplo, en la cola `short_idx` con nodos `ideafix[01-10]`), liberando tu ordenador personal para otras tareas. En otras palabras, usas la potencia del clúster en lugar de sobrecargar tu PC.

#### ¿Para qué sirve?

* **Automatización:** Puedes lanzar tareas largas o múltiples sin necesidad de permanecer conectado. Slurm se encargará de gestionar la entrada de estas tareas (comunmente conocidas como "jobs") al sistema del colas del HPC, las ejecutará y tú puedes desconectar o hacer otras cosas.
* **Reserva de recursos:** Al enviar un trabajo, especificas cuántas CPU, cuánta memoria RAM y cuánto tiempo necesitas. El gestor reserva esos recursos para ti, garantizando que cada análisis disponga de lo necesario y no interfiera con otros. Esto previene la sobrecarga y ayuda a aprovechar el hardware equitativamente.
* **Ejecución reproducible:** Queda un registro de la actividad y resultados de cada trabajo. La salida estándar y los errores se guardan en archivos de log, lo que facilita revisar qué ocurrió en cada paso y depurar si algo falla.
* **Facilita reruns:** Puedes repetir un análisis con parámetros distintos editando un solo archivo en lugar de teclear de nuevo todos los comandos. Tus pasos quedan documentados en el script, reduciendo errores humanos.

#### ¿Cómo se organiza un script `sbatch`?

Un *script* para `sbatch` es un archivo de texto con una estructura fija que combina **directivas de Slurm** y **órdenes de la terminal**. Por ejemplo:

```bash
#!/bin/bash                  # 1) Shebang: intérprete que ejecutará el script
#SBATCH --option=valor       # 2) Directivas SBATCH que solicitan recursos/configuración
#SBATCH --option=valor       # 2) Directivas SBATCH que solicitan recursos/configuración
#SBATCH --option=valor       # 2) Directivas SBATCH que solicitan recursos/configuración
# A partir de aquí, comandos que queremos ejecutar:
comando_1
comando_2
```
>Llamemos a este script `myscript.sh`. Como puedes ver, los script sbatch son archivos tipo "sh".


1. **Shebang (`#!/bin/bash`)** – la primera línea indica qué intérprete de comandos se usará (normalmente Bash).
2. **Directivas `#SBATCH`** – líneas que comienzan con `#SBATCH` para pedir recursos o ajustes al gestor de colas. Estas líneas no son comandos normales, sino instrucciones para Slurm que se procesan en el momento de enviar el script.
3. **Comandos** – tras las directivas, escribes los comandos Linux que deseas ejecutar. Cuando Slurm ejecute tu trabajo en un nodo del clúster, irá corriendo estos comandos en orden.

##### Parámetros habituales

Un ejemplo de cabecera de script con parámetros típicos sería:

```bash
#!/bin/bash
#SBATCH --chdir=/ruta/al/directorio/de/trabajo  # Carpeta donde se ejecutará el análisis
#SBATCH --job-name=my_first_slurm_job           # Nombre reconocible del trabajo
#SBATCH --cpus-per-task=1                       # Número de CPU (hilos) para este trabajo
#SBATCH --mem=1G                                # Memoria RAM a reservar
#SBATCH --time=00:10:00                         # Tiempo máximo (HH:MM:SS)
#SBATCH --partition=short_idx                   # Cola o partición en la que correr
#SBATCH --output=slurm-%j.out                   # Archivo para la salida estándar
#SBATCH --error=slurm-%j.err                    # Archivo para la salida de errores
```

En este ejemplo, el trabajo **my\_first\_slurm\_job** se ejecutará en la carpeta indicada, reservando 1 CPU y 1 GB de RAM durante un máximo de diez minutos, dentro de la partición `short_idx`. Los archivos de salida `slurm-%j.out` y `slurm-%j.err` contendrán lo que normalmente veríamos en pantalla: `%j` se sustituye por el identificador del trabajo para que cada trabajo tenga sus propios logs. De este modo, después podremos abrir `slurm-<jobid>.out` para ver los mensajes normales del programa, y `slurm-<jobid>.err` para ver los errores, sin mezclarlos con otros trabajos. Ten en cuenta que **indicar un tiempo máximo es muy importante** – en algunos clústeres es obligatorio especificarlo con el formato `D-HH:MM:SS` o `HH:MM:SS`. Si no lo haces, Slurm podría asumir por defecto un valor máximo (p. ej. 2 días) y eso puede hacer que tu trabajo espere más de la cuenta para iniciar.

##### Otros parámetros útiles

* `--mail-type=END,FAIL` y `--mail-user=tu_email@dominio` – para que Slurm te envíe un correo cuando el trabajo empiece, termine o falle, según el tipo seleccionado.
* `--dependency=afterok:<jobid>` – hace que tu trabajo espere a que otro termine correctamente. Útil para lanzar un análisis sólo si el anterior fue bien (encadenar pasos).
* `--array=<rango>` – crea **job arrays** o “trabajos en *array*”, es decir, envía múltiples tareas similares de una vez. Lo veremos en la siguiente sección con más detalle.
* `--qos=<nombre>` – selecciona un Quality of Service si tu clúster ofrece varias calidades/prioridades de ejecución.
* `--gres=gpu:2` – en clústeres con GPU, pedir por ejemplo 2 GPUs para tu trabajo (si haces cómputo acelerado).

A continuación te indico una página en donde puedes encontrar la lista completa de parámetros:

- https://slurm.schedmd.com/sbatch.html#SECTION_OPTIONS


> **Nota:** Cada clúster puede tener parámetros adicionales o ciertos valores por defecto. Consulta la documentación local para opciones específicas.

#### Cargar módulos y preparar el entorno

Como hemos visto a lo largo de este curso, los nodos de cálculo suelen usar un sistema de *módulos de entorno* para gestionar el software disponible. Antes de ejecutar un programa es habitual “cargar” el módulo correspondiente. Por ejemplo, si vas a usar FastQC, asegúrate de cargarlo en el script:

```bash
module load fastqc/0.12.1    # Activar el módulo de FastQC versión 0.12.1

fastqc datos.fq.gz           # Ahora ejecutamos el comando real sobre nuestro archivo
```

De esta forma garantizamos que el software correcto esté disponible en el *PATH* cuando se ejecute el trabajo. Puedes cargar todos los módulos o activar entornos (conda, etc.) necesarios antes de lanzar los comandos principales. Así, el nodo de cómputo tendrá las mismas herramientas que tú usas al probar el análisis de manera interactiva.

#### Lanzar el trabajo

Para enviar el trabajo al clúster utilizamos el comando `sbatch` seguido del nombre de nuestro script:

```bash
sbatch mi_script.sh
```

Al enviarlo, Slurm devolverá un mensaje del estilo `Submitted batch job 12345`. Ese **12345** es el identificador único de tu trabajo (job ID). Conviene apuntarlo, ya que lo usaremos para consultar el estado y revisar la ejecución. Ten en cuenta que `sbatch` sólo coloca tu trabajo en la cola; el script no empieza a correr inmediatamente, sino cuando Slurm encuentre un hueco con los recursos que pediste. Cuantos más recursos solicites (por ejemplo, muchos núcleos o muchas horas), más podría tardar en entrar en ejecución, ya que tendrá que esperar a que estén disponibles esos recursos.

#### Explorar la ejecución en Slurm

Una vez enviado el trabajo, dispones de varias herramientas para monitorear y obtener información:

* `squeue --me` – muestra tus trabajos en cola o en ejecución (según la configuración, `--me` puede filtrar por tu usuario). Verás columnas como JOBID (ID del trabajo), PARTITION (cola), NAME (nombre que le diste), ST (estado), TIME (tiempo transcurrido) y NODES (nodos utilizados). Un trabajo recién enviado suele aparecer en **PD (Pending)** mientras espera turno, y pasará a **R (Running)** cuando esté ejecutándose. Si no ves tu job en `squeue`, posiblemente ya terminó (¡o quizá nunca se envió correctamente!).
* `scontrol show job <jobid>` – brinda información **detallada** de un trabajo concreto. Este comando te mostrará todos los parámetros y el estado actual del job: en qué nodo(s) está corriendo o por qué está pendiente (a veces indica *Reason=* con la razón de espera), cuánta memoria pidió, cuándo se envió, etc. Es útil para diagnosticar por qué un trabajo sigue en cola (por ejemplo, si está esperando porque pediste más tiempo del permitido en esa partición, aparecerá un Reason). *Tip:* Sólo podrás ver detalles de **tus** trabajos, no los de otros usuarios.
* `sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS` – consulta el **histórico** de un trabajo (funciona una vez ha **terminado**, no para los activos). Este comando forma parte de las herramientas de *accounting* de Slurm. Por ejemplo, `sacct -j 12345 -o JobID,State,Elapsed,MaxRSS` te dirá si el job 12345 acabó exitosamente (State=COMPLETED) o hubo problemas (FAILED, TIMEOUT, etc.), cuánto tiempo ejecutó efectivamente (Elapsed) y el máximo de memoria RAM que llegó a usar (MaxRSS). `sacct` es muy útil para revisar a posteriori los recursos consumidos y así ajustar mejor las peticiones en futuros lanzamientos.


#### Revisar los resultados

Una vez el trabajo finaliza (o incluso durante su ejecución), debemos **validar los resultados**:

* Abre los archivos de salida que indicamos en el script. Por ejemplo, si usamos `--output=slurm-%j.out` y el job ID era 12345, habrá un fichero `slurm-12345.out`. Ahí estará la salida estándar de tu programa (lo que normalmente verías en pantalla al ejecutarlo). Del mismo modo, revisa `slurm-12345.err` para ver si hubo mensajes de error. Si tu script no definió archivos `--output`/`--error`, Slurm igualmente habrá generado uno por defecto (suele llamarse `slurm-<jobid>.out` o, en caso de *array jobs* (los veremos a continuación), `slurm-<jobid>_<taskid>.out` por defecto).
* Si el trabajo generó archivos de resultado (por ejemplo, un informe HTML de FastQC, un archivo de alineamiento BAM, etc.), búscalos en el directorio de trabajo que estableciste (`--chdir`). Verifica que existen y que tienen sentido (tamaño, formato esperado, etc.).
* Comprueba en `sacct` el estado final del job. Si aparece como **COMPLETED**, en principio terminó bien. Si pone **FAILED**, **CANCELLED** o **TIMEOUT**, algo ocurrió: quizá el programa devolvió error, o se quedó sin memoria, o excedió el tiempo límite. En ese caso, inspecciona el `.err` en busca de pistas (p.ej. mensajes de “Killed” suelen indicar que sobrepasó memoria).

En resumen, los logs y la información de Slurm sirven para hacer un poco de “CSI” de tus trabajos: entender qué pasó y afinar la configuración para futuras corridas.

#### Consejos y buenas prácticas

* **Asigna nombres descriptivos** a tus trabajos (`--job-name`). Un nombre claro (ej: `align_mouse_genome`) te permitirá identificar fácilmente para qué era cada job cuando mires la cola con `squeue` o los logs.
* **¡¡No pidas más recursos de los necesarios!!:** un uso responsable evita colas largas y desperdicio de cómputo. Solicitar recursos excesivos (por ejemplo, 16 CPUs si tu código sólo usa 1) hará que tu trabajo espere mucho para iniciar y estarás bloqueando recursos inútilmente. En algunos clústeres, si no indicas memoria/CPU, el planificador asume que necesitas todo el nodo y tu job **no empezará hasta tener un nodo completo libre**, lo que puede demorar horas o días. Sé específico pero realista con lo que necesitas.
* **No ejecutes trabajos pesados en el nodo de login:** envíalos siempre a través de `sbatch` (o en modo interactivo con `salloc/srun` si corresponde). Todos los usuarios comparten el login; si tú ejecutas algo grande allí, entorpeces a los demás. La documentación de centros HPC recalca que *“todos los trabajos HPC deben ejecutarse en los nodos de cálculo mediante el envío de un script al gestor de trabajos”*.
* **Incluye comentarios en tu script** explicando cada paso. Agradecerás estos comentarios cuando vuelvas a ese script meses después sin recordar por qué pusiste tal comando. Un simple `# Preprocesar los FASTQ` encima de una línea de código hace maravillas para la claridad.
* **Prueba primero en pequeño:** antes de lanzar un análisis masivo o un job array con 100 muestras, haz una prueba con un caso o un subset de datos. Esto te ayuda a detectar rutas incorrectas, módulos que olvidaste cargar, o parámetros mal ajustados. Más vale descubrir en 2 minutos de prueba que falta instalar cierto paquete, que darse cuenta tras 5 horas de cola y un job fallido.
* **Guarda tus scripts** (y si es posible, versionálos con Git u otro sistema). Reutilizarás muchos de estos scripts en futuros proyectos. Tener un repositorio de “scripts Slurm” te ahorra tiempo y te asegura que usas comandos probados.
* **Usa job arrays para tareas repetitivas:** si alguna vez te ves escribiendo un bucle `for` para lanzar el mismo script con 10 archivos distintos, es señal de que deberías emplear un *array job*. Los *job arrays* son la forma que ofrece Slurm para enviar muchos trabajos similares de forma limpia y eficiente. En la siguiente sección profundizamos en cómo utilizarlos.
* **Encadena tareas con dependencias:** para flujos de trabajo más complejos, considera lanzar jobs que empiecen cuando otros acaben (`--dependency`). Por ejemplo, primero un job que filtra datos, y al terminar, que arranque automáticamente otro job de análisis sobre esos datos filtrados. Esto te permite construir pipelines sencillos sin supervisión manual en cada paso.

---

### Job Arrays: mismos pasos, múltiples muestras

#### ¿Qué son?

Son una funcionalidad de Slurm para lanzar muchos trabajos **idénticos en su estructura** (mismo script) pero con ligeras variaciones, típicamente en los datos de entrada o en algún parámetro. En lugar de crear 50 scripts para 50 muestras, creas **un solo script** y le dices a Slurm que lo ejecute N veces. Podemos imaginarlo como una flotilla de repartidores que llevan el mismo paquete a distintas direcciones: el proceso base es el mismo, sólo cambia la “dirección” (p. ej., el nombre de archivo de entrada). Slurm enviará esas tareas al clúster de forma automática y en paralelo cuando sea posible.

En términos más formales, un *job array* es un conjunto de tareas (*tasks*) que comparten un mismo **JobID base** pero se distinguen por un índice (array index). Si envías un array de 10 tareas, Slurm te dará un JobID (digamos 45678) y a cada tarea un ID compuesto como 45678\_1, 45678\_2, ..., 45678\_10.

#### ¿Cuándo usarlos?

* Cuando necesites repetir la **misma operación** sobre múltiples entradas. Por ejemplo, ejecutar un alineador sobre 100 archivos FASTQ, o entrenar 20 modelos con diferentes semillas aleatorias.
* Cuando quieras probar un mismo código con distintos parámetros independientes (p. ej., 10 valores de una variable) sin tener que cambiar manualmente el script cada vez.
* En general, siempre que tengas cargas de trabajo *triviales de paralelizar* (“embarrassingly parallel”), donde cada tarea puede correr por su cuenta sin comunicación con las demás.

La documentación oficial aconseja usar arrays en lugar de lanzar muchos jobs individuales en bucle. Esto aligera la carga del planificador y te facilita la vida, ya que con un solo comando controlas todo el conjunto.

#### Variables de entorno para arrays

Slurm pone a disposición algunas variables de entorno dentro del script para que sepas qué tarea del array es cada una:

* `$SLURM_ARRAY_JOB_ID` – ID del job array (en el ejemplo arriba, 45678). Todas las tareas comparten este ID base.
* `$SLURM_ARRAY_TASK_ID` – índice de la tarea dentro del array. Toma valores 1, 2, 3, … según lo definido.
* (También existe `$SLURM_ARRAY_TASK_COUNT` con el tamaño total del array, y `$SLURM_ARRAY_TASK_MAX`/`MIN` con los límites del rango, entre otras, según la versión de Slurm).

La más útil es `$SLURM_ARRAY_TASK_ID`. Podemos usarla dentro del script para variar la entrada. Por ejemplo, si tus archivos se llaman `muestra_1.fq.gz`, `muestra_2.fq.gz`, etc., en el script puedes referirte a `muestra_${SLURM_ARRAY_TASK_ID}.fq.gz`. Cuando la tarea 1 ejecute, expandirá a `muestra_1.fq.gz`; la tarea 2 usará `muestra_2.fq.gz`, y así sucesivamente. De esta forma un único script sirve para todas las muestras.

Otra forma común es usar el índice para leer de una lista. Por ejemplo, podrías tener un archivo de texto con una lista de 100 nombres de muestras y que cada tarea lea la línea N que corresponde a su `$SLURM_ARRAY_TASK_ID`. Esto permite trabajar con nombres que no son simplemente 1, 2, 3, sino, por decir, IDs de pacientes o similares. Requiere un poco más de scripting (ej. usando `sed` o `awk` para extraer la línea correspondiente), pero es muy poderoso para generalizar análisis.

#### Ejecución de un job array

Lanzar un job array es tan sencillo como añadir `--array` al comando sbatch. Por ejemplo:

```bash
sbatch --array=1-20 mi_array.sh
```

Esto enviará **20 tareas**, numeradas del 1 al 20, que ejecutarán el script `mi_array.sh` cada una por su lado. Slurm intentará correrlas en paralelo, ocupando tantos recursos como le hayas pedido por tarea. Es decir, si cada tarea pide 1 CPU, en teoría podrían correr hasta 20 a la vez (si el clúster tiene suficientes núcleos libres). Si pides muchas CPU o RAM por tarea, quizás sólo unas pocas puedan ejecutarse simultáneamente.

Puedes especificar rangos más complejos: `--array=1-3,7,9-12` lanzaría tareas 1,2,3,7,9,10,11,12 (saltando algunos índices). También puedes limitar cuántas corren al mismo tiempo usando `%`. Ejemplo: `--array=1-100%10` lanzará hasta 10 tareas en paralelo como máximo, aunque haya 100 en total. Esto es útil si no quieres saturar el clúster o si cada tarea ya consume muchos recursos. Ten en cuenta que esto no garantiza orden ni secuencia; Slurm seguirá gestionando la cola según prioridades y disponibilidad, simplemente no pondrá más de 10 concurrentes en este caso.

Dentro del propio *script* sbatch, también puedes poner la directiva array junto con el resto de `#SBATCH`. Por ejemplo, en el encabezado del script podrías tener `#SBATCH --array=1-20` para no tener que especificarlo en la línea de comando. También es común ajustar en el script los nombres de archivo de log para que incluyan el índice, así:

```bash
#SBATCH --output=mi_trabajo_%A_%a.out 
#SBATCH --error=mi_trabajo_%A_%a.err
```

Aquí `%A` representa el JobID principal del array y `%a` el índice de cada tarea. De este modo, cada tarea escribe en su propio log (por ejemplo `mi_trabajo_45678_3.out` para el job 45678 tarea 3). De lo contrario, si todas las tareas escribieran al mismo `slurm-45678.out` sería difícil separar la salida de cada una (Slurm por defecto ya separa los logs de arrays usando este patrón `%A_%a` si no especificas `--output`, pero conviene saberlo para personalizarlo).

#### Monitorización de arrays

* `squeue --me` mostrará cada tarea del array como una entrada separada, con el formato `<JobID>_<Task>` en la columna JOBID. Por ejemplo, podrías ver `45678_5` en estado R y `45678_6` en PD, etc., indicando qué índices van corriendo y cuáles esperan.
* `scontrol show job <JobID>` con el ID principal listará información del array completo, pero también puedes consultar una tarea específica añadiendo el índice (a veces requiere el flag `-d` para ver subtareas detalladas). En general, para info rápida es más cómodo `squeue` o `sacct`.
* `sacct -j 45678` listará el histórico de todas las tareas del array 45678. Podrás ver cada una con su State (COMPLETED/FAILED) y recursos usados. Esto es genial para, por ejemplo, detectar si de 100 tareas, 2 fallaron por alguna razón.
* Herramientas personalizadas del clúster (como el mencionado `gstat`) suelen agrupar el uso por array para no saturar la vista. Revisa la documentación local para ver cómo presentan los arrays.

La monitorización de arrays es muy similar a la de jobs normales, solo que tienes **muchos jobs hijitos** bajo un mismo paraguas. Recuerda que para cancelar, también puedes hacerlo en bloque: `scancel 45678` eliminaría *todo* el array, mientras que `scancel 45678_5` intentaría eliminar sólo la tarea 5. Si cancelas individualmente y todas las tareas terminan (o se cancelan), el JobID padre se marcará como completado cuando ya no queden tareas activas.

#### Ejemplo completo

Imagina que tienes 3 archivos FASTQ (`muestra_1.fq.gz`, `muestra_2.fq.gz`, `muestra_3.fq.gz`) y quieres correr FastQC en todas. Podrías crear un script `fastqc_array.sh` así:

```bash
#!/bin/bash
#SBATCH --job-name=array_fastqc
#SBATCH --output=fastqc_%A_%a.out   # logs separados por tarea
#SBATCH --error=fastqc_%A_%a.err
#SBATCH --partition=short_idx
#SBATCH --time=00:05:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --array=1-3

module load fastqc/0.12.1

# Usar el ID de tarea para elegir el archivo correspondiente
fastqc muestra_${SLURM_ARRAY_TASK_ID}.fq.gz
```

Al ejecutar `sbatch fastqc_array.sh`, Slurm creará 3 tareas en paralelo (si puede). Cada una cargará FastQC y ejecutará el análisis sobre su archivo correspondiente gracias a la variable de entorno. Los resultados (archivos HTML de FastQC, etc.) aparecerán en el directorio de trabajo, y tendremos `fastqc_45679_1.out`, `_2.out`, `_3.out` con los logs de cada una (asumiendo JobID 45679).

Como ves, todas las tareas comparten la misma definición de recursos (`--cpus-per-task=1`, etc.) y parámetros. Eso significa que **cada** tarea del array recibirá, en este caso, 1 CPU y 1GB de RAM y podrá usar hasta 5 minutos. En otras palabras, los recursos que pides en las directivas *se aplican por tarea*, no al conjunto completo. No necesitas, por ejemplo, multiplicar la memoria por el número de tareas. Si pides `--mem=1G` en un array de 100 tareas, estás pidiendo que **cada tarea** use hasta 1GB (no que las 100 juntas compartan 1GB, obviamente).

#### Consejos rápidos

* **Rangos con paso:** Puedes lanzar arrays con un incremento distinto de 1 usando el formato `start-end:step`. Ejemplo: `--array=0-9:2` ejecuta las tareas 0, 2, 4, 6, 8 (si tu lógica usa índices pares, por ejemplo).
* **Evita enormes cantidades sin control:** Aunque Slurm soporta hasta millones de tareas en un array, no siempre es buena idea lanzar 100k jobs de golpe. Si vas a procesar cientos de miles de elementos, asegúrate de que el clúster puede con ello (a veces hay límites como `%1000` concurrentes, etc.). Divide en lotes si es necesario.
* **Combina arrays con dependencias:** Puedes lanzar un array que procese muestras y luego un job que agregue resultados una vez *todas* las tareas del array hayan terminado. Para esto, puedes usar `--dependency=afterok:<JobID_padre>` en un job separado, o incluso `--dependency=afterok:45679_3` para depender de una tarea específica. Otra opción es la dependencia *singleton* o *afterok:<JobID>* (sin índice, refiriéndose al array completo). Consulta la documentación de Slurm para casos avanzados.
* **Uso de archivos temporales separados:** Si todas tus tareas escriben a un mismo archivo (caso raro, pero podría ser), podrías tener conflictos. Intenta que cada tarea use archivos separados, idealmente etiquetados con su ID. Las variables `%A`/`%a` y `$SLURM_ARRAY_TASK_ID` son tus aliadas para eso.
* **Depuración de arrays:** Si una de las tareas falla, a veces querrás recrear solo esa. Puedes lanzar otro job (no array) usando la misma entrada para investigar el fallo, o volver a lanzar el array limitado a ese índice (`--array=7` por ejemplo). También fíjate en `sacct` cuál fue el error de esa tarea fallida (te mostrará el código de salida o señal que causó el fallo).


## Parallelization in HPC: OpenMP vs MPI

En esta segunda parte vamos a ver **cómo aprovechar varios núcleos o incluso varios nodos del clúster** para acelerar nuestros análisis.
En HPC, esto se llama *paralelización*, y puede hacerse de dos maneras principales: **OpenMP** y **MPI**. Aunque hay más tecnologías, estas dos son las más habituales y las que veremos en nuestro clúster.

### ¿Qué son OpenMP y MPI?

Por un lado, **OpenMP** es un modelo de paralelización para memoria compartida. Permite utilizar multiples hilos/threads dentro de un proceso que será ejecutado en un nodo (habitualmente, este último contará con varios núcleos de CPUs). Por ejemplo, un programa OpenMP lanzará un proceso y creará varios hilos que corren en paralelo dentro de ese nodo, compartiendo datos en la RAM común

Por otro lado, **MPI** es un estándar de programación para memoria distribuida. Está pensado para ejecutar una aplicación en múltiples procesos separados, potencialmente en distintos nodos de un clúster, que se comunican entre sí mediante el paso de mensajes a través de la red. Es el modelo típico en supercomputación para problemas muy grandes, donde los datos no caben en la RAM de un solo nodo o se necesita más poder de cómputo del que ofrece una sola máquina.


En el contexto de **bioinformática**, la gran mayoría de programas usan **OpenMP**:

* Herramientas de alineamiento (BWA, Bowtie2, STAR, Minimap2…)
* Ensambladores (SPAdes, MEGAHIT…)
* Análisis de variantes (GATK, FreeBayes…)
* Procesamiento de lecturas (Fastp, Cutadapt…)

Por otro lado, **MPI** se usa poco, pero hay excepciones, sobre todo en programas de **filogenia** o análisis masivos de simulaciones, por ejemplo:

* RAxML en modo MPI
* IQ-TREE MPI
* Algunos paquetes de modelado molecular o dinámica

[TODO]: <Add image of partition -- node -- cpus>

La **gran diferencia** entre ambas es **dónde y cómo se reparten las tareas**:

| Tecnología | Nivel de paralelización     | Comunicación entre procesos                                        | Ejemplo de uso típico                                                        |
| ---------- | --------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| **OpenMP** | Dentro de **un mismo nodo** | Memoria compartida: todos los hilos acceden a la misma RAM         | Alinear 200 millones de lecturas en un solo nodo usando todos sus núcleos    |
| **MPI**    | Entre **varios nodos**      | Memoria distribuida: cada nodo tiene su RAM y se comunican por red | Construir un árbol filogenético muy grande repartiendo el trabajo en 4 nodos |

---

### Configuración de un trabajo OpenMP en Slurm

Supongamos que queremos ejecutar un programa bioinformático que soporta paralelismo con OpenMP (por ejemplo, ensamblador de secuencias) en un clúster HPC que usa Slurm como gestor de colas. El objetivo es aprovechar, digamos, 8 núcleos de CPU en un nodo para acelerar el análisis. Cuando usamos OpenMP, la clave está en definir el parámetro de Slurm: **`--cpus-per-task`**.


```bash
#!/bin/bash
#SBATCH --job-name=spades_openmp
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --partition=long
#SBATCH --output=spades_%j.out
#SBATCH --error=spades_%j.err

module load spades/3.15.5
spades.py --threads $SLURM_CPUS_PER_TASK -o ensamblado_resultado
```

**Parámetros relevantes del script OpenMP:**

* **`--cpus-per-task`** = número de hilos/threads que el software podrá usar.
* La memoria **`--mem`** debe ser suficiente para todos esos hilos, ya que comparten la misma RAM del nodo.
* `$SLURM_CPUS_PER_TASK` es una variable que Slurm rellena automáticamente con el valor que pediste.

**Ejecución del script OpenMP:**
```bash
srun --mpi=none spades_slurm.sh
```
> En este caso usamos srun (con --mpi=none para indicarle que no intente hacer cosas de MPI) para que Slurm inicie el programa usando los 8 cores asignados.

**Debugging y control de uso:**

* Durante la ejecución:
  `sstat -j <jobid> --format=JobID,MaxRSS,AveCPU` → ver uso de RAM y CPU.
* Después de acabar:
  `sacct -j <jobid> --format=JobID,Elapsed,MaxRSS,TotalCPU` → comprobar si realmente usaste los hilos que pediste.

---

### Configuración de un trabajo MPI en Slurm

Cuando usamos MPI, la clave está en **`--nodes`** y **`--ntasks`**. Supongamos un caso donde usamos una herramienta paralela con MPI – por ejemplo, el programa **RAxML** para un análisis filogenético grande, o cualquier otra aplicación HPC distribuida. En este caso queremos utilizar varios nodos, digamos 2 nodos con 4 procesos MPI en cada nodo (total 8 procesos de cómputo trabajando en paralelo). Los pasos del script SBATCH serían:

```bash
#!/bin/bash
#SBATCH --job-name=raxml_mpi
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=4
#SBATCH --mem=8G
#SBATCH --time=06:00:00
#SBATCH --partition=long
#SBATCH --output=raxml_%j.out
#SBATCH --error=raxml_%j.err

module load raxml/8.2.12
mpirun -np $SLURM_NTASKS raxmlHPC-MPI -s datos.phy -n resultado -m GTRGAMMA
```

**Parámetros relevantes del script OpenMP:**

* **`--nodes`** = cuántos nodos distintos se usarán.
* **`--ntasks`** = número total de procesos MPI a lanzar (pueden estar repartidos en varios nodos).
* **`--ntasks-per-node`** = distribución de tareas por nodo (opcional, pero recomendable).
* `$SLURM_NTASKS` = variable con el número de tareas pedidas.

**Depuración y control de uso:**

* Igual que en OpenMP, `sstat` y `sacct` sirven para ver uso real.
* Importante: en MPI, si un nodo falla o hay mala conexión de red, todo el trabajo puede detenerse.

---

### Pros y contras resumidos

| Aspecto                | OpenMP                                         | MPI                                             |
| ---------------------- | ---------------------------------------------- | ----------------------------------------------- |
| **Facilidad de uso**   | Muy sencillo: solo pedir más CPUs/hilos        | Más complejo: nodos, tareas y distribución      |
| **Velocidad**          | Escala bien dentro de un nodo                  | Escala entre nodos, ideal para trabajos enormes |
| **Comunicación**       | Memoria compartida (rápida)                    | Red entre nodos (más lenta)                     |
| **Uso típico bioinfo** | La mayoría de herramientas                     | Casos específicos (filogenia, simulaciones)     |
| **Riesgos comunes**    | Pedir más hilos de los que el programa soporta | Configuración incorrecta de tareas/nodos        |

---

### Consejos de depuración para el alumno

* **En OpenMP**:
  Si pides 16 hilos pero `sacct` muestra `AveCPU` muy baja, es que tu software no está usando todos los hilos. Ajusta `--cpus-per-task` o revisa parámetros (`--threads` o similar).

* **En MPI**:
  Si una tarea se queda colgada, revisa los logs (`.err`) para mensajes de conexión o comunicación. A veces es un problema de nodos ocupados o incompatibilidad con el módulo cargado.

* **En ambos casos**:
  Usa trabajos cortos de prueba antes de lanzarte a un análisis de 3 días. Mejor descubrir un fallo en 5 minutos que en 72 horas.
