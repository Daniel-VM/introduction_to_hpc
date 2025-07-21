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


