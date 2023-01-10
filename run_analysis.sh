#!/bin/bash

### Configuration Section ###

# Set input folder
INPUT_FOLDER="input/Terry"

# Optionally enable / disable analysis
RUN_COMBINER=true
RUN_SNAKEMAKE=true

### Main Script Section ###

# crash on error
set -e

# start from where the script lives
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
pushd "$SCRIPT_DIR" > /dev/null

# Remove old count files and copy over new count files
mkdir -p code/AM_count_combiner/input
rm -f code/AM_count_combiner/input/*
cp "$INPUT_FOLDER"/data/* code/AM_count_combiner/input

if [[ $RUN_COMBINER == true ]]; then
  # Run the count combiner
  pushd code/AM_count_combiner > /dev/null
  echo Combining Count Files
  docker-compose up --build
  popd > /dev/null
fi

# Copy combined counts to snakemake locations
mkdir -p output/counts
mkdir -p code/JT_snakemake/results/count
mkdir -p code/JT_snakemake/results/extras
mkdir -p code/JT_snakemake/results/test

cp code/AM_count_combiner/counts_all.txt output/counts
cp code/AM_count_combiner/counts_all.txt code/JT_snakemake/results/count/

# Copy configs, ignore errors
cp "$INPUT_FOLDER/config/config_snakemake.yaml" code/JT_snakemake/config.yaml | true
cp "$INPUT_FOLDER/config/config_combiner.js" code/AM_count_combiner/config.js | true

# Make output directories if needed
mkdir -p output/snakemake

if [[ $RUN_SNAKEMAKE == true ]]; then
  # Run snakemake code
  pushd code/JT_snakemake > /dev/null
  echo Running Snakemake

  ./run.sh -r

  # Copy snakemake output
  echo Copying Snakemake output files
  cp results/extras/* ../../output/snakemake
  cp results/test/* ../../output/snakemake
  popd > /dev/null
fi

popd > /dev/null

echo All Done!
