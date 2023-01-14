#!/bin/bash

### Configuration Section ###

# Set input folder
INPUT_FOLDER="input/Terry"

# Optionally enable / disable analysis
RUN_COMBINER=true
RUN_SNAKEMAKE=true

### Main Script Section ###

# crash on error
set -eE

# Trap errors
trap handle_error ERR

# Handler for errors
function handle_error() {
  echo
  echo "*** An error occured. Please read the logs and retry. The data in the output folder may be innacurate! ***"
}

# start from where the script lives
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
pushd "$SCRIPT_DIR" > /dev/null

# Make output directories if needed
OUTDIR="${INPUT_FOLDER/input\//}"
mkdir -p output/"$OUTDIR"/counts
mkdir -p output/"$OUTDIR"/snakemake

# Remove old count files and copy over new count files
mkdir -p code/AM_count_combiner/input
rm -f code/AM_count_combiner/input/*
cp "$INPUT_FOLDER"/data/* code/AM_count_combiner/input

  # Run the count combiner
  pushd code/AM_count_combiner > /dev/null
  echo Combining Count Files
  docker-compose up --build
  popd > /dev/null

# Make snakemake input dirs
mkdir -p code/JT_snakemake/results/count
mkdir -p code/JT_snakemake/results/extras
mkdir -p code/JT_snakemake/results/test

# Copy combined counts to snakemake locations
cp code/AM_count_combiner/counts_all.txt output/"$OUTDIR"/counts
cp code/AM_count_combiner/counts_all.txt code/JT_snakemake/results/count/

# Copy configs, ignore errors
cp "$INPUT_FOLDER/config/config_snakemake.yaml" code/JT_snakemake/config.yaml | true
cp "$INPUT_FOLDER/config/config_combiner.js" code/AM_count_combiner/config.js | true

  # Run snakemake code
  pushd code/JT_snakemake > /dev/null
  echo Running Snakemake

# Run Z-Score analysis
  ./run.sh -r

  # Copy snakemake output
  echo Copying Snakemake output files
cp results/extras/* ../../output/"$OUTDIR"/snakemake
cp results/test/* ../../output/"$OUTDIR"/snakemake

# Move back to base dir
  popd > /dev/null
popd > /dev/null

echo All Done!
