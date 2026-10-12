#!/bin/bash
ids=$(/usr/bin/docker ps -q) || exit 0
[ -z "$ids" ] && exit 0
/usr/bin/docker inspect \
  -f '{{.Id}} {{.Name}} {{range .Mounts}}{{.Source}} {{end}}' $ids \
  | grep -F docker.sock
exit 0
