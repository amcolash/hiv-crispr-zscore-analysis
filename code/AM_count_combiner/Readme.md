# Count Combiner

This code was written by [Andrew McOlash](https://github.com/amcolash/) is a pre-processing stage of the analysis pipeline before the actual
z-score analysis is run. The purpose of this script is to combine MAGeCK counts files along with a library file into a single counts file.
This file in then inputted into the snakemake pipeline by JT Porrier for the z-score analysis.

## Required Input Files

### These files are automatically copied when using the z-score analysis pipeline. Please refer to the pipeline documentation for information about that input.

- Create a directory called `input/` in this folder.
- Add all `.txt` counts files (can be renamed from `.csv` to `.txt` if needed)

> example-counts.txt

```tsv
sgRNA	Gene	Experiment1R1.fastq	Experiment1R2.fastq	Experiment2R1.fastq	Experiment2R2.fastq	Experiment3R1.fastq	Experiment3R2.fastq	Experiment4R1.fastq	Experiment4R2.fastq	Experiment5R1.fastq	Experiment5R2.fastq
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

// Count exclusion will only happen for these columns (the entire row will be excluded)
const thresholdExclusions = ['Experiment1R1', 'Experiment1R2'];

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
sgRNA	Gene	Experiment1R1.fastq	Experiment1R2.fastq	Experiment2R1.fastq	Experiment2R2.fastq	Experiment3R1.fastq	Experiment3R2.fastq	Experiment4R1.fastq	Experiment4R2.fastq	Experiment5R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment5R2.fastq	Experiment6R1.fastq	Experiment6R2.fastq	Experiment7R1.fastq	Experiment7R2.fastq	Experiment8R1.fastq	Experiment8R2.fastq	Experiment9R1.fastq	Experiment9R2.fastq	Experiment10R1.fastq	Experiment10R2.fastq
CHOPCHOP_vm0001	AARS1	466	558	334	352	462	480	448	394	1095	970	1312	1503	721	2680	2506	2642	2446	1757	978	2581	2825	1494	2287	2647
CHOPCHOP_vm0002	AARS1	3968	4254	2722	2486	2667	2675	2787	2628	6412	6115	8187	9608	18167	16482	17451	17582	16538	15962	16538	16441	15858	13056	15497	17063
CHOPCHOP_vm0003	AARS1	150	189	299	305	257	234	325	278	585	737	929	992	1570	1699	2827	1608	1854	1948	748	1715	1556	1260	1301	1791

...
```
