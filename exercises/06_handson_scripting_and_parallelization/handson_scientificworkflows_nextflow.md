# Curso Práctico de Iniciación al uso del Entorno de Alta Computación  
BU-ISCIII

## Práctica D: Workflows reproducibles con Nextflow (Slurm) — `nf-demo` y `nf-core/bacass`

### Descripción
Verás cómo **Nextflow** envía procesos a **Slurm** automáticamente mediante un **archivo de configuración**. Ejecutaremos `nf-demo` y `nf-core/bacass` con **configuración completa** (recursos por proceso) y monitorizaremos con Slurm.

### Notas importantes
- No envíes Nextflow con `sbatch`: ejecuta `nextflow run ...` en el *login* (es liviano) y Nextflow creará los jobs de Slurm.
- Asegúrate de cargar `module load nextflow` y (opcional) `singularity`.
- Ajusta colas, memoria y CPUs en tu `nextflow.config`.

---

### 1) Config para `nf-demo`
Guarda **`configs/nextflow.nf-demo.config`**:

```groovy
/*
 * nextflow.nf-demo.config — ejecutar 'nf-demo' en Slurm
 */
params {
  outdir = "$PWD/results/nf-demo"
}
process {
  executor = 'slurm'
  queue    = 'short_idx'
  errorStrategy = 'retry'
  maxRetries    = 1
  cpus   = 1
  memory = '1 GB'
  time   = '15 m'
  withName:sayHello {
    cpus = 1
    memory = '512 MB'
    time = '5 m'
  }
}
singularity {
  enabled    = true
  autoMounts = true
  cacheDir   = '/data/ucct/bi/pipelines/singularity-images'
}
```
[TODO]: <Fix this example; it needs to be run within an sbatch script>

**Ejecutar:**
```bash
module load nextflow
cd ~/hpc101

nextflow run nf-demo -c configs/nextflow.nf-demo.config -resume   --outdir "$PWD/results/nf-demo"
```
[TODO]: <this is not the expected process to be excuted in the pipeline>
<details>
<summary>Stdout ejemplo</summary>

```
N E X T F L O W  ~  version 23.10.1
Launching `nf-demo` [calm_lamarr] DSL2
executor >  slurm (4)
[a1/3e1f2c] process > sayHello (1) [100%] 4 of 4 ✔
```
</details>

**Mientras corre:**
```bash
squeue --me | egrep 'nf|sayHello|demo'
```

---

### 2) Config para `nf-core/bacass`
Guarda **`configs/nextflow.bacass.config`**:

```groovy
/*
 * nextflow.bacass.config — nf-core/bacass en Slurm
 * Ajusta 'withName:' según versión del pipeline.
 */
params {
  outdir = "$PWD/results/bacass"
}
process {
  executor = 'slurm'
  queue    = 'middle_idx'
  cpus   = 2
  memory = '4 GB'
  time   = '2 h'
  errorStrategy = { task.exitStatus in [137,138,140,143] ? 'retry' : 'finish' }
  maxRetries    = 1
  maxErrors     = '-1'

  withName:TRIMMOMATIC {
    cpus = 4; memory = '8 GB'; time = '1 h'
  }
  withName:SPADES {
    cpus = 8; memory = '64 GB'; time = '12 h'
  }
  withName:QUAST {
    cpus = 2; memory = '8 GB'; time = '2 h'
  }
  withName:PROKKA {
    cpus = 4; memory = '8 GB'; time = '1 h'
  }
  withName:BOWTIE2 {
    cpus = 4; memory = '8 GB'; time = '2 h'
  }
}
singularity {
  enabled    = true
  autoMounts = true
  cacheDir   = '/data/ucct/bi/pipelines/singularity-images'
}
```

**Ejecutar (perfil test):**
```bash
module load nextflow
cd ~/hpc101

nextflow run nf-core/bacass -profile test,singularity   -c configs/nextflow.bacass.config -resume   --outdir "$PWD/results/bacass"
```

<details>
<summary>Stdout ejemplo</summary>

```
N E X T F L O W  ~  version 23.10.1
Launching `nf-core/bacass` [nifty_bohr] DSL2
executor >  slurm (7)
[2a/0f1d3a] process > TRIMMOMATIC (test)  [100%] 1 of 1 ✔
[3b/8ce912] process > SPADES (test)       [100%] 1 of 1 ✔
[4c/19f7a1] process > QUAST (test)        [100%] 1 of 1 ✔
[5d/5aa7b3] process > PROKKA (test)       [100%] 1 of 1 ✔
[6e/7bb213] process > BOWTIE2 (test)      [100%] 1 of 1 ✔
Completed at: 2025-.. Duration: 6m 12s
```
</details>

**Monitorizar consumo al final:**
```bash
sacct -j <primer_jobid_de_bacass> --format=JobID,JobName,Partition,State,Elapsed,MaxRSS,TotalCPU
```

---

### 3) Preguntas de control
<details>
<summary>¿Cómo sé los nombres exactos de los procesos para <code>withName:</code>?</summary>
Ejecuta con `-with-trace`. Revisa `trace.txt` y usa esos nombres en la config.
</details>

<details>
<summary>Me aparece <code>PD</code> para SPADES…</summary>
Revisa que la cola (`queue`) permite el tiempo/memoria solicitados; ajusta `cpus/memory/time` en `withName:SPADES`.
</details>
