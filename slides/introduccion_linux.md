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

## 2.1. Características

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

## 2.2 Estructura

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

## 2.3. Comparción con windows

Organización:

- En Linux, todo el sistema de archivos se organiza como un único árbol jerárquico que parte desde un directorio raíz, representado por la barra `/`. Esto significa que no importa cuántas particiones o discos tenga el equipo, todos los elementos (discos, carpetas, archivos, dispositivos externos) se integran en ese único árbol de directorios bajo `/`. Por ejemplo, la carpeta `/home`, que es donde residen los archivos personales de los usuarios (similar a "Usuarios" en Windows), siempre cuelga del directorio raíz. Esto da una estructura más uniforme y predecible.
- En cambio, en Windows, los sistemas de archivos se organizan por unidades de disco, asignando una letra a cada partición o dispositivo (como C:\, D:\, E:\, etc.). Por eso, una carpeta como "Usuarios" puede estar en C:\ o en D:\, según cómo se haya configurado el sistema.

Otro punto importante es cómo se gestionan los dispositivos externos, como un CD, una memoria USB o un disco duro externo:

- En Linux, cuando conectas un dispositivo, este se “monta” dentro del sistema de archivos, lo que significa que se le asigna un punto de acceso dentro del árbol. Por convención, los dispositivos suelen montarse en el directorio `/mnt` (de mount, montar) o en `/media`. Esto permite acceder al contenido del dispositivo como si fuese parte del mismo sistema de archivos.
- En Windows, cuando conectas un dispositivo, el sistema le asigna una nueva letra de unidad (por ejemplo, E:\), y lo muestra en el explorador de archivos bajo “Este equipo” (antes “Mi PC”), como si fuera un disco independiente.

Esta diferencia refleja filosofías distintas: Linux apuesta por una organización unificada y coherente, mientras que Windows se basa en una estructura modular por unidades, más intuitiva para el usuario general pero menos flexible para administradores y servidores.

## 2.4. Rutas

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
