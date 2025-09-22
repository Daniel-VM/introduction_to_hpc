# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

## Práctica 5: Gestión de Software en HPC

Bienvenido a la sesión práctica sobre la gestión de software en nuestro HPC. Hoy cubriremos tres temas principales:

* [Curso Práctico de Iniciación al uso del Entorno de Alta Computación](#curso-práctico-de-iniciación-al-uso-del-entorno-de-alta-computación)

  * [Práctica 5: Gestión de Software en HPC](#práctica-5-gestión-de-software-en-hpc)
  * [1. Permisos: PC personal vs HPC](#1-permisos-pc-personal-vs-hpc)
  * [2. Entornos Virtuales & Gestores de Software](#2-entornos-virtuales--gestores-de-software)

    * [2.1 Cómo compartir entornos virtuales entre usuarios del HPC](#21-Cómo-compartir-entornos-virtuales-entre-usuarios-del-HPC)
  * [3. Contenedores: Docker & Singularity](#3-contenedores-docker--singularity)

## 1. Permisos: PC personal vs HPC

* En este apartado vamos a **Comparar permisos de archivos y software** entre tu PC personal y el HPC y cómo gestionarlos.
* **Práctica: comprobar permisos de usuario y grupo**

  * Comprobar tus permisos de usuario en tu ordenador personal:

    ```bash
    whoami # Mostrar mi nombre de usuario
    groups # Mostrar los grupos a los que pertenece mi usuario
    ls -l ~ # Listar contenido del directorio home (~), incluyendo permisos
    ```
    Ahora repite el mismo comando pero en el HPC, ¿ves alguna diferencia? <br><br>

* **Práctica con `chown` (cambiar propietario del archivo):**

    * En tu ordenador personal (si tienes acceso admin/root), crea un archivo y cambia su propietario:

      ```bash
      touch testfile.txt # Crear archivo
      ls -l testfile.txt
      rm testfile.txt
      ```

    * El archivo se ha borrado sin problema. Pero ¿qué pasa si solo puede borrarlo root?

    * Primero, iniciemos una sesión root:

      ```bash
      sudo su
      touch testfile.txt
      exit # Salir de la sesión root
      ```

    * Ahora que salimos de root, revisemos los permisos de testfile.txt. **Nota:** reinicia la terminal, ya que `sudo` tiene un tiempo de gracia en el que no pide la contraseña de nuevo.

      ```bash
      ls -l testfile.txt
      ```

    * Intenta editar o borrar el archivo como usuario normal:

      ```bash
      rm testfile.txt
      ```

    * En el HPC, intenta ejecutar `chown` en un archivo de tu directorio home:

      ```bash
      touch myfile.txt
      chown root:root myfile.txt
      ```

    * **Esperado:** Aparecerá `"Operation not permitted"`, porque no tienes privilegios root en el HPC.

    * Ahora intenta cambiar la propiedad a un grupo común del laboratorio:
      `chown bi:bi myfile.txt`

  * **Discusión:**

    * ¿Por qué `chown` está restringido en sistemas compartidos?
    * ¿Cómo afecta esto a la instalación de software y gestión de archivos en HPC?

---

## 2. Entornos Virtuales & Gestores de Software

* **¿Por qué usar entornos virtuales?**
  Principalmente para aislar dependencias y evitar conflictos, pero también sirve para organizar todo el software necesario para una tarea en el mismo lugar.

* **¿Cómo crear un entorno virtual?**
  Existen muchas herramientas que ayudan a crear entornos virtuales. Softwares como **conda o mamba** incluso los gestionan para simplificar la instalación de software y evitar conflictos.
  
- En primer lugar, vamos a conectarnos al HPC por ssh como hemos visto anteriormente: `ssh -p 32122 usuario@portutatis.isciii.es`
  - Una manera sencilla de crear un entorno virtual es con `venv`, una herramienta propia de Python:

    ```bash
    python3 -m venv bioenv # Crear el entorno
    source bioenv/bin/activate # Activar el entorno
    ```

    Verás `(bioenv)` a la izquierda del prompt indicando que está activado. `pip` se instala por defecto, así que podemos aprovecharlo para instalar librerías ya que ayuda a gestionar las dependencias:

    ```bash
    pip install numpy rich requests # Instalar paquetes con pip
    python3 -c 'import numpy' # Comprobar instalación
    pip uninstall numpy
    python3 -c 'import numpy' # Esperado -> ModuleNotFoundError
    deactivate # Salir del entorno virtual
    ```

    Nota: Puedes salir en cualquier momento con `deactivate`.

* **¿Cómo trabajar con entornos virtuales en nuestro HPC?**
  En este ejercicio usaremos **seqkit** para inspeccionar archivos de secuencias. 
  * Veamos si lo tenemos instalado:
    ```bash
    seqkit --help # <-- Command 'seqkit' not found
    ```

  * Intentemos instalarlo con pip:

    ```bash
    pip install seqkit
    ```
  * Bueno, eso no salió como esperábamos ¿verdad? Como vimos en la clase teórica, pip no crea ninguna virtualización, solo gestiona paquetes y dependencias. Por lo tanto, si intentáramos instalar algo con pip, terminaríamos instalándolo para todos los demás   usuarios del HPC. Esa es la razón principal por la que **pip no está instalado globalmente en nuestro HPC**. <br><br>
  - **Discusión:** ¿Se te ocurre alguna alternativa para instalar seqkit? <br>
  Vamos a ver si lo tenemos disponible dentro de **bioenv**, el entorno virtual que creamos previamente.

    ```bash
    source envs/bioenv
    pip list # Comando para ver qué paquetes están instalados por pip

    # Output esperado:
    # Package    Version
    # ---------- -------
    # pip        25.2
    # setuptools 80.9.0
    # wheel      0.45.1
    ```
    No es nuestro caso, pero podemos intentar instalarlo con pip.
    ```
    pip install seqkit

    # Output esperado:
    # ERROR: Could not find a version that satisfies the requirement seqkit (from versions: none)
    # ERROR: No matching distribution found for seqkit
    ```

    Parece que `seqkit` no está disponible en el repositorio de pip [https://pypi.org/](https://pypi.org/). En este caso, usaremos **micromamba** para crear un entorno aislado. Una vez activado el entorno, podremos instalar y usar `seqkit` de manera segura dentro de él.

    Como `seqkit` no está en PyPI, usaremos **micromamba**.<br> <br>

* **Micromamba:** Nuestro gestor de entornos favorito, ya que es especialmente rápido y ligero. Para descargarlo en vuestro _Home_ podéis utilizar el siguiente comando:
`curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj ~/bin/micromamba`
 Además, para hacerlo fácilmente accesible vamos a añadir una **configuración** extra a `~/.bashrc`:

  ```bash
  # >>> mamba initialize >>>
  # !! Contents within this block are managed by 'mamba  init' !!
  export MAMBA_EXE='/home/USUARIO/bin/micromamba  bin/micromamba';
  export MAMBA_ROOT_PREFIX='/home/USUARIO/bin/micromamba micromamba';
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash  --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
  else
      alias micromamba="$MAMBA_EXE"
  fi
  unset __mamba_setup
  # <<< mamba initialize <<<
  ```

  Aplica los cambios:

  ```bash
  source ~/.bashrc
  ```

* Ahora ya podemos utilizar micromamba invocándolo directamente por su nombre. Micromamba cuenta con un entorno `base` pre-instalado: podemos activarlo con `micromamba activate`. Cuando se haya activado aparecerá `(base)` a la izquierda de nuestra linea de comandos. Para salir, utiliza `micromamba deactivate`.
* Con esto ya tendríamos un entorno virtual, pero nosotros vamos a ir más allá, creando un entorno virtual personalizado con `micromamba create`:

  ```bash
  micromamba create -y -n bioenv python==3.12.0 pip twine -c conda-forge
  
  # Output esperado:
  #
  # Transaction finished
  # 
  # To activate this environment, use:
  # 
  #     micromamba activate bioenv
  # 
  # Or to execute a single command in this environment, use:
  # 
  #    micromamba run -n bioenv mycommand
  ```
  
  Vamos a explicar cada parámetro en profundidad:
  -  `-y` sirve para no tener que confirmar la instalación
  - `-n` se usa para asignar el **nombre del entorno**
  - `python==3.12.0 pip twine` son los **paquetes iniciales** a instalar: en este caso especificamos `python` con la versión `3.12.0` y `pip`. 
  - `-c` indica el **channel o canal** donde va a buscar los paquetes.

  **Podemos establecer tantos paquetes iniciales como queramos**, siempre que estén disponibles en los canales de conda configurados. <br>Iniciemos nuestro entorno virtual:
  
  ```bash
  micromamba activate bioenv
  ```
  
  ¡Felicidades! Tus paquetes ahora están aislados del   sistema global. Verás `(bioenv)` añadido en la esquina   izquierda del prompt de tu terminal como indicador de que   el entorno está activado. <br>Puedes probar `pip list`   ahora, ya que estará disponible dentro del entorno   virtual. Esto listará todos los paquetes instalados con   pip. Intenta hacer lo mismo en el anterior virtualenv   `bioenv` para ver qué ocurre (*pista: primero necesitarás   salir con `micromamba deactivate`*).
  
  <br>Veamos si `seqkit` está disponible en pip o micromamba para poder instalarlo:
  Pip no tiene un comando oficial para buscar un paquete, debes ir a su página web y usar el navegador para encontrarlo [https://pypi.org/search](https://pypi.org/  search). Es crucial inspeccionarlo antes de instalar, ya que podría haber un paquete con el mismo nombre que el que quieres pero con diferente funcionalidad.
  **Ejemplo**: `taranis` en pip es un wrapper de una API   meteorológica, pero en bioconda es un pipeline para wg/cgMLST allele calling.
  
  <br>`Seqkit` no está disponible a través de pip, por lo que nuestra mejor opción es instalarlo con micromamba.
  
  * Veamos si `seqkit` está disponible en micromamba:
  
  ```bash
  micromamba search seqkit
  Getting repodata from channels...

  # nodefaults/  # linux-64                                         Using   # cache
  # nodefaults/  # noarch                                           Using   # cache
  # conda-forge/noarch                                  22.3MB   # @  31.6MB/s  0.6s
  # conda-forge/linux-64                                47.0MB   # @  51.1MB/s  0.9s
  # No entries matching "seqkit" found
  # Try looking in a different channel with '-c, --channel'.
  ```
  
  Como puedes ver no aparece. Esto es debido a que seqkit solo se encuentra disponible en [https://conda.anaconda.org/bioconda](https://conda.anaconda.org/bioconda). Esto significa que si no tenemos el canal `bioconda` añadido a nuestra configuración, no podremos descargarlo con micromamba.
  
  <br>- Puedes comprobar la lista de canales accesibles con:
  
  ```bash
  micromamba config get channels
  ```
  
  Podrías ver algo como lo siguiente:
  
  ```bash
  channels:
      - conda-forge
      - nodefaults
  ```

  Vamos a indicarle que busque el paquete en `bioconda`:
  ```bash
  micromamba install seqkit -c bioconda
  ```
  
  Si quieres **añadir un canal por defecto**, puedes hacerlo modificando la sección `channels` en el archivo de configuración `~/.condarc` que deberías tener en tu directorio home. Es un archivo oculto, por lo que necesitarás `ls -a` para verlo.
  Tras modificarlo, debería quedar así:
  ```bash
  channels:
      - conda-forge
      - nodefaults
      - bioconda
  ```
  Ahora ya no tendrás que indicar bioconda como canal al instalar ya que lo usará por defecto. <br><br>

  Como práctica, vamos a **eliminar el canal bioconda** e intentar reinstalar `seqkit`:
  
  1. Elimina `- bioconda` de la sección `channels` en `~/.  condarc`
  2. Ejecuta `micromamba remove seqkit` para desinstalarlo
  3. Reinstala `seqkit` con micromamba
  
  Bueno bueno, ahora parece que `seqkit` ya no está   disponible.
  
  Para continuar con la siguiente sección, **vuelve a añadir   el canal bioconda** e **instala seqkit otra vez** por tu   cuenta.
  
  * **Consejo**: si quieres instalar paquetes de   Python, usa `pip install` ya que es el repositorio de   paquetes de Python más grande, pero para herramientas más   complejas como `bedtools` utiliza **micromamba** o   **conda**.


---

## 2.1 Cómo compartir entornos virtuales entre usuarios del HPC

* Con micromamba:

  * Configura `.condarc` para utilizar el mismo directorio de entornos que el resto de alumnos:

    ```bash
    nano ~/.condarc
    envs_dirs:
       - RUTA_POSIBLE/micromamba/envs
    ```

  * Buscar y activar `hpc_course_bioenv`:

    ```bash
    micromamba env list
    micromamba activate hpc_course_bioenv
    ```

  * Comparar con módulos del sistema:

    ```bash
    module overview
    module load R/4.1.3
    R --help
    ```

  * Prueba a instalar un paquete con micromamba y pip, y observa las diferencias.

---

Aquí tienes la traducción al **español** manteniendo el estilo **markdown**:

---

## 3. Contenedores: Docker & Singularity

* **¿Por qué contenedores?**
  Portabilidad y reproducibilidad de entornos de software.

* **Práctica:**
  Desafortunadamente, no tenemos Docker disponible en nuestro HPC. **Singularity** es un buen reemplazo de Docker ya que gestiona contenedores y además está **específicamente diseñado para sistemas HPC**.

* En este ejercicio usaremos **bedtools** para convertir algunos archivos bam de nuevo a fastq. Busquemos un contenedor de Singularity con el software requerido:

```bash
singularity search bedtools
```

Espera, parece que Singularity no está disponible... Así es, porque para mantener la reproducibilidad los HPC no tienen tanto software instalado a nivel de sistema.
En nuestro caso, Singularity se accede a través de **módulos de EasyBuild**:

```bash
module load singularity
singularity search bedtools
```

Si quieres comprobar **qué módulos están activos** en tu sesión, puedes ejecutar `module list`.
Cuando termines de usar un módulo, puedes ejecutar `module unload <module_name>` para descargarlo de tu sesión, o `module purge` para descargar todos los módulos activos.

**¿Cómo listar los módulos accesibles en el HPC?**.
Para ello bastará con utilizar `module avail`. Si por otra parte queremos buscar módulos con un nombre concreto, podemos utilizar `module spider <module>` o `module keyword <module>`

---

#### Descargar y ejecutar un contenedor de Singularity:

Existen muchos repositorios de contenedores, siendo [https://hub.docker.com](https://hub.docker.com) el más común. Para herramientas bioinformáticas recomendamos:

* [galaxy index](https://depot.galaxyproject.org/singularity/)
* [biocontainers registry](https://biocontainers.pro/registry)
* [sequera containers](https://seqera.io/containers/)

El comando `singularity run` ya descarga la imagen antes de ejecutarla, lo cual usaremos en este ejercicio para correr un contenedor de bedtools directamente desde el repositorio de Galaxy.

**Cómo usar `singularity run/exec`:**

`singularity run` iniciará una sesión en el container y ejecutará la acción por defecto programada en él si la hubiere.

```bash
singularity run https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0 
# Ahora estaremos dentro del container, ya que esta imagen no tiene proceso de inicio.
# Podemos probar a lanzar fastp para ver que está disponible en el container 
fastp --help
exit # Salir del container. También con ctrl+D
```

En contraparte tenemos `singularity exec`, que permite configurar lo que queremos que se ejecute con el container, sin iniciar una sesión en él, pero aprovechándonos de todas las dependencias que se encuentren instaladas dentro. Ejemplo:

```bash
singularity exec https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0 fastp --help
```

Si queremos simplemente descargar la imagen para tenerla accesible en local, podemos utilizar `singularity pull`:

```bash
singularity pull <destination_file> https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0
```

Como ya sabéis, siempre es mejor lanzar los trabajos con `srun`. Lo mismo aplica para procesos con containers:

```bash
srun singularity exec --bind /scratch/RUTA_EJEMPLO https://depot.galaxyproject.org/singularity/bedtools:2.27.1--0 \
bedtools bamtofastq -i RUTA_EJEMPLO_ARCHIVO -fq RUTA_EJEMPLO_FASTQ 
```

Al hacer `--bind <PATH>`, lo que pongamos en `<PATH>` será accesible dentro del contenedor. Por defecto se incluye la carpeta en la que nos encontremos al momento de lanzar singularity.

#### Otros conceptos importantes sobre singularity.

* Para uso únicamente interactivo dentro de una imagen, ejecuta:

  ```bash
  singularity shell /path/to/image
  ```

* Puedes **configurar y crear tu propio contenedor vía web** fácilmente con [https://seqera.io/containers](https://seqera.io/containers).
  Solo busca cada dependencia y añádela a la lista, luego haz clic en **"Get Container"** y espera a que la imagen esté lista. Una vez completado, puedes usarla con:

  ```bash
  singularity run <container_url>
  ```

* Si quieres aprender más sobre cómo crear tu propio contenedor, recomendamos revisar la documentación de [singularity build](https://docs.sylabs.io/guides/3.0/user-guide/build_a_container.html) y [docker build](https://docs.docker.com/get-started/workshop/02_our_app/) para conocer todas las especificaciones necesarias.
