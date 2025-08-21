# Curso Práctico de Iniciación al uso del Entorno de Alta Computación  
BU-ISCIII

## Práctica C: Paralelización — OpenMP (hilos) y MPI (procesos)

### Descripción
Probarás **OpenMP** (múltiples hilos en un nodo) con `fastp` y una mini-demo **MPI** (múltiples procesos, potencialmente en varios nodos). Verás cómo cambia el uso de CPU y cómo monitorizar.

### Notas importantes
- **OpenMP**: ajusta `--cpus-per-task` y el flag de hilos del programa (`-w`, `--threads`, `-@`…).
- **MPI**: ajusta `--nodes`, `--ntasks`, `--ntasks-per-node`; lanza con `mpirun`/`srun`.

---
[TODO]: <still need to add real tests>

### 1) OpenMP con `fastp`
**Script:** `scripts/fastp_openmp.sbatch`
```bash
#!/bin/bash
#SBATCH --job-name=fastp_omp
#SBATCH --partition=short_idx
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --chdir=~/hpc101
#SBATCH --output=logs/fastp_%j.out
#SBATCH --error=logs/fastp_%j.err

module load fastp/0.23.4

IN="raw/sample_01.fq.gz"
OUT="results/sample_01.trimmed.fq.gz"
mkdir -p results

echo "Using $SLURM_CPUS_PER_TASK threads"
fastp -i "$IN" -o "$OUT" -w "$SLURM_CPUS_PER_TASK" --dont_overwrite --verbose
echo "Done."
```

**Enviar y comprobar:**
```bash
sbatch scripts/fastp_openmp.sbatch
squeue --me
# Al terminar:
sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS,TotalCPU
```

<details>
<summary>¿Qué observar?</summary>
En OpenMP, si paraleliza bien, verás `TotalCPU` significativamente mayor que `Elapsed`.
</details>

---

### 2) Mini-demo MPI (hello desde cada proceso)
**Script:** `scripts/mpi_demo.sbatch`
```bash
#!/bin/bash
#SBATCH --job-name=mpi_demo
#SBATCH --partition=middle_idx
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:05:00
#SBATCH --output=logs/mpi_demo_%j.out
#SBATCH --error=logs/mpi_demo_%j.err

module load openmpi

mpirun -np $SLURM_NTASKS bash -lc 'echo "Hello from $(hostname)"; sleep 2'
```

**Enviar y ver logs:**
```bash
sbatch scripts/mpi_demo.sbatch
# tras finalizar
cat logs/mpi_demo_*.out
```
<details>
<summary>Salida ejemplo</summary>

```
Hello from ideafix04
Hello from ideafix04
Hello from ideafix07
Hello from ideafix07
```
</details>

---

### 3) Preguntas de control
<details>
<summary>¿Cuándo elegir OpenMP vs MPI?</summary>
OpenMP si todo cabe en un nodo y la herramienta soporta hilos. MPI si necesitas varios nodos o la app está hecha para procesos distribuidos.
</details>

<details>
<summary>Mi OpenMP no usa todos los hilos…</summary>
Revisa el flag de hilos del programa y que `--cpus-per-task` coincide. Observa `AveCPU`/`TotalCPU` en `sacct`.
</details>
