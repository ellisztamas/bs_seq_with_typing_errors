# Overview of the data files used

This needs updating with details of where data are, and how to download and rename.

* `columbia_drosophila`: raw sequence data from four samples of the *A thaliana*
    reference strain Columbia (Col-0) and *Drosophila melanogater*. This is one
    sample of DNA prepared using 13 or 15 PCR cycles, and relative
    concentrations of transposase to DNA of 0.5 and 1. Nomimal coverage is 30x.
* `cross`: 96 F2 and selfed offspring of the parents of a cross between *A.
    thaliana* accessions 6191 and 6046. Pisupati et al. (2023; PLoS genetics 
    19.5 : e1010728.) grew F2s from reciprocal crosses and selfed parents at 4°C
    and 16°C and sequenced them using a protocol using oligo replacement and 
    unmethylated dNTPS. These data are a subset of Pisupati's data resequenced
    with the protocol using strand displacement and methylated dNTPs.    
* `genomes`: FASTA files of reference genomes:
    * *A. thaliana* TAIR10 reference assembly.
    * *D. melanogaster* genome (version 6)
    * NEB lambda phage vector, used as an unmethylated control
    * pUC19 vector, used as a methylated control
    * *Lactobacillus acidophilus* and *Acetobacter aceti*, which apparently are
        common symbionts of fruit flies.

Lambda phage was downloaded from:
https://www.ncbi.nlm.nih.gov/nuccore/J02459

pUC19 downloaded from
https://zymoresearch.eu/products/methylated-non-methylated-puc19-dna-set