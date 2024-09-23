[![DOI](https://zenodo.org/badge/709326989.svg)](https://zenodo.org/doi/10.5281/zenodo.10171228)


# Bisulphite sequencing in the presence of conversion errors

Code supporting the manuscript "Bisulphite sequencing in the presence of
cytosine-conversion errors" by Ellis et al. (2024)

The manuscript describes errors associated with a tagmentation-based protocol to
perform bisulphite sequencing, and how to deal with them.

* [Folder overview](#folder-overview)
* [Data](#data)
    + [Illumina data](#illumina-data)
    + [Genome files](#genome-files)
* [Getting the code to run](#getting-the-code-to-run)
    + [SLURM environment](#slurm-environment)
    + [Dependencies](#dependencies)
        - [Conda environment](#conda-environment)
        - [Packages to download raw data](#packages-to-download-raw-data)
        - [methlab](#methlab)
* [Author information](#author-information)
* [Acknowledgements](#acknowledgements)
* [License](#license)

## Folder overview

- `01_data` gives raw reads and fasta files to align to.
- `02_processing` contains scripts to prepare genomes for mapping, aligning reads to those genomes, and calculating methylation across the genome. Note that most of this is done on the `scratch-cbe` partition of CLIP.
- `03_analysis` runs the analyses and prepares figures for the manuscript
- `04_manuscript` contains Latex files to compile the manuscript

See additional README files and docstrings within scripts for more information.


## Data

### Illumina data

There are two main datasets of bisulphite-sequenced short read data:

1. The reference strain of *Arabidopsis thaliana* (Columbia, or Col-0), sequenced at 30x coverage
2. Drosophila melanogaster, sequenced at 30x coverage

See 01_data/columbia_drosophila/readme.md for more details.

### Genome files

There is also a folder of reference-genome FASTA files, with a script to download them.
See 01_data/genomes

## Getting the code to run

All scripts are intended to be run from the project root folder.

### SLURM environment

Analyses were written an run on the Vienna Biocenter CLIP cluster (https://clip.science) using the SLURM job scheduler.
I've done my best to get them reproducible, to get them to work on your machine you may need to adapt the code to manage dependencies correctly.
In particular, the heavy lifting is done on the CLIP `scratch-cbe` drive, which will not be available on other machines; edit the code to save things to a folder on your machine.

### Dependencies

Most of the packages to run the analyses can be installed an used in a conda 
environment, with one or two exceptions.

#### Conda environment

A conda environment files is provided listing dependencies to run the analyses.

I recommend using mamba rather than conda to install the environment.
After
[installing mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html),
install the environment with:
```
mamba env create -f environment.yml
```

You can load the environment with `conda activate bserrors`.
There is a master script `setup.sh` which most scripts in this repo run to 
activate the repo, meaning that you should only have to change this script to
affect the whole repo.

Ensure that the environment includes Bismark version 0.24 or greater.
This is not done automatically, because neither `mamba` or `conda` would create
the environment when this was specified; I don't know why.
You can check the version with:
```
mamba list
```

#### Packages to download raw data

To download the short read data from NCBI, a few extra tools are required that
I could not get to play nicely with the conda environment

1. [SRA Tools](https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit)
2. [GNU parallel](https://www.gnu.org/software/parallel/)
3. NCBI's Entrez command-line tools. To install:
```
sh -c "$(curl -fsSL https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
export PATH=${HOME}/edirect:${PATH}
```

#### methlab

The analysis uses functions from the custom Python package (https://epiclinestools.readthedocs.io/en/latest/)[methlab].
In theory it ought to install as part of the conda environment described above, but this can be finicky.
If it fails, try
```
pip install methlab
```
or directly from GitHub:
```
pip install git+https://github.com/ellisztamas/methlab.git#egg=argh
```

## Author information

* Manuscript and analyses by Tom Ellis
* Wet lab work by Viktoria Nyzhynska
* Additional critical discussions and input from Almudena Mollá Morales, Rahul Pisupati and Grégoire Bohl-Viallefond
* Principle investigator: Magnus Nordborg (GMI)

## Acknowledgements

Thanks to Robert Schmitz and members of the Nordborg group for discussion.

The computational results presented were obtained using the CLIP cluster (https://clip.science).

## License

This work is released under the Creative Commons BY 4.0 license.