# Bisulphite sequencing in the presence of conversion errors

Code supporting the manuscript "Bisulphite sequencing in the presence of
conversion errors".

## Introduction

The manuscript describes errors associated with a tagmentation-based protocol to
perform bisulphite sequencing, and how to deal with them.

## Data

Note! I need to update this section once data files are on a public server somewhere.

There are three main datasets of bisulphite-sequenced short read data:

1. The reference strain of *Arabidopsis thaliana* (Columbia, or Col-0), sequenced at 30x coverage
2. Drosophila melanogaster, sequenced at 30x coverage
3. F2 and selfed offspring of the parental accessions from a cross between *A thaliana* accessions 6046 and 6191.

There is also a folder of reference-genome FASTA files, with a script to download them

See the README file in the data folder for more details.

## Folder overview

- `01_data` gives raw reads and fasta files to align to.
- `02_processing` contains scripts to prepare genomes for mapping, aligning reads to those genomes, and calculating methylation across the genome. Note that most of this is done on the `scratch-cbe` partition of CLIP.
- `03_analysis` runs the analyses and prepares figures for the manuscript
- `04_manuscript` contains Latex files to compile the manuscript

See additional README files and docstrings within scripts for more information.

## Getting the code to run

Download the data first! See 01_data.

All scripts are intended to be run from the project root folder.

### SLURM environment

Analyses were written an run on the Vienna Biocenter CLIP cluster (https://clip.science) using the SLURM job scheduler.
I've done my best to get them reproducible, to get them to work on your machine you may need to adapt the code to manage dependencies correctly.
In particular, the heavy lifting is done on the CLIP `scratch-cbe` folder, which will not be available on other machines; edit the code to save things to a folder on your machine.

### Conda environment

A conda environment files is provided listing dependencies to run the analyses.
Install it on your machine with:
```
conda env create -f environment.yml
```
Scripts contain code to load the environment, but you may need to change 

### epiclinestools

The analysis uses functions from the custom Python package (https://epiclinestools.readthedocs.io/en/latest/)[epiclinestools].
In theory it ought to install as part of the conda environment described above, but this can be finicky.
If it fails, try
```
pip install git+https://github.com/ellisztamas/epiclinestools.git#egg=argh
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

MIT license
