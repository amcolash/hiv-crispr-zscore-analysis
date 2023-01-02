# Columns to Rows

This code was written by [Andrew McOlash](https://github.com/amcolash/) to turn columns of data from existing MAGeCK gene summaries + z-score analysis output files
into rows for data visualization within Tableau.

_This code does run the statistical analyses to create MAGeCK or z scores._

This was a one-time conversion but should be simple to use if needed in other scenarios.
This script may not be useful for everyone, but was used in the Tableau visualization for the paper.

## Required Input Files

- Create a directory called `input/` in this folder.
- Add all median normalized MAGeCK gene summaries for each CRISPR screen (these should be in `.csv` format) to the `input/` folder.

> example.csv

```csv
id,num,neg|score,neg|p-value,neg|fdr,neg|rank,neg|goodsgrna,neg|lfc,pos|score,pos|p-value,pos|fdr,pos|rank,pos|goodsgrna,pos|lfc
CCR5,8,6.3802E-10,4.6969E-06,0.00033,1,7,-0.75804,0.9251,0.96588,0.999995,968,1,-0.75804
CCNT1,8,7.397E-10,4.6969E-06,0.00033,2,7,-1.7452,0.95832,0.97714,0.999995,980,1,-1.7452
KMT2A,8,5.3564E-08,4.6969E-06,0.00033,3,7,-1.4363,0.9952,0.99485,0.999995,1019,0,-1.4363

...
```

- A file specifically named `zscores.csv` is needed. This is a the output from the z-score analysis which has been converted to `.csv` from `.txt` and has an additional column `id`.

> zscores.csv

```csv
id,Experiment1 R1,Experiment1 R2,Experiment2 R1,Experiment2 R2,Experiment3 R1,Experiment3 R2,Experiment4 R1,Experiment4 R2,Experiment5 R1,Experiment5 R2
AARS1,0.390949254,-0.230691792,-0.251894749,-1.033276241,0.209674081,-0.744347951,0.275783572,-0.120453123,-0.369544279,0.310066925
ABCB6,-0.009215916,1.106322173,1.588210611,1.22942758,1.056921791,0.326747099,0.691375062,0.282985941,0.144325424,1.028594322
ABCD1,0.021359248,0.730961073,-0.551333061,0.311979561,0.727819745,0.939686238,0.360554279,0.653421291,-0.304985332,-0.435151182

...
```

## Script Usage

This script can be run most easily using [Docker](https://www.docker.com/). This is already a prerequisite of running the main analysis pipeline, so there is no additional setup required.

Running the script is simple. Open a terminal, move into this code directory and run the script via docker.

```
$ cd hiv-crispr-zscore-analysis/code/AM_cols2rows
$ docker-compose up --build
```

## Output Files

The script will output a single file named `output.csv`. Each row will contain all information for a given experiment and a single gene.

> output.csv

```csv
id,num,neg|score,neg|p-value,neg|fdr,neg|rank,neg|goodsgrna,neg|lfc,pos|score,pos|p-value,pos|fdr,pos|rank,pos|goodsgrna,pos|lfc,screen,zscore r1,zscore r2,uuid
CCR5,8,6.3802E-10,4.6969E-06,0.00033,1,7,-0.75804,0.9251,0.96588,0.999995,968,1,-0.75804,Experiment1,-2.747746832,-3.24394513,5029609
...
CCR5,8,0.23775,0.511,0.99976,400,4,0.030569,0.082279,0.25719,0.793191,330,4,0.030569,Experiment2,0.951309409,0.21960513,5029609
...
CCR5,8,0.15792,0.35236,0.999995,292,4,0.11354,0.0093532,0.040548,0.724709,53,4,0.11354,Experiment3,1.651241749,1.125185157,5029609

...
```
