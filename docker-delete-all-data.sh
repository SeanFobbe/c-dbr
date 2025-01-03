#!/bin/bash
set -e

time docker-compose run --build --rm c-dbr Rscript delete-all-data.R
