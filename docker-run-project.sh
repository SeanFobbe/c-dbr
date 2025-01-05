#!/bin/bash
set -e

time docker-compose build --pull

time docker-compose run --rm c-dbr Rscript run_project.R
