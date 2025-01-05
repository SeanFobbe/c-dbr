#!/bin/bash
set -e

time docker-compose build --pull

time docker-compose run --rm c-dbr Rscript delete-all-data.R
