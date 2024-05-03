#!/bin/bash

set -e

cd /opt/myapp/webapp
./mvnw clean install -DskipTests 
# skip test first, and try run with test
