#!/bin/bash

# crash on error
set -e

# Optionally enable / disable analysis
RUN_COMBINER=true
RUN_PYTHON=true
RUN_SNAKEMAKE=true

# start from where the script lives
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
pushd "$SCRIPT_DIR" > /dev/null

# Remove old count files and copy over new count files
mkdir -p code/AM_count_combiner/input
rm -f code/AM_count_combiner/input/*
cp input_counts/* code/AM_count_combiner/input

if [[ $RUN_COMBINER == true ]]; then
  # Run the count combiner
  pushd code/AM_count_combiner > /dev/null
  echo Combining Count Files
  docker-compose up --build
  popd > /dev/null
fi

# Copy combined counts to python/snakemake locations
mkdir -p output_counts
mkdir -p code/JT_snakemake/results/count
mkdir -p code/JT_snakemake/results/extra
mkdir -p code/JT_snakemake/results/test

cp code/AM_count_combiner/counts_all.txt output_counts
cp code/AM_count_combiner/counts_all.txt code/PR_python/
cp code/AM_count_combiner/counts_all.txt code/JT_snakemake/results/count/

# Copy python/snakemake configs
cp config_snakemake.yaml code/JT_snakemake/config.yaml
cp config_python.py code/PR_python/config.py
cp config_combiner.js code/AM_count_combiner/config.js

# Make output directories if needed
mkdir -p output_python
mkdir -p output_snakemake

if [[ $RUN_PYTHON == true ]]; then
  # Run python code
  pushd code/PR_python > /dev/null
  echo Running Python
  mkdir -p output
  python3 process.py

  # Copy python output
  echo Copying Python output files
  cp output/* ../../output_python
  popd > /dev/null
fi

if [[ $RUN_SNAKEMAKE == true ]]; then
  # Run snakemake code
  pushd code/JT_snakemake > /dev/null
  echo Running Snakemake
  
  ./run.sh -r

  # Copy snakemake output
  echo Copying Snakemake output files
  cp results/extras/* ../../output_snakemake
  cp results/test/* ../../output_snakemake
  popd > /dev/null
fi

popd > /dev/null

echo All Done!
