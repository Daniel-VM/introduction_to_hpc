# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

BU-ISCIII

## Práctica 10: Casos Prácticos y Problemas conocidos

### Descripción

En esta práctica se trabajará con situaciones reales y problemas comunes que pueden aparecer en entornos de computación de alto rendimiento (HPC). El objetivo es aprender a identificar, diagnosticar y resolver incidencias, así como adoptar buenas prácticas en la gestión de recursos y ejecución de trabajos.

### Ejercicios

#### 1. Reservar más recursos de los disponibles

Vamos a intentar reservar más recursos de los disponibles para comprobar cómo el trabajo no entra en cola.

Ejecutamos:

```bash

```

Observamos

```bash

```

Recomendaciones:


#### 2. Un trabajo utiliza más memoria de la solicitada

Vamos a ejecutar un trabajo que utilice más memoria de la solicitada para observar el comportamiento del sistema.

Ejecutamos:

```bash

```

Observamos:

```bash

```

Recomendaciones:

##### 3. Load average

Vamos a simular un **load average** elevado y analizar su impacto.

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 4. Interpreción de logs

Vamos a interpretar algunos logs generados por el sistema y por los trabajos

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 5. Ganglia

Vamos a ver como se puede emplear [**Ganglia**](http://ganglia.isciii.es/) como herramienta de diagnóstico y monitorización. Ganglia es una herramienta de monitorización y diagnóstico de sistemas, muy usada en entornos de HPC (High Performance Computing) y clústeres. Ganglia recopila métricas de cada nodo del clúster como: Uso de CPU, memoria, red, carga del sistema (load average), espacio en disco, y otras métricas personalizadas. Se visualiza a través de una interfaz web con gráficos históricos y en tiempo real. Para qué sirve:

- Detectar sobrecarga en un nodo.
- Ver tendencias de consumo de recursos.
- Diagnosticar cuellos de botella.
- Comprobar si los trabajos se están ejecutando correctamente o si saturan el sistema.

Observamos:

```

```

Recomendaciones:

#### 6. Problemas de memoria

En ocasiones cuando estemos trabajando en el HPC podemos observar este error `PONER AQUI EL ERROR`. Este se debe a que la memoria de alguna de las particiones que estamos empleando está llena. Vamos a revisar el tamaño de las particiones para gestionar el almacenamiento de forma eficiente.

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 7. Permisos de las distintas particiones

Como todos sabemos en este punto, par partición de `/scratch/` tiene permisos de lectura, pero no permisos de escritura. Si no trabajamos con las rutas correctas nos vamos a encontrar con problemas de permisos cuando estemos trabajando en el HPC.

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 8. Gestión de ficheros

En este ejercicio vamos a ir creando algunos scripts "tipo" para que podáis guardarlos y emplearlos como buenas prácticas para la gestión de ficheros.

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones:

#### 9. Lanzar un pipeline de Nextflow: Ejecución, revisión e interpretación

En este ejercicio vamos a ejecutar el pipeline de [**nf-core/bacass**]() indicando todos los pasos a seguir:

- Crear la carpeta de trabajo
- Preparar los archivos necesarios
- Ejecutar el pipeline
- Revisar los logs y resultados
- Revisar la carpeta `work`

Ejecutamos:

```bash

```

Observamos:

```

```

Recomendaciones: