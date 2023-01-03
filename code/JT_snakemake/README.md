# Z-Score Calculations in R

This code is initially from [Dr. John T. Poirier](john.poirier@nyulangone.org) and his team. This R code is the main portion of the z-score
analysis pipeline. The input counts files are used to calculate z-scores as is described [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7796900/): PMID: 33382968

The original z-score file exists here and is named `zscore-orig.R`. A slightly modified version is used in the z-score pipeline analysis.
The modified version includes comments, removal of unused code, and a few small modifications that made the code run successfully.

No license was attached to this code, but has been shared/modified with JT's permission.

### Please refer to the main documentation if using the z-score pipeline analysis. This documentation is also listed here for completeness and informational purposes for anyone aiming to use this subset of code separately from the z-score pipeline.

## Required Input Files

- Create a directory `results/count` in this folder.
- Add a `.txt` counts file (can be renamed from `.csv` to `.txt` if needed). This is the count file that will be referenced from your
  configuration.

> counts_all.txt

```tsv
sgRNA	Gene	Expt1_vrna_R1.fastq Expt1_vrna_R2.fastq Expt2_vrna_R1.fastq Expt2_vrna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq Expt1_gdna_R1.fastq Expt1_gdna_R2.fastq
CHOPCHOP_vm0001	AARS1	466	558	334	352	462	480	448	394
CHOPCHOP_vm0002	AARS1	3968	4254	2722	2486	2667	2675	2787	2628
CHOPCHOP_vm0003	AARS1	150	189	299	305	257	234	325	278

...
```

- A configuration file must be added to the root of this code directory. This configuration allows control over how the analysis is run.

> config.yaml

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

## Script Usage

### Unless you are modifying this code as a developer, it is not recommended to manually run this script.

This script is run during the z-score analysis pipeline and can be run most easily using a helper script. This script requires
[Docker](https://www.docker.com/). This is already a prerequisite of running the main analysis pipeline, so there is no additional setup
required.

Open a terminal, move into this code directory and run the helper script.

```bash
$ cd hiv-crispr-zscore-analysis/code/JT_snakemake
$ ./run.sh
```

## Output Files

The script will output files based on your configuration of `output_file`. The files will exist inside `results/tests` and `results/extras`.

- Z-Scores: The z scores are outputted to this file

> [output].zscores.txt

```tsv
"Expt1_vrna_R1.fastq"	"Expt1_vrna_R2.fastq"	"Expt2_vrna_R1.fastq"	"Expt2_vrna_R2.fastq"
"AARS1"	0.276442868675943	-0.163123730468512	0.148261964751478	-0.526333484040557
"ABCB6"	-0.00651663688418705	0.782287910700647	0.747356565769643	0.231045089552426
"ABCD1"	0.0151032690760687	0.516867531180449	0.514646277119141	0.664458511402256

...
```

- Metadata: Additional statistical metadata is outputted to this file

> [output].metazscore.txt

```tsv
"Gene"	"p"	"z"	"fdr"
"CCNT1"	"CCNT1"	1.26435387776632e-54	-7.91321930179149	1.3326289871657e-51
"CXCR4"	"CXCR4"	7.26450981065823e-43	-4.68789127416631	7.64952883062311e-40
"UBE2M"	"UBE2M"	5.08315740422764e-35	-6.3513148130628	5.34748158924748e-32

...
```

- Heatmaps: Heatmaps are outputted to `results/extras`.
