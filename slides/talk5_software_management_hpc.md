# Software Management and Containers in HPC

## 1. Software management basics: Permissions

Permissions are rules that control what a user can do on a computer system. They determine:

* Who can read (view a file or program).
* Who can write (modify or delete).
* Who can execute (run a program).

### Example: Checking and changing permissions

```bash
# Check file permissions
ls -l myscript.sh

# Add execute permission for user
chmod u+x myscript.sh

# Remove read/write permission for group and others
chmod go-rw data.txt

# Change file owner
chown username:group file.txt
```

---

## 1. Software management basics: Why permissions exist

They exist to protect the operating system, applications, and data from accidental damage or malicious use:

* Security: Prevent malware or mistakes from harming other users.
* Stability: Prevent one user’s bad installation from breaking shared applications.
* Consistency: Admins control which versions of software are installed cluster-wide.
* Performance: HPC software often needs to be built with optimized compilers and libraries.

```bash
# Load software through modules instead of custom install
module avail
module load Python/3.10.4
python --version
```

---

## 1. Software management basics: Windows vs Linux

Windows and linux work quite different when talking about software. In windows we ussually run programs through binary executable files (.exe) but in linux, the tools are more often executed through the Command Line Interface (CLI).

On **Windows (PC)**:

```powershell
installer.exe
```

On **Linux/HPC**:

```bash
module load gcc/12.1.0
gcc --version
```

---

## 1. Software management: HPC vs Personal PC

On a personal computer (for example, your Windows laptop) installing software is straightforward:

* You open a browser, download an installer (.exe or .msi), run it, and the program installs locally.
* You usually have administrator rights (even if you don’t notice), so you can change almost any system configuration.
* You work on a single machine, with a fixed operating system and hardware (CPU, RAM, graphics card…).

On a High-Performance Computing (HPC) system, the situation is very different:

* It’s a multi-user environment.
* The hardware consists of compute nodes that cannot be accessed by normal users.
* You have no root permissions: you cannot install software system-wide, change OS settings…
* The goal is to optimize for the cluster hardware and ensure reproducibility, not just “get a program running.”

Differences between your personal PC and HPC:

On **PC**:

```powershell
# Download and install directly
python-3.11.0-amd64.exe
```

On **HPC**:

```bash
# Use modules instead of local installation
module avail
module load python/3.10
python -m pip install --user numpy
```

---

## Software management: HPC principles

On a personal machine, you can afford to “break” your setup and reinstall. On an HPC the situation is completely different:

* Overwriting system libraries could break unrelated software for all the other users.
* You must be able to reproduce exactly an analysis months or years later with the same configuration.
* In case of unrestricted installation a malicious or careless user could install malware.

That’s why HPC systems:

* Organize software into modules, virtual environments or containers so you can choose versions without interfering with others.
* This latter approach also helps to keep reproducibility.
* Contained privileges: Users are free to install packages only in their home or scratch directories, where they can’t affect other users.

```bash
# Load reproducible environment with EasyBuild
module load R/4.2.1

# Create a private environment (safe for you only)
micromamba create -n analysis-env r-base=4.2.0
micromamba activate analysis-env
```

# 2. Introduction to Virtualization

## Virtual Environments

A virtual environment is an isolated workspace on your computer where you can install software without interfering with the global system.

Examples: Python venv, Conda, Micromamba environments, R virtual libraries.

* **Pro**: No root permissions needed.
* **Con**: Doesn’t virtualize the OS, system or hardware. Only manages the software layer.

### How to create python virtual environments

```bash
# Python has built-in virtual environment tool called venv
python3 -m venv myenv
source myenv/bin/activate
pip install numpy pandas
```

## Virtual Envs usage in HPC

On an HPC cluster, you usually don’t have admin/root permissions. That means:

* You cannot install system-wide software (like `pip install` globally).
* Users share the same filesystem: installing packages globally would cause conflicts.
* Even inside a virtual environment it’s difficult to avoid conflicts. Software managers exist for the sole reason to simplify this process.

### Example: Installing safely in user space

```bash
# BAD (not allowed in HPC)
pip install numpy

# GOOD (inside environment)
micromamba create -n py39 python=3.9
micromamba activate py39
pip install numpy
```

# 3. Software Managers

## EasyBuild

EasyBuild is an open-source framework designed specifically for building and installing scientific software on HPC systems.

* Our HPC uses this framework to manage certain global software for all users (e.g. Nextflow or Singularity).
* Encapsulates software in modules, which can be loaded via: `module load <module-name>`.

### Example: Using EasyBuild

```bash
# Load Nextflow
module load Nextflow

# Now we can call Nextflow right away from our terminal
Nextflow run main.nf
```

## Conda / Mamba

* Pro: No root permissions needed, isolates packages and dependencies inside the same OS without affecting system installations.
* Con: Doesn’t virtualize the OS, system or hardware. Only manages the software layer.
* HPC usage: Extremely common for running different Python/R environments on shared clusters without interfering with system-wide libraries.
* Example: Python venv, Conda, Micromamba environments, R virtual libraries.

### Example: Creating Conda and Micromamba envs

```bash
# Conda
conda create -n rnaseq python=3.10 numpy pandas
conda activate rnaseq

# Install software from Bioconda channel
conda install -c bioconda fastqc

# Micromamba (faster, lighter)
micromamba create -n rnaseq python=3.10 numpy pandas
micromamba activate rnaseq
```

## Conda: Channels

* Not everything can be installed with `conda install`.
* The desired software must be accessed through a **conda channel**.
* Conda channels are repositories (URLs) where Conda looks for packages.
* The base channel is `defaults`, but there are community-driven channels like **conda-forge** or **bioconda**. Anyone can create a channel.

### Example: Installing from channels

```bash
# From defaults
conda install numpy

# From conda-forge
conda install -c conda-forge r-ggplot2

# From bioconda (bioinformatics tools)
conda install -c bioconda fastqc
```

## Mamba

* A drop-in replacement for Conda written in C++ instead of Python.
* Uses the same package repositories and commands as Conda.
* Designed to solve Conda’s main weakness: slowness, especially in dependency resolution.
* **Micromamba** is a lightweight (10mb), and self-contained version of Mamba (installed in our HPC).

### How to use Micromamba:

```bash
# Create environment with Micromamba
micromamba create -n testenv python=3.9 numpy pandas
micromamba activate testenv

# Install packages
micromamba install -n testenv -c bioconda fastqc
```

## HPC Shared Environments

* If each user creates its own environments in the HPC, there may be differences in results due to software versions.
* Using shared environments avoids differences in analysis results due to environment differences.
* In our HPC, all users can access the same modules, for softwares like Nextflow or Singularity.
* You can also change Conda’s configuration file (`.condarc`) to use the same list of environments as other users.

### Private vs public environments. How to build and use shared environments

```bash
# Shared environment (everyone has access)
module load singularity

# Private environment (user space only)
micromamba create -n privateenv python=3.10
micromamba activate privateenv

# Example how to configure .condarc to use shared envs
# Open ~/.condarc (should be located in your home after installation)
channels:
  - defaults
  - conda-forge
  - bioconda
envs_dirs:
  - /shared/conda/envs # This route may point to a shared folder so users can access the same envs
  - ~/micromamba/envs
```

## Pip

* Pip is the default package manager for Python.
* It is the official tool for installing packages from the Python Package Index ([https://pypi.org/](https://pypi.org/)).
* Pip’s sole purpose is to install, update, and remove Python packages from PyPI.
* Pip itself does not have built-in environment management like Conda, but you can install it in a Conda environment.

### Example: Using Pip

```bash
# Install package
pip install numpy

# Install a specific version
pip install fastqc==0.12.1

# Upgrade a package
pip install --upgrade numpy

# Use pip inside Conda or Micromamba
micromamba create -n pyenv python=3.10
micromamba activate pyenv
pip install scipy
```

# Introduction to Virtualization

What is Virtualization?

* Virtualization is the process of creating a virtual version of a computing resource.
* It behaves like the real thing, but is actually a software on top of physical hardware.
* Instead of interacting directly with the physical server, you interact with a virtual replica that is isolated from your system.

### Example: Virtualization in practice

```bash
# Virtual Machine example (desktop)
VBoxManage createvm --name UbuntuTest --register

# Container example (lighter weight)
docker run -it ubuntu:20.04 bash
```

## Virtual Machines

* A Virtual Machine (VM) is a software-based emulation of a physical computer, including OS and hardware components using a hypervisor.
* **Pro**: Total isolation. They can run a completely different operating system.
* **Con**: Very slow due to full hardware emulation.
* **HPC usage**: Rare, mainly for testing environments or isolated, security-sensitive workloads.
* **Example**: Running Ubuntu in VirtualBox on a Windows laptop.

### Here is a brief example of using virtualbox that you can try in your personal PC

```bash
# VirtualBox command line example
VBoxManage createvm --name "UbuntuLab" --register
VBoxManage modifyvm "UbuntuLab" --memory 4096 --cpus 2
VBoxManage startvm "UbuntuLab"
```

## Containers (OS-level Virtualization)

* A container is a lightweight, standalone package that bundles together an application and everything it needs to run, but shares the host system’s kernel instead of emulating hardware.
* **Pro**: Near-native performance, lightweight.
* **Con**: Shares the host OS kernel, cannot simulate a different OS than the host’s.
* **HPC usage**: Very common for packaging software to run without dependency issues.
* **Examples**: Docker, Singularity.

```bash
# Docker container (local machine only)
docker run -it ubuntu:22.04 bash

# Singularity container (HPC-friendly)
module load singularity
singularity exec docker://ubuntu:22.04 bash
```

## VMs vs Containers

* VMs emulate full hardware + OS (heavy, slower).
* Containers share the kernel, just isolate applications (fast, portable).

### Lets see the size differences for each image

```bash
# VM image (several GB)
du -sh ubuntu-vm.vdi

# Container image (hundreds of MB, faster to deploy)
singularity pull docker://biocontainers/fastqc:v0.11.9_cv8
du -sh fastqc_v0.11.9.sif
```

# 4. Introduction to Containers: Docker & Singularity

## Docker

* Docker is a popular platform designed for building, sharing, and running applications in containers.
* By default, Docker containers run as the root user on the host system. This can pose a security risk in multi-user environments like an HPC.
* Unfortunately, we cannot directly use Docker in our HPC but here is a small example on how to use it:

```bash
# Pull an image
docker pull ubuntu:22.04

# Run interactively
docker run -it ubuntu:22.04 bash

# Build a custom image
docker build -t mytool .

# Save an image for export to HPC
docker save mytool > mytool.tar
```

## Singularity

* Singularity is a container platform specifically designed for high-performance computing (HPC) and scientific research environments.
* Singularity containers run as the same user that launched them on the host system. This is a security feature for HPC clusters.
* It’s our go-to to create and run containers in the HPC.
* Galaxy’s [https://depot.galaxyproject.org/singularity](https://depot.galaxyproject.org/singularity) includes a lot of Singularity containers for bioinformatic analysis.
* Another viable option is [DockerHub](https://hub.docker.com/r/biocontainers/biocontainers)

```bash
# Load Singularity module
module load singularity

# Pull a container from DockerHub
singularity pull docker://biocontainers/fastqc:v0.11.9_cv8

# Run FastQC inside container
singularity exec fastqc_v0.11.9_cv8.sif fastqc --version

# Open shell inside container
singularity shell fastqc_v0.11.9_cv8.sif

# Pull directly from Galaxy depot
singularity pull https://depot.galaxyproject.org/singularity/fastqc:0.11.9--0
```

# Essential Takeaways

* You cannot install anything on the HPC that needs admin permissions.
* Prioritize modules over virtual environments (more efficient).
* If you only need to execute one certain task (e.g. run FastQC) use a Singularity container.
* If you need to interact with files or data dynamically use virtual environments (Micromamba/Pip).
* **DON’T RUN HEAVY JOBS IN THE LOGIN NODE!!**

```bash
# DON'T RUN HEAVY JOBS IN THE LOGIN NODE
Nextflow run bacass/main.nf # BAD, this will overload the login node as it has no computing resources

# Instead, use slurm scheduler via srun or sbatch
cat > job.sh <<EOF
#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=fastqc.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4

module load singularity
singularity exec fastqc_v0.11.9_cv8.sif fastqc file.fastq
EOF

sbatch job.sh
```
