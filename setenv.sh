#!/bin/sh
  
# Pass K8s env to JVM system properties
CATALINA_OPTS="$CATALINA_OPTS \
  -DDB_HOST=${DB_HOST} \
  -DDB_PORT=${DB_PORT} \
  -DDB_NAME=${DB_NAME} \
  -DDB_USER=${DB_USER} \
  -DDB_PASSWORD=${DB_PASSWORD}"
export CATALINA_OPTS
