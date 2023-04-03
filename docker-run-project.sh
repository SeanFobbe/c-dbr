#!/bin/bash
set -e

time docker build -t c-dbr:4.2.2 .

time docker-compose run --rm c-dbr Rscript run_project.R
