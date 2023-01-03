# Z-Score Calculations in R

This code is initially from [John Poirier](john.poirier@nyulangone.org) and his team. This R code is the main portion of the z-score
analysis pipeline. The input counts files are used to calculate z-scores (Add link about what this means).

No license was attached to this code, but has been shared/modified with his permission.

## Required Input Files

### These files are automatically copied from the count combiner when using the z-score analysis pipeline. Please refer to the pipeline documentation for information about that input.

- Create a directory `results/count` in this folder.
- Add a `.txt` counts file (can be renamed from `.csv` to `.txt` if needed). This is the count file that will be referenced from your
  configuration.

> counts_all.txt

```tsv
sgRNA	Gene	Experiment1R1.fastq	Experiment1R2.fastq	Experiment2R1.fastq	Experiment2R2.fastq	Experiment3R1.fastq	Experiment3R2.fastq	Experiment4R1.fastq	Experiment4R2.fastq	Experiment5R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment1R1.fastq	Experiment5R2.fastq	Experiment6R1.fastq	Experiment6R2.fastq	Experiment7R1.fastq	Experiment7R2.fastq	Experiment8R1.fastq	Experiment8R2.fastq	Experiment9R1.fastq	Experiment9R2.fastq	Experiment10R1.fastq	Experiment10R2.fastq
CHOPCHOP_vm0001	AARS1	466	558	334	352	462	480	448	394	1095	970	1312	1503	721	2680	2506	2642	2446	1757	978	2581	2825	1494	2287	2647
CHOPCHOP_vm0002	AARS1	3968	4254	2722	2486	2667	2675	2787	2628	6412	6115	8187	9608	18167	16482	17451	17582	16538	15962	16538	16441	15858	13056	15497	17063
CHOPCHOP_vm0003	AARS1	150	189	299	305	257	234	325	278	585	737	929	992	1570	1699	2827	1608	1854	1948	748	1715	1556	1260	1301	1791

...
```

- A configuration file must be added to the root of this code directory. This configuration allows control over how the analysis is run.

> config.yaml

```yaml
# Config file for all of the values to change

# Output file
counts_file: results/count/counts_all.txt

# Which columns in the counts file are treatments
treatment: Experiment1R1.fastq,Experiment1R2.fastq,Experiment2R1.fastq,Experiment2R2.fastq

# Which columns in the counts file are controls
control: Experiment3R1.fastq,Experiment3R2.fastq,Experiment4R1.fastq,Experiment4R2.fastq

# Which column in the counts file is plasmids
plasmid: Experiment5R1.fastq

# Number of sgrnas
sgrnas:
  n: 4

# Heatmap configuration
heatmapCount: 50
heatmapMin: -4
heatmapMax: 4

# File to output results to
output_file: nextseqArticuno_20201201_34.fastq.zscores.txt
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
"Experiment1R1.fastq"	"Experiment1R2.fastq"	"Experiment2R1.fastq"	"Experiment2R2.fastq"
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
