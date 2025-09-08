# Curso Práctico de Iniciación al uso del Entorno de Alta Computación

BU-ISCIII

## Práctica 5: Software Management on HPC

Welcome to the practice session for software management on our local HPC. Today, we'll cover three main topics:

- [Curso Práctico de Iniciación al uso del Entorno de Alta Computación](#curso-práctico-de-iniciación-al-uso-del-entorno-de-alta-computación)
  - [Práctica 5: Software Management on HPC](#práctica-5-software-management-on-hpc)
  - [1. Permissions: Personal PC vs HPC](#1-permissions-personal-pc-vs-hpc)
  - [2. Virtual Environments \& Software Managers](#2-virtual-environments--software-managers)
  - [3. Inspect data with our installed package](#3-inspect-data-with-our-installed-package)
  - [3. Containers: Docker \& Singularity](#3-containers-docker--singularity)

## 1. Permissions: Personal PC vs HPC

- **Compare file and software permissions** on your personal computer vs the HPC.
- **Practice:**
  - Check your user permissions on the HPC:

        ```bash
        whoami
        groups
        ls -l ~
        ```

  - Try installing a package globally (expect a permissions error).
  - **Practice with `chown` (change file ownership):**
    - On your personal computer (if you have admin/root access), create a file and change its owner:

            ```bash
            touch testfile.txt
            ls -l testfile.txt
            rm testfile.txt
            ```

    - The file has been removed with no issue. But what happens if the file can only be removed as root?
    - First, lets start by initiating a root session:

            ```bash
            sudo su
            touch testfile.txt
            exit # Exit root session
            ```

    - Now that we exited the root session, we can check testfile.txt permissions

            ```bash
            ls -l testfile.txt
            ```

    - Try editing or deleting the file as a regular user

            ```bash
            rm testfile.txt
            ```

    - On the HPC, try running `chown` on a file in your home directory:

            ```bash
            touch myfile.txt
            chown root:root myfile.txt
            ```

    - **Expected:** You will get a "Operation not permitted" error, because you do not have root privileges on the HPC.
    - Now lets try to change the ownership to a common group for our lab
  - **Discussion:**
    - Why is `chown` restricted on shared systems?
    - How does this affect software installation and file management on HPCs?

## 2. Virtual Environments & Software Managers

- **Why use virtual environments?**
    Isolate dependencies and avoid conflicts.
- **How to work with Virtual Environmets in our HPC:**
    In this exercise, we will use seqkit to inspect some sequence files.
  - Let's start by installing a it with pip:

        ```bash
        pip install seqkit
        ```

  - Well, that didn't go as expected did it?
    As we've seen during the theory class, pip does not create any virtualization, only manages packages and dependencies.
    Therefore, if we tried to installl something with pip, we would end-up installing it for every other user in the HPC.
    That's the main reason why pip is not installed globally in our HPC.

    Do you know any workaround to install seqkit?

    In this case, we will use micromamba to create an isolated environment, so our installed packages do not interfere with or depend on the HPC's system-wide resources. Once the environment is activated, we can safely install and use seqkit within it.
  - Create a micromamba virtual environment. We will use `micromamba create` for it

        ```bash
        micromamba create -n bioenv pip
        ```

    Here, the `-n` bioenv flag sets the environment name, and `pip` is the initial package to install. We can set as many initial packages as we want, if they are available in the configured conda channels.

    Lets initiate the virtual environment:
        ```bash
        micromamba activate bioenv
        ```
    Congratulations! Your packages are now isolated from the global system. You will see `(bioenv)` added at the left corner of your terminal pallete as a flag to know that the environment is activated.

    You can try to use `pip list` now as it will be available in the virtual environment. Try to do the same after running `micromamba deactivate` to see what happens.

    Lets see if seqkit is available in pip or micromamba so we can install it:

    Pip does not have a supported command to search for a package, you have to go to its webpage and use the browser to find it <https://pypi.org/search>.

  - Let's see if seqkit is available in micromamba:

        ```bash
        micromamba search seqkit
        ```

    Seqkit is not available thorugh pip, so our only option is to install it with micromamba
        ```bash
        micromamba install seqkit
        ```
    As you can see, it is only found in <https://conda.anaconda.org/bioconda>. This means that if we don't have bioconda channel added to our config, we won't be able to download through micromamba.

    Let's see what channels are accessible:
        ```bash
        micromamba config get channels
        ```
    You might see something like the following:

    ```bash
    channels:
        - conda-forge
        - bioconda
        - defaults
        - nodefaults
    ```

    If you want to add any new channel, (like bioconda if we did not have it), you can do it by modifying `~/.condarc` config file. Go to the channels section and add or remove any channels.

    As a practice test, lets remove bioconda channel and try to reinstall seqkit:
    1. Remove `- bioconda` from the channels section in `~/.condarc`
    2. Run `micromamba remove seqkit`
    3. Reinstall seqkit with micromamba
    Well well, seqkit seems to be unavailable now.

    To go on with the next section, add bioconda channel back and install seqkit again by yourself.

## 3. Inspect data with our installed package

    - Try with conda/micromamba:
        - First, configure your `.condarc` so all users share the same environments directory. This helps with reproducibility and collaboration on the HPC.
            ```bash
            nano ~/.condarc
            # Now add this line somewhere in the file
            envs_dirs:
               - RUTA_POSIBLE/micromamba/envs
            ```
        - Create a new micromamba environment in the shared location:
            ```bash
            micromamba create -n mymicroenv python=3.10
            micromamba activate mymicroenv
            ```
        - Install pip inside the micromamba environment to compare package availability:
            ```bash
            micromamba install pip
            pip install somepackage
            ```
        - Compare with module load (system-wide software):
            ```bash
            module overview
            module load R/4.1.3
            R --help
            ```
        - Try installing a package with both micromamba and pip, and note any differences in available versions or installation success.
    
## 3. Containers: Docker & Singularity

- **Why containers?**
    Portability and reproducibility of software environments.
- **Practice:**
    Unfortunately, we don't have docker available in our HPC. Singularity is a nice replacement for docker as it handles containers while also be specifically designed for HPC systems.

  - In this exercise we will use bedtools to convert some bam files back to fastq. Let's find a container singularity with the required software:

        ```bash
        singularity search bedtools
        ```

    Wait, it appears as singularity is not available... Thats right, because in order to keep reproducibility HPCs don't have as much system-wide software. In our case, singularity is accessed through EasyBuild modules:
        ```bash
        module load singularity
        singularity search bedtools
        ```
    If you want to check what modules are active in your session, you can run `module list`.
    Once you are done using a module, you can `module unload singularity` to unload it from your session, or `module purge` to unload all active modules.
  - Pull and run a Singularity container:

        ```bash
        singularity exec --bind /scratch/RUTA_EJEMPLO /data/courses/hpc_course/pipelines/singularity-images/bedtools:2.31.1--h13024bc_3 \
        bedtools bamtofastq -i RUTA_EJEMPLO_ARCHIVO -fq RUTA_EJEMPLO_FASTQ # Our container is initiated with exec so bedtools is accessible here
        ```

  - for interactive use inside an image run `singularity shell /path/to/image`

---
**Discussion:**

- When would you use each method?
- What are the pros and cons of each approach?
