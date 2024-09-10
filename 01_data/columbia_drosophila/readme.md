# Columbia and fruit fly data

Raw sequence data from four samples of the *A thaliana*
reference strain Columbia (Col-0) and *Drosophila melanogater*. This is one
sample of DNA prepared using 13 or 15 PCR cycles, and relative
concentrations of transposase to DNA of 0.5 and 1. Nomimal coverage is 30x.

Raw fastq files are uploaded to NCBI bioproject PRJNA1155267.
They can be downloaded with the script `download_raw_fastq.sh`

This will require three additional packages that aren't in the mamba environment.

1. [SRA Tools](https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit)
2. [GNU parallel](https://www.gnu.org/software/parallel/)
3. NCBI's Entrez command-line tools. To install:
```
sh -c "$(curl -fsSL https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
export PATH=${HOME}/edirect:${PATH}
```