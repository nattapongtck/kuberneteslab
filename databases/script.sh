#!/bin/sh

set -e
mongoimport --host localhost --username root --password ratings-dev \
  --db ratings-dev --collection ratings --drop --file /docker-entrypoint-initdb.d/ratings_data.json
