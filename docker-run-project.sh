#!/bin/bash
set -e

time docker-compose run --build --rm c-dbr Rscript run_project.R
