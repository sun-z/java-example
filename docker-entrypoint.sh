#!/bin/sh

set -ex;

exec /usr/bin/java \
  $JAVA_OPTS \
  -Djava.io.tmpdir="/home/app/tmp" \
  -jar \
  /home/app/example/app.jar \
  "$@"
