# Introducción a Linux

Linux es un sistema operativo, de código abierto, multi-tarea y multi-usuario.

## 1. Sistema Operativo Linux

## 1.1. ¿Qué es un sistema operativo?

Un sistema operativo por definición es el **software** principal de un sistema informático que gestiona los recursos de hardware y provee servicios a los programas de aplicación de software.

- El hardware como su propio nombre indica es lo duro (viene a ser la caja, el ordenador en sí y la pantalla o el ratón) y este se relaciona directamente con el sistema operativo.
- El usuario somos nosotros, y nosotros lo que hacemos en el ordenador es usar aplicaciones, como Word o Chrome.
- Estas aplicaciones se relacionan directamente con el sistema operativo, pero para funcionar necesitan los recursos del hardware como la memoria, de forma que el sistema operativo es el intermediario entre las aplicaciones y el hardware.

Un ejemplo sería que nosotros queremos abrir el Word y el Word le dice al sistema operativo que necesita que el monitor despliegue una ventana, entonces el sistema operativo le dice al hardware que es la caja y el monitor que desplieguen esa ventana. 
De forma que hay una relación uno a uno entre los distintos elementos.

"Linux es como el director de una orquesta que coordina todos los instrumentos (programas, recursos del sistema), y permite que varias personas toquen al mismo tiempo."

### Funciones del sistema operativo

Un sistema operativo controla procesos, gestiona recursos como la memoria y el almacenamiento, y ofrece una interfaz para interactuar con el sistema, que en el caso de Linux suele ser mediante una **línea de comandos** (shell), aunque también existen entornos gráficos. Sus funciones principales incluyen:

- **Ejecución, control y supervisión de los programas**: El sistema operativo se encarga de iniciar (o "lanzar") los programas que el usuario o el sistema necesitan. Además, supervisa su funcionamiento, gestiona los recursos que utilizan (como memoria o tiempo de procesador) y permite que se ejecuten varios programas al mismo tiempo (multitarea), asegurando que no interfieran entre sí.
- **Administración de periféricos (dispositivos de entrada y salida)**: Controla el funcionamiento de los dispositivos conectados al ordenador, como el ratón, el teclado, la pantalla, impresoras, discos duros, puertos USB, etc. El sistema operativo traduce las acciones del usuario (como mover el ratón o pulsar una tecla) en señales que el sistema puede interpretar y actuar en consecuencia.
- **Gestión de usuarios y permisos**: En entornos multiusuario, el sistema operativo permite que varias personas usen el mismo ordenador, cada una con su propio perfil y nivel de acceso. Esto es esencial para la seguridad y el orden, ya que impide que un usuario modifique archivos de otro sin autorización. También se puede controlar qué usuarios tienen permisos de administración y cuáles no.
- **Gestión de errores y seguridad**: El sistema operativo detecta errores durante la ejecución de programas o en el hardware (por ejemplo, cuando un dispositivo no responde o hay un fallo de memoria). Además, incluye mecanismos para proteger el sistema frente a accesos no autorizados, malware, y errores del usuario. Esto incluye el uso de contraseñas, actualizaciones de seguridad, y restricciones de acceso a archivos o programas.

### Componentes del sistema operativo

El sistema operativo está compuesto por tres partes esenciales que trabajan en conjunto para permitir el funcionamiento del ordenador y la interacción con el usuario. Estos componentes son: el kernel, el sistema de ficheros, y la shell o terminal.

#### Kernel

El kernel (o núcleo) es el corazón del sistema operativo. Es un software que actúa como intermediario entre el hardware del ordenador y el resto del sistema. Sus funciones principales incluyen:

- Gestionar los recursos del sistema, como la memoria, el tiempo del procesador (CPU), y los dispositivos de entrada/salida.
- Coordinar la ejecución de procesos y garantizar que cada programa tenga acceso controlado a los recursos que necesita.
- Facilitar la comunicación con el hardware, traduciendo las órdenes del software en instrucciones que el hardware puede entender.

Es el componente que siempre está en funcionamiento, desde que el sistema se inicia hasta que se apaga.

#### Sistema de ficheros

El sistema de ficheros se encarga de organizar, almacenar y recuperar datos en los dispositivos de almacenamiento (como discos duros o memorias USB). Define cómo se estructuran las carpetas y archivos, cómo se accede a ellos y qué permisos tiene cada usuario o proceso.

Más adelante en el apartado 2 [File System](#file-system) exploraremos con detalle cómo funciona este sistema en Linux.

#### La shell

La shell es el programa que permite al usuario interactuar con el sistema operativo mediante comandos escritos. Es una interfaz basada en texto que traduce las órdenes del usuario en instrucciones que el sistema puede ejecutar.
En Linux, una de las shells más comunes es Bash. A través de ella, se pueden:

- Navegar por el sistema de archivos.
- Ejecutar programas y scripts.
- Gestionar procesos.
- Administrar usuarios y permisos.
- Automatizar tareas repetitivas.

La terminal es la aplicación gráfica que permite acceder a esta shell. Aunque hoy en día existen entornos gráficos (ventanas, menús, botones), la terminal sigue siendo una herramienta muy poderosa y flexible, especialmente en entornos de alta computación y servidores.

Más adelante en el [apartado 3](#comandos-basicos) desarrollaremos un poco más de información acerca de la Shell de Linux.

### Sistemas operativos

En el mercado existen distintos sistemas operativos, de los cuales los más conocidos son:

- Windows de Microsoft, que es el líder del mercado
- MacOS de Apple, que sería el segundo más conocido
- Y el tercero es GNU/Linux

#### GNU/Linux

GNU (acrónimo de “**G**NU’s **N**ot **U**nix”) es un proyecto iniciado por Richard Stallman en 1983 con el objetivo de crear un sistema operativo completamente libre, compatible con Unix. Stallman y su comunidad desarrollaron:

- Un shell → Bash
- Un compilador → GCC (GNU Compiler Collection)
- Herramientas de sistema → ls, cp, mv, cat, ps, etc.
- Librerías esenciales → glibc
- Utilidades para editar texto, scripts, depurar, comprimir archivos, etc.

Linus Torvalds publicó su kernel en 1991, y como todavía no existía un kernel funcional y libre en el proyecto GNU (el suyo, Hurd, no estaba listo), los desarrolladores unieron el kernel de Linux con las herramientas del proyecto GNU y crearon un sistema operativo funcional: lo que hoy se llama popularmente "Linux", aunque el nombre completo sería más correcto como GNU/Linux.

## 1.2. Código abierto

Linux es un **software libre y de código abierto**, de forma que cualquiera puede acceder al código fuente, modificarlo y redistribuirlo según las condiciones de la licencia GPL (General Public License).

Gracias a esta licencia, Linux no es solo un producto tecnológico, sino también el resultado de una colaboración global entre desarrolladores y comunidades que contribuyen de forma abierta, sin una coordinación central estricta pero con objetivos comunes.

Para que un software sea considerado verdaderamente de código abierto, su licencia debe cumplir una serie de principios fundamentales:

1. **Libre redistribución**: El software puede compartirse libremente. No se puede tomar un programa gratuito, cambiar su nombre y venderlo con restricciones.
2. **Acceso al código fuente**: El código fuente debe estar incluido o ser fácilmente accesible, permitiendo su estudio y modificación por parte de los usuarios.
3. **Permiso para trabajos derivados**: Se pueden crear versiones modificadas y distribuirlas bajo los mismos términos que el original.
4. **Integridad del autor**: Las licencias pueden exigir que los trabajos derivados tengan nombres distintos o números de versión diferentes. Esto protege tanto a los usuarios (que saben qué están usando) como a los autores originales.
5. **No discriminación de personas o grupos**: Cualquier persona, sin importar su origen, tiene derecho a usar el software.
6. **No discriminación por áreas de uso**: El software puede usarse en cualquier ámbito, incluyendo negocios, educación, investigación, etc.
7. **Distribución automática de derechos**: Todos los usuarios reciben los mismos derechos al redistribuir el software, sin necesidad de nuevas licencias.
8. **Neutralidad respecto a productos**: El uso del software no puede estar condicionado a formar parte de un paquete o producto específico.
9. **Sin restricciones a otros programas**: El software puede distribuirse junto a otros programas (libres o propietarios) sin imponer restricciones adicionales.
10. **Neutralidad tecnológica**: La licencia no debe depender de tecnologías o interfaces particulares.

## 1.3. Distribuciones

Gracias a los principios del software de código abierto, especialmente la libre redistribución, el acceso al código fuente y la posibilidad de crear trabajos derivados, es posible que múltiples comunidades y organizaciones desarrollen sus propias distribuciones de Linux.

Una distribución (coloquialmente llamada distro) es una distribución de software basada en el kernel de Linux que incluye determinados paquetes de software para satisfacer las necesidades de un grupo específico de usuarios, dando así origen a ediciones domésticas, empresariales y para servidores. 

Además del núcleo o kernel de Linux, las distribuciones incluyen habitualmente las librerías y herramientas del proyecto GNU, software adicional, documentación, un sistema de ventanas, un gestor de ventanas y un entorno de escritorio. Dependiendo del tipo de usuarios a los que la distribución esté dirigida se incluye también otro tipo de software como procesadores de texto, hoja de cálculo, reproductores multimedia, herramientas administrativas, etc. 

Por lo general están compuestas, total o mayoritariamente, de software libre, aunque a menudo incorporan aplicaciones o controladores propietarios.

Algunas de las distribuciones más populares son:

- Ubuntu: Amigable para principiantes, muy utilizada en escritorios y entornos educativos.
- Debian: Base de muchas otras distribuciones, conocida por su estabilidad.
- Fedora: Promovida por Red Hat, orientada a usuarios que buscan tecnología de vanguardia.
- Arch Linux: Enfocada a usuarios avanzados, ofrece control total sobre la configuración del sistema.
- CentOS / Rocky Linux / AlmaLinux: Alternativas comunitarias a Red Hat Enterprise Linux (RHEL), orientadas a servidores.

La distribución que tiene el HPC del ISCIII es CentOS Stream release 8

## 1.4. Multi-tarea

Linux es multi-tarea, por lo que permite ejecutar múltiples tareas simultáneamente.

Un sistema operativo multitarea es aquel que permite ejecutar varios programas o procesos al mismo tiempo. Esto no significa que el procesador realmente haga muchas cosas a la vez, sino que gestiona el tiempo de manera tan eficiente que da la impresión de simultaneidad.

Enn un ordenador tienes PowerPoint abierto, el navegador Firefox y el calendario. Aparentemente, los tres programas están activos a la vez. Pero lo que realmente ocurre es que el procesador cambia rápidamente de una tarea a otra, dedicando lapsos de tiempo muy breves a cada una. Es tan rápido (a veces miles de veces por segundo) que tú no notas las pausas. Este sistema se llama "planificador de procesos", y lo organiza el sistema operativo.

Imagina una película antigua: no es un vídeo continuo, sino una sucesión de fotogramas estáticos. Al pasar muy rápido de uno a otro, nuestro cerebro interpreta movimiento. Con la multitarea pasa lo mismo: el sistema operativo va alternando entre tareas, pero lo hace tan velozmente que parece que todo funciona al mismo tiempo.

El sistema operativo:

- **Mantiene el estado de cada tarea**: Sabe en qué punto estábamos en PowerPoint, Firefox o el calendario, y retoma desde ahí al volver a activarla.
- **Administra recursos**: Decide qué proceso usa el procesador, cuál accede al disco o qué ventana está activa.
- **Evita conflictos**: Se asegura de que las tareas no interfieran entre sí ni se "pisen" datos.

La multitarea es aún más crucial en entornos HPC donde el sistema operativo debe gestionar cientos de procesos de diferentes usuarios y aplicaciones, optimizando recursos de forma eficiente y segura.

## 1.5. Multi-usuario

Linux es multi-usuario, es decir, soporta varios usuarios conectados al mismo tiempo, con distintos permisos y configuraciones

Un sistema operativo multiusuario es un tipo de software que permite que varias personas accedan y utilicen un mismo sistema informático, ya sea de forma simultánea o secuencial, sin interferencias entre ellas.

- Tiene su propio nombre de usuario (login) y una contraseña.
- Dispone de permisos específicos sobre archivos, programas o recursos del sistema.
- Puede ejecutar tareas sin afectar directamente a las de otros.

En sistemas de computación de alto rendimiento (HPC), la capacidad multiusuario es esencial:

- Decenas o cientos de usuarios trabajan simultáneamente en el mismo clúster.
- Cada usuario ejecuta procesos, analiza datos y accede a software especializado.
- El sistema operativo garantiza que cada sesión, archivo o proceso esté aislado y protegido, sin interferir con otros usuarios.

## 2. File system

El File System o Sistema de Archivos es uno de los tres componente que configuran el sistema operativo, como vimos anteriormente.

### 2.1. Características

Un sistema de archivos es el componente del sistema operativo que organiza, almacena y recupera datos en un dispositivo de almacenamiento como un disco duro, SSD, pendrive o servidor.

El sistema de archivos es lo que le da estructura a los datos. Permite:

- Guardar archivos y carpetas de forma organizada.
- Acceder a ellos por su nombre, ruta y permisos.
- Controlar quién puede leer, modificar o ejecutar cada archivo.

Cuando guardas un archivo (por ejemplo, un documento de texto), el sistema de archivos:

- Lo divide en bloques físicos que se almacenan en el disco.
- Asocia metadatos (nombre, fecha, permisos, tamaño, propietario).
- Lo ubica en una jerarquía de carpetas para facilitar su localización.

También gestiona:

- Permisos y propiedad
- Tiempos de acceso/modificación
- Espacio libre y ocupado
- Integridad y recuperación ante errores

Otras características: 

- La estructura de ficheros de Linux es una estructura jerárquica en forma de árbol invertido, donde el directorio principal (directorio raíz) es el directorio `/`, del que cuelga toda la estructura del sistema. 
- Todo tiene rutas, que hay que especificar
- En Linux, todo son archivos, tanto los archivos de texto, como los directorios o carpetas, como los dispositivos que están conectados al ordenador, todo está representado como si fueran archivos. ¿Por qué se hace esto?
  - Porque tratarlo todo como ficheros simplifica la programación y el uso del sistema:
  - Se puede usar el mismo conjunto de comandos y funciones para trabajar con todo tipo de recursos.
  - Un desarrollador o administrador puede leer datos de un dispositivo igual que leería de un archivo de texto.
  - Permite que tuberías y redirecciones funcionen de forma uniforme (por ejemplo: redirigir la salida de un programa a un fichero, a otro programa o a un dispositivo).
- Además, no existe el concepto de extensiones y existen los archivos ocultos.

### 2.2 Estructura

Como mencionabamos antes, el sistema de archivos de Linux está organizado en forma de árbol jerárquico invertido, comenzando en la parte superior con el directorio raíz, representado por `/`.

Desde este punto se ramifican todos los demás directorios y archivos del sistema. Esta estructura permite una organización lógica, eficiente y modular de todos los componentes del sistema operativo, así como los archivos de los usuarios.

- `/` (Root (Raíz)): Es el punto de partida del sistema de archivos. Todos los demás archivos y carpetas están contenidos o enlazados desde aquí. Es el núcleo de la jerarquía.
- `/bin` (Binary): Contiene programas ejecutables esenciales, necesarios tanto para el sistema como para todos los usuarios. Son comandos básicos que se deben poder ejecutar incluso en modo de rescate o sin montar otras particiones.
- `/usr` (User system resources): Contiene programas y utilidades de uso general para los usuarios. Dentro de `/usr` también hay subdirectorios como:
    - `/usr/bin`: comandos no esenciales para todos los usuarios.
    - `/usr/sbin`: herramientas administrativas.
    - `/usr/lib`: bibliotecas compartidas.
- `/var` (Variable): Contiene archivos cuyo contenido cambia con el tiempo:
    - Logs del sistema (/var/log)
    - Bases de datos temporales
    - Correos electrónicos del sistema
    - Cachés
    - Archivos de spool (como colas de impresión o correos)
- `/etc`: Configuraciones del sistema y servicios.
- `/root`: Directorio personal del superusuario (root).
- `/sbin`: Comandos del sistema usados por el administrador.
- `/tmp`: Archivos temporales (borrados al reiniciar).
- `/dev`: Archivos especiales que representan dispositivos del sistema.
- `/lib`: Bibliotecas compartidas necesarias para ejecutar comandos de /bin y /sbin.
- `/home`: Es un directorio donde se encuentran los directorios personales de los usuarios del sistema. Donde están las carpetas de cada usuario del ordenador con su escritorio.
- `/mnt` y `/media`:  Es el directorio que contiene todas las unidades físicas que tenemos montadas: discos duros, unidades de DVD, pen drives, etc.
- `/opt`: se utiliza para instalar software adicional que no forma parte del sistema base. En nuestro caso es donde se realiza la instalación del software bioinformático.

### 2.3. Comparción con windows

Organización:

- En Linux, todo el sistema de archivos se organiza como un único árbol jerárquico que parte desde un directorio raíz, representado por la barra `/`. Esto significa que no importa cuántas particiones o discos tenga el equipo, todos los elementos (discos, carpetas, archivos, dispositivos externos) se integran en ese único árbol de directorios bajo `/`. Por ejemplo, la carpeta `/home`, que es donde residen los archivos personales de los usuarios (similar a "Usuarios" en Windows), siempre cuelga del directorio raíz. Esto da una estructura más uniforme y predecible.
- En cambio, en Windows, los sistemas de archivos se organizan por unidades de disco, asignando una letra a cada partición o dispositivo (como C:\, D:\, E:\, etc.). Por eso, una carpeta como "Usuarios" puede estar en C:\ o en D:\, según cómo se haya configurado el sistema.

Otro punto importante es cómo se gestionan los dispositivos externos, como un CD, una memoria USB o un disco duro externo:

- En Linux, cuando conectas un dispositivo, este se “monta” dentro del sistema de archivos, lo que significa que se le asigna un punto de acceso dentro del árbol. Por convención, los dispositivos suelen montarse en el directorio `/mnt` (de mount, montar) o en `/media`. Esto permite acceder al contenido del dispositivo como si fuese parte del mismo sistema de archivos.
- En Windows, cuando conectas un dispositivo, el sistema le asigna una nueva letra de unidad (por ejemplo, E:\), y lo muestra en el explorador de archivos bajo “Este equipo” (antes “Mi PC”), como si fuera un disco independiente.

Esta diferencia refleja filosofías distintas: Linux apuesta por una organización unificada y coherente, mientras que Windows se basa en una estructura modular por unidades, más intuitiva para el usuario general pero menos flexible para administradores y servidores.

### 2.4. Rutas

En los sistemas operativos como Linux, cada archivo o carpeta tiene una “dirección” que indica dónde se encuentra dentro del sistema. Esta dirección se llama ruta (o path, en inglés), y se expresa como una secuencia de directorios separados por barras (/) que debemos recorrer para llegar hasta el archivo deseado.

Como veniamos viendo, Linux organiza su sistema de archivos como un árbol jerárquico que comienza en el directorio raíz, representado por `/`. A partir de ahí, se ramifican todas las carpetas y archivos del sistema. Esta estructura nos permite acceder a los archivos utilizando dos tipos de rutas:

- **Ruta absoluta**:
  - La ruta absoluta comienza siempre desde el directorio raíz (/) y describe el camino completo hasta un archivo, sin importar en qué carpeta estemos actualmente. Siempre es la misma, porque parte desde la base del sistema.
  - Ejemplo: `/home/alumno1/dir1/libro.txt`
    - Esta ruta va desde el directorio raíz, entra en home, luego en alumno1, luego en dir1, y finalmente llega al archivo libro.txt.
- **Ruta relativa**:
  - La ruta relativa parte desde el directorio en el que nos encontramos actualmente. Por eso, cambia según nuestra ubicación dentro del sistema de archivos.
    - `.` (punto) representa el directorio actual.
    - `..` (dos puntos) representa el directorio padre (el nivel superior).
  - Ejemplos:
    - Si estamos en `/home`, la ruta relativa sería: `./alumno1/dir1/libro.txt` o `alumno1/dir1/libro.txt`
    - Si estamos en `/home/alumno1`, podemos escribir simplemente: `dir1/libro.txt` o `./dir1/libro.txt`
    - Si estamos ya dentro de `dir1`: `libro.txt` o `./libro.txt`

Comprender cómo funcionan las rutas en Linux es fundamental para poder navegar por el sistema de archivos, ejecutar comandos correctamente y trabajar de forma eficiente desde la terminal.

## 3. Comandos básicos de linux

### 3.1. Shell

La shell es el programa que interpreta los comandos que escribimos. Es como un "intérprete" entre nosotros y el sistema operativo. Hay varios tipos de shell, pero una de las más comunes en Linux es Bash.

En Linux, la forma de comunicarse con el sistema operativo es a través de la línea de comandos. A diferencia de los entornos gráficos, que permiten hacer clic en iconos o menús, la línea de comandos nos permite dar instrucciones precisas y controlar el sistema a un nivel más profundo. Esta interacción se realiza en un entorno llamado terminal. La terminal es la aplicación gráfica que permite acceder a esta shell, y es especialmente importante en entornos como servidores, sistemas sin interfaz gráfica o infraestructuras HPC, donde la línea de comandos es la herramienta principal de trabajo. Aunque hoy en día existen entornos gráficos (ventanas, menús, botones), la terminal sigue siendo una herramienta muy poderosa y flexible, especialmente en entornos de alta computación y servidores.

En Linux, una de las shells más comunes es Bash. A través de ella, se pueden:
- Navegar por el sistema de archivos.
- Ejecutar programas y scripts.
- Gestionar procesos.
- Administrar usuarios y permisos.
- Automatizar tareas repetitivas.

### 3.2. Prompt

El prompt es el mensaje que aparece en la línea de comandos cuando abrimos una terminal. Es la señal visual que nos indica que el sistema está listo para recibir instrucciones. En otras palabras, es el punto de entrada entre el usuario y el sistema operativo a través de la shell.

Un prompt típico puede tener este aspecto:

```bash
[user@machine ~]$
```
Este ejemplo nos da información importante:

- user → es el nombre del usuario que ha iniciado sesión.
- machine → es el nombre del equipo o host.
- ~ → representa el directorio personal del usuario (también llamado home).
- $ → indica que estamos usando un usuario normal (si fuese el usuario root, veríamos #).

Cada vez que escribimos un comando, lo hacemos después del prompt.

### 3.3. Comandos básicos

Para interactuar con el sistema operativo desde la terminal, utilizamos comandos: instrucciones que escribimos y que la shell interpreta para que el sistema las ejecute. Estos comandos permiten navegar por el sistema de archivos, manipular archivos y carpetas, ejecutar programas, gestionar usuarios y procesos, y automatizar tareas repetitivas.

Conocer los comandos básicos es fundamental para cualquier persona que utilice Linux, especialmente si trabaja en servidores remotos o sistemas sin entorno gráfico.

Los comandos que le podemos dar a la terminal para que nos ofrezca resultados y que siempre tenéis que recordar son:

- `pwd` (Print Working Directory): Nos muestra en qué directorio estamos actualmente.

```bash
[user@machine ~]$ pwd
/home/user
```

> Esto indica que estamos en el directorio personal del usuario s.varona.

- `ls` (List): Muestra una lista del contenido de un directorio.

```bash
[user@machine ~]$ ls
Documentos  Descargas  imagen.png  script.sh
```

> Vemos los archivos y carpetas que hay en nuestro directorio actual.

- `cd` (Change Directory): Nos permite movernos entre directorios

```bash
[user@machine ~]$ cd Documentos
[user@machine ~/Documentos]$ pwd
/home/user/Documentos
[user@machine ~/Documentos]$ cd ..
[user@machine ~]$ pwd
/home/user/
```
>  Primero estamos dentro de la carpeta Documentos y después nos movemos al directorio anterior con `..`

- `mkdir` (Make Directory): Sirve para crear nuevos directorios (si tenemos permisos).

```bash
[user@machine ~]$ ls
Documentos  Descargas  imagen.png  script.sh
[user@machine ~]$ mkdir Carpeta_Prueba
[user@machine ~]$ ls
Carpeta_Prueba Documentos  Descargas  imagen.png  script.sh
```

> Hemos creado una carpeta llamada `Carpeta_prueba`.

- `rm` (Remove): Borra archivos. ⚠️ ¡Cuidado! No pide confirmación por defecto.

```bash
[user@machine ~]$ ls
Carpeta_Prueba Documentos  Descargas  imagen.png  script.sh
[user@machine ~]$ rm imagen.png
[user@machine ~]$ ls
Carpeta_Prueba Documentos  Descargas  script.sh
```

> Hemos borrado el archivo `imagen.png`

- `rmdir` (Remove Directory): Permite borrar directorios vacíos.

```bash
[user@machine ~]$ ls
Carpeta_Prueba Documentos  Descargas   script.sh
[user@machine ~]$ rmdir Carpeta_Prueba
[user@machine ~]$ ls
Documentos  Descargas  script.sh
```

> Hemos borrado la carpeta `Carpeta_Prueba`

- `cp` (Copy): Permite copiar archivos o carpetas de un lugar a otro.

```bash
[user@machine ~]$ ls
Documentos  Descargas   script.sh
[user@machine ~]$ cp script.sh copia_script.sh
[user@machine ~]$ ls
copia_script.sh  Documentos  Descargas  script.sh
```

>  Aquí hemos copiado el archivo `script.sh` a `copia_script.sh`

- `mv` (Mover): Sirve tanto para mover archivos a otra ubicación como para cambiarles el nombre.

```bash
[user@machine ~]$ ls
copia_script.sh  Documentos  Descargas  script.sh
[user@machine ~]$ mv copia_script.sh script_de_pruebas.sh
[user@machine ~]$ ls
Documentos  Descargas  script.sh script_de_pruebas.sh
[user@machine ~]$ mv script_de_pruebas.sh Documentos/
[user@machine ~]$ ls
Documentos  Descargas  script.sh
[user@machine ~]$ ls Documentos
script_de_pruebas.sh
```

> Primero hemos renombrado `copia_script.sh` a `script_de_pruebas.sh` y luego lo hemos movido a la carpeta `Documentos`

- `history` (Historial): Muestra los últimos comandos ejecutados por el usuario en esa sesión (o anteriores).

```bash
[user@machine ~]$ history
1 ls
2 mv copia_script.sh script_de_pruebas.sh
3 ls
4 mv script_de_pruebas.sh Documentos/
5 ls
6 ls Documentos
7 history
```

> Muy útil para repetir comandos anteriores o para revisar qué hiciste.

- `less` (Menos): Ver el contenido de un archivo

```bash
[user@machine ~]$ ls
Carpeta_Prueba Documentos  Descargas   script.sh
[user@machine ~]$ less script.sh
#!/bin/bash
echo "Hola mundo"
```

> Puedes moverte con las flechas o q para salir.

- `nano` (Editor de texto simple): Nos permite editar archivos desde la terminal.

```bash
[user@machine ~]$ nano script.sh
```

> Se abre una interfaz de edición dentro del terminal. Para guardar, pulsa Ctrl+o y luego intro. Para salir puls Ctrl+x.

## 4. Sintaxis de la linea de comandos

### 4.1. Sintaxis

Usar la terminal no es solo escribir comandos al azar. Como cualquier lenguaje, tiene una sintaxis (unas reglas) que debemos seguir para que el sistema entienda lo que queremos hacer.

La estructura general de un comando es:

```bash
comando [opciones o parámetros] [argumentos]
```

- Comando: La instrucción principal que le damos al sistema.
- Parámetro (opción): Modifica el comportamiento del comando. Suele empezar con - o --. Los parámetros se indican con guiones:
  - Cortos: -l, -a, -h
  - Largos: --help, --version
- Argumento: Es el objeto sobre el que actúa el comando. Por ejemplo, un archivo, una carpeta o una ruta.
  - Para algunos comandos el argumento de archivo es obligatorio (como el de mover o leer un archivo)

Ejemplos:
- `ls -l -a`: Tiene dos parámetros
  - `-l`: Indica que se haga el listado en formato largo
  - `-a`: Indica que se haga el listado incluyendo archivos ocultos
- `cp archivo1.txt copia.txt`: Tiene dos argumentos, donde **el orden importa**:
  - archivo1.txt: El archivo de origen, siempre va primero
  - copia.txt: El archivo de destino siempre va segundo


### 4.2. Input/Output

Cuando usamos comandos en la terminal, siempre hay una entrada (input) y una salida (output). Esta comunicación entre el usuario, el sistema operativo y los comandos se basa en un modelo de entrada/salida muy flexible.

- **Entrada estándar** (Standard Input - stdin): Es la información que el comando recibe. Por defecto, es el teclado (lo que tú escribes).

Por ejemplo:

```bash
cat
```

> Al ejecutar cat sin argumentos, el comando espera que escribas algo. Cada línea que introduces se convierte en la entrada. Para salir, puedes usar Ctrl + D.

- **Salida estándar** (Standard Output - stdout): Es la información que el comando devuelve. Por defecto, se muestra en la pantalla.

```
echo "Hola mundo"
```

> El comando echo imprime la salida Hola mundo en pantalla.

### 4.3. Redirigir

En Linux, puedes redirigir estas salidas y entradas para controlar mejor lo que hacen los comandos.

- Redirigir **la salida estándar a un archivo**:

```bash
echo "Hola mundo" > saludo.txt
```
> Crea un archivo llamado saludo.txt con el contenido Hola mundo.

- **Añadir** (en vez de sobrescribir) a un archivo:

```bash
echo "Otra línea" >> saludo.txt

```
> Añade una línea al final del archivo sin borrar lo anterior.

- Redirigir **la entrada estándar desde un archivo**

```bash
cat < saludo.txt
```
> Lee el contenido de saludo.txt como si lo estuvieras escribiendo tú.

- **Redirigir errores**: Puedes redirigir la salida de error (stderr) con 2>:

```
cat archivo_que_no_existe.txt 2> error.txt
```

> El mensaje de error (si lo hubiera) se guarda en error.txt en lugar de mostrarse en pantalla.

- Redirigir **salida y error al mismo archivo**

```bash
cat archivo_que_no_existe.txt > salida.txt 2>&1
```

> Esto guarda tanto stdout como stderr en el mismo archivo.


### 4.4. Pipes

Un pipe (símbolo |) en Linux es una herramienta que permite conectar la salida de un comando con la entrada de otro. Esto nos permite encadenar comandos para realizar operaciones más complejas de forma sencilla. Piensa en un pipe como un tubo que transporta datos de un comando a otro:

```bash
[Comando A] --salida--> | --entrada--> [Comando B]
```

En lugar de mostrar la salida en pantalla, se la pasa directamente al siguiente comando.

_Por ejemplo_:

```bash
ls | sort
```

> ls lista los archivos del directorio actual.
> sort ordena esa lista alfabéticamente.
> El resultado es la lista de archivos ordenada.

_Otro ejemplo_: filtrar con grep

```
cat archivo.txt | grep "palabra"
```

> cat muestra el contenido de archivo.txt.
> grep filtra las líneas que contienen "palabra".
> Se muestran solo las líneas coincidentes.

_Otro ejemplo_: contar con wc

```
ls | wc -l
```

> ls lista los archivos.
> wc -l cuenta el número de líneas (es decir, cuántos archivos hay).
Z Devuelve el número total de archivos.

Los pipes solo conectan la salida estándar (stdout) con la entrada estándar (stdin).

# 5. Usuarios y privilegios

## 5.1. Usuarios

Un usuario en Linux es una entidad con acceso a recursos del sistema: archivos, programas, dispositivos, etc. Cada usuario tiene:

- Un nombre de usuario (username)
- Un identificador de usuario (UID)
- Un grupo principal (GID)
- Un directorio personal (por ejemplo, /home/user)
- Un intérprete de comandos (shell, como /bin/bash)

Existen dos tipos de usuarios:

- Los usuarios normales:
  - Tienen acceso limitado.
  - Solo pueden modificar archivos de su propio directorio.
  - No pueden cambiar configuraciones del sistema.
- Usuario root:
  - Es el administrador del sistema.
  - Tiene acceso total a todos los archivos y comandos.
  - Puede instalar programas, borrar cualquier archivo, crear usuarios, etc.
 
Un grupo es un conjunto de usuarios. Se usan para gestionar permisos colectivos. Ejemplo: si varios usuarios necesitan acceder a un proyecto común, puedes añadirlos al mismo grupo.

Algunas caracteristicas:
- Los usuarios están asociados a una persona o proceso de computación
- Todos los usuarios pueden pertenecer a uno o más grupos
- Todos los usuarios tienen una carpeta propia dentro de la carpeta home
- Los usuarios son los dueños (es decir tienen permisos de owner) en todos los archivos que creados por ellos, directa o indirectamente
- Los usuarios pueden cambiar los permisos de los archivos que son suyos.
- Los usuarios poseen permisos sobre los procesos que ejecutan
- El super usuario root tiene permiso sobre todo. Esto es como los permisos de administrador, cuando queréis instalar algo en el ordenador windows del ISCIII y no os deja, es porque no sois el root del ordenador, es decir el administrador.
- Como todo usuario, root también tiene una carpeta home, pero la carpeta home del super usuario root esta en /root, no en /home

## 5.2. Permisos

Para ver los permisos y quien es el dueño de los archivos, tendremos que usar los comandos `ls –l` en la linea de comandos. Por ejemplo el resultado para la carpeta `Documentos` del home es:

```bash
drwxrwxr-x 2 s.varona s.varona 4096 Jul 24 19:58 Documentos
```

- Primero nos dice que es un directorio
- Después nos indica los permisos
- Luego nos indica un número que es el número de archivos que contiene es directorio. En el caso de que el fichero sea un archivo pondrá un 1.
- Nos indica el usuario propietario de la carpeta
- Nos indica el grupo de la carpeta
- Después te dice el tamaño del archivo que son 4096 bytes.
- Después te dice la fecha de la última modificación
- Por último te dice el nombre del directorio que es Documentos

Los permisos como su propio nombre indica son los derechos de los usuarios para actuar sobre los archivos o directorios. Existen tres tipos de permisos de actuación sobre los ficheros:

- **Permiso de lectura (r)**:
  - Estos permisos permiten a la persona que tiene permisos de lectura ver el contenido de los archivos.
  - En el caso de directorios, el permiso de lectura permite listar el contenido de los directorios.
- **Permisos de escritura (w)**:
  - Permite a los usuarios con este permiso modificar el contenido del archivo.
  - En el caso de los directorios, este permiso permite editar el contenido (los archivos del directorio)
- **Permisos de ejecución (x)**:
  - Permiten ejecutar o correr un archivo que contiene un programa o script.
  - Para el caso de los directorios, el permiso de ejecución permite moverte dentro del directorio y convertirlo en tu directorio actual (pwd).

La información de los permisos se almacena en el sistema como una secuencia de 9 bits en una estructura de tres grupos:

- La primera es para el propietario del fichero 
- La segunda secuencia es para el grupo del fichero
- Y la tercera es para los demás usuarios que no sean ni el propietario ni pertenezcan al grupo

Cada uno de los grupos tiene un apartado para los permisos de lectura, para los permisos de escritura y para los de ejecución.

Después de la secuencia de información de permisos te proporciona información sobre el propietario del fichero, el grupo al que pertenece el fichero y el nombre del fichero.

## 5.3. Cambiar permisos

Los permisos de un fichero solo pueden ser alterados por su propietario, los usuarios que pertenezcan al grupo y por el administrador. El super usuario puede cambiar los permisos de cualquier fichero del sistema.

Comandos para cambiar permisos: 
- `chmod` (change mode): Sirve para cambiar los permisos de acceso de un archivo o directorio.

```bash
chmod 755 archivo.sh
```
Este ejemplo le da:
- `rwx` al usuario (7 = 4 + 2 + 1)
- `rx` al grupo (5 = 4 + 0 + 1)
- `rx` a los demás (5 = 4 + 0 + 1)

- `chown` (change owner): Sirve para cambiar el propietario o el grupo asociado a un archivo.

```
chown s.vaorna:bi informe.txt
```

Este comando asigna el archivo informe.txt al usuario s.vaorna y al grupo bi.

Permisos en formato octal

Los permisos se representan en grupos de tres letras:

| Letra | Significado         | Valor |
|-------|---------------------|--------|
| r     | read (leer)         | 4      |
| w     | write (escribir)    | 2      |
| x     | execute (ejecutar)  | 1      |
| -     | sin permiso         | 0      |

Cada grupo (usuario, grupo, otros) se traduce a un número del 0 al 7, sumando los valores.

Por ejemplo:

- rwx = 4 + 2 + 1 = 7
- rw- = 4 + 2 + 0 = 6
- r-- = 4 + 0 + 0 = 4

Entonces, los permisos rwxr-xr-x se representan como:

```bash
chmod 755 archivo.txt
```
