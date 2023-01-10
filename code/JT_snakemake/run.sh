#!/bin/bash

process() {
  FILE=$(yq e '.output_file' config.yaml)

  echo Running Snakemake

  # Remove old files
  rm -f results/test/$FILE

  # Run snakemake for new file
  snakemake --unlock
  snakemake --jobs 1 --quiet --use-conda results/test/$FILE
}

run() {
  docker-compose build --no-rm
  docker-compose run snakemake bash -c "./run.sh"
}

watch() {
  nodemon -e "yml,R,sh,Snakefile" --exec "./run.sh -r" --delay 2
}

if [ -f /.dockerenv ]; then
  process
elif [[ $1 == "-w" ]]; then
  watch
elif [[ $1 == "-r" ]]; then
  run
else
  echo "Usage: run.sh [-w] [-r]"
  echo "-w  Watch files and reload as needed"
  echo "-r  Do a single run and then quit"
  exit 1
fi
