# syntax=docker/dockerfile:1

# Build Arguments
ARG R_VERSION="4.4.0"
ARG R_CRAN_MIRROR="https://packagemanager.posit.co/cran/__linux__/jammy/2024-06-13"

# Base Layer
FROM rocker/r-ver:${R_VERSION}

# LaTeX Layer
RUN apt-get update && apt-get install -y \
    pandoc \
    pandoc-citeproc \
    texlive-science \
    texlive-latex-extra \
    texlive-lang-german

# System Dependency Layer
COPY etc/requirements-system.txt /
RUN apt-get update && apt-get -y install $(cat /requirements-system.txt)

# R Layer
COPY etc/requirements-R.txt /
RUN /rocker_scripts/setup_R.sh ${R_CRAN_MIRROR} && \
    Rscript -e 'install.packages(readLines("/requirements-R.txt"))'

# Config Layers
WORKDIR /c-dbr
CMD R
