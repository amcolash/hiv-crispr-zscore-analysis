# The running build can specify an alternate image (default is x86, arm64 is supported too)
ARG IMAGE=snakemake/snakemake

# Use snakemake base image
FROM $IMAGE

# Install yq
COPY yq_linux_amd64 /usr/bin/yq

# Create app directory
WORKDIR /zscore
