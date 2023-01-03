# Count Combiner

This code was written by [Andrew McOlash](https://github.com/amcolash/) and is a pre-processing stage of the analysis pipeline before the actual
z-score analysis is run. The purpose of this script is to combine MAGeCK counts files along with a library file into a single counts file.
This file in then inputted into the z-score snakemake pipeline written by JT Poirier for the z-score analysis.

### Please refer to the main documentation if using the z-score pipeline analysis. This documentation is also listed here for completeness and informational purposes for anyone aiming to use this subset of code separately from the z-score pipeline.

## Required Input Files

- Create a directory called `input/` in this folder.
- Add all `.txt` counts files (can be renamed from `.csv` to `.txt` if needed)

> example-counts.txt

```tsv
sgRNA	Gene	Expt1_vrna_R1.fastq Expt1_vrna_R2.fastq Expt2_vrna_R1.fastq Expt2_vrna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq
CHOPCHOP_vm1334	SYMPK	842	843	604	586	578	574	561	473
chr14_34904432_34904451_SPTSSA_plus	SPTSSA	385	368	374	401	366	561	512	433
GUIDES_vm0477	GATAD2B	489	523	437	457	370	393	352	324

...
```

- Library files that end with `.csv`

> library.csv

```csv
sgrna,guide,gene
CHOPCHOP_vm0001,ATCCACTACGACCGGATTGG,AARS1
CHOPCHOP_vm0002,CGCCGCACATCTTGTCAACC,AARS1
CHOPCHOP_vm0003,CCACAGTGATGGTCCGAGCG,AARS1

...
```

- [Optional] A configuration file can be added to the root of this code directory. This configuration allows filtering out low counts from
  specified columns when they do not meet a threshold.

> config.js [Optional]

```js
// Counts less than (not including) this value will be excluded
const countThreshold = 10;

// Count exclusion checks only happen for the specified columns below. Any count lower than the threshold in these columns will exclude the guide from the downstream zscore analysis for each counts column, not only the gdna columns
const thresholdExclusions = ['Expt1_gdna_R1', 'Expt1_gdna_R2'];

// Make these values available to the main script
module.exports = { countThreshold, thresholdExclusions };
```

## Script Usage

### Unless you are modifying this code as a developer, it is not recommended to manually run this script.

This script is run during the z-score analysis pipeline and can be run most easily using [Docker](https://www.docker.com/). This is already
a prerequisite of running the main analysis pipeline, so there is no additional setup required.

Open a terminal, move into this code directory and run the script via docker.

```bash
$ cd hiv-crispr-zscore-analysis/code/AM_count_combiner
$ docker-compose up --build
```

## Output Files

The script will output a single file named `counts_all.txt`. Each row will contain all information for a gene combined together.

> counts_all.txt

```tsv
sgRNA	Gene	Expt1_vrna_R1.fastq Expt1_vrna_R2.fastq Expt2_vrna_R1.fastq Expt2_vrna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq
CHOPCHOP_vm0001	AARS1	466	558	334	352	462	480	448	394
CHOPCHOP_vm0002	AARS1	3968  4254	2722	2486	2667	2675	2787	2628
CHOPCHOP_vm0003	AARS1	150	189	299	305	257	234	325	278

...
```
