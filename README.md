# hiv-crispr-zscore-analysis

This repository contains the code that was used to run z-score analyses for Montoya et al. 2023 [bioRxiv](https://www.biorxiv.org/content/10.1101/2022.11.03.515041v1). There is additional code that was used in a post-processing stage that helped with preparing figures for the paper, but is not used for the z-score analysis.

## Processing Scripts

There are three pieces of code inside of this repository. Two of them are used in the main z-score processing and the last helped with post-processing the z-score data for figures in the paper. Unless otherwise noted, most of the code and infrastructure here was written by [Andrew McOlash](https://github.com/amcolash).

### Count Combiner

The contents of `code/AM_count_combiner` contains a pre-processing stage of the analysis pipeline before the actual z-score analysis is run.

### Z-Score Analysis

The contents of `code/JT_snakemake` contains R code written by [John Poirier](john.poirier@nyulangone.org) and is the main portion of the z-score
analysis pipeline.

### Columns to Rows

The contents of `code/AM_cols2rows` contains a data post-processing script (not part of the actual z-score analysis). This script was used to help with transforming the output data for the visualizations in the paper.

## Getting Set Up

Using this code requires 2 things, docker and an environment that allows using bash scripts (Mac OS, Linux, WSL on Windows).

It is highly recommended to run this code on Mac OS or Linux as it will be much easier to do, though it will be possible on windows.

### Windows-Specific Instructions (WSL)

If you use Mac OS or Linux, skip to the next step. This is only necessary for windows users (only Windows 10/11 supported).

You will need to WSL to use a virtual linux container. This allows running the code in a linux environment with minimal complications. The easiest environment to set up is Ubuntu 20.04.

- Windows 10: Please go [here](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10) and follow steps 1-4.
- Windows 11: Please go [here](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support) and follow steps 1-4.

### Installing Docker

- Mac OS: Install docker desktop following these [instructions](https://docs.docker.com/desktop/install/mac-install/). Make sure you install the proper version! Check if you have an M1 or M2 chip [Apple Menu -> About this Mac]. If you do, install the apple silicon version of docker instead of the intel one.

- Linux: install docker desktop following these [instructions](https://docs.docker.com/desktop/install/linux-install/).

- Windows (WSL): Open your WLS Ubuntu 20.04 terminal.

  Install docker by following these [instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).

  Then install `docker-compose` following these [instructions](https://docs.docker.com/compose/install/other/).

### Getting the Code

Download the latest version of the code from [Github](https://github.com/amcolash/hiv-crispr-zscore-analysis/archive/refs/heads/main.zip).

Unzip this folder to your computer (downloads, documents, desktop, etc).

## Setting Up Input

Make an `input/` folder inside of the code directory. Inside, make 2 more directories `data` and `config`.

### Count and Library Input Files

- Add all `.txt` counts files to `input/data/` - they can be renamed from `.csv` to `.txt` if needed

> input/data/example-counts.txt

```tsv
sgRNA	Gene	Expt1_vrna_R1.fastq Expt1_vrna_R2.fastq Expt2_vrna_R1.fastq Expt2_vrna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq
CHOPCHOP_vm1334	SYMPK	842	843	604	586	578	574	561	473
chr14_34904432_34904451_SPTSSA_plus	SPTSSA	385	368	374	401	366	561	512	433
GUIDES_vm0477	GATAD2B	489	523	437	457	370	393	352	324

...
```

- Add all library files that end with `.csv` to `input/data/`

> input/data/library.csv

```csv
sgrna,guide,gene
CHOPCHOP_vm0001,ATCCACTACGACCGGATTGG,AARS1
CHOPCHOP_vm0002,CGCCGCACATCTTGTCAACC,AARS1
CHOPCHOP_vm0003,CCACAGTGATGGTCCGAGCG,AARS1

...
```

### Configuration

Create a file inside of `input/config` named `config_snakemake.yaml`. This file will configure the z-score analysis. You will need to change any values that do not work for your data.

> input/config/config_snakemake.yaml

```yaml
# Z-score analysis configuration file

# Output file
counts_file: results/count/counts_all.txt

# Which columns in the counts file are treatments
treatment: Expt1_vrna_R1.fastq,Expt1_vrna_R2.fastq,Expt2_vrna_R1.fastq,Expt2_vrna_R2.fastq

# Which columns in the counts file are controls. Match the treatment replicates above with control replicates you want to normalize to below.
control: Expt1_gdna_R1.fastq,Expt1_gdna_R2.fastq,Expt1_gdna_R1.fastq,Expt1_gdna_R2.fastq

# Which column in the counts file is plasmids
plasmid: plasmidlibrary.fastq

# Number of sgrnas per gene in library
sgrnas:
  n: 8

# Heatmap configuration
heatmapCount: 50
heatmapMin: -4
heatmapMax: 4

# File to output results to. Name as you see fit.
output_file: Expt1_Expt2.zscores.txt
```

## Running Analysis

Open a terminal inside of the root of the project, then run the analysis script

```bash
$ cd hiv-crispr-zscore-analysis/
$ chmod +x ./run_analysis.sh
$ ./run_analysis.sh
```

### Output Files

Assuming everything went well, all output files should be placed into the `output` directory. There is a different directory for each part of the pipeline. The final output is placed into `output/snakemake`.
