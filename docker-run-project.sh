#!/bin/bash
set -e

time docker build -t c-dbr:4.4.0 .

time docker-compose run --rm c-dbr Rscript run_project.R
