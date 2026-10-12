#!/bin/bash
# Wazuh active response: pause | kill-shell | quarantine
set -u
LOG=${AR_LOG:-/var/ossec/logs/active-responses.log}
DOCKER=${DOCKER_BIN:-/usr/bin/docker}
log() { echo "$(date '+%Y/%m/%d %H:%M:%S') container-response: $*" >> "$LOG"; }

read -r INPUT
CMD=$(jq -r '.command // empty' <<<"$INPUT")
MODE=$(jq -r '.parameters.extra_args[0] // "pause"' <<<"$INPUT")
CID=$(jq -r '(.parameters.alert.data.docker.Actor.ID
             // .parameters.alert.data.output_fields["container.id"]
             // .parameters.alert.data.output_fields.container.id
             // .parameters.alert.data.process_kprobe.process.docker
             // empty)' <<<"$INPUT")

[[ "$CMD" == "add" ]] || exit 0
[[ "$CID" =~ ^[0-9a-f]{12,64}$ ]] || { log "error no-container-id (-)"; exit 0; }

NAME=$("$DOCKER" inspect -f '{{.Name}}' "$CID" 2>/dev/null | tr -d '/')
[[ -n "$NAME" ]] || { log "error not-found ($CID)"; exit 0; }

OPTOUT=$("$DOCKER" inspect -f '{{index .Config.Labels "soc.autoresponse"}}' "$CID" 2>/dev/null)
if [[ "$OPTOUT" == "off" ]]; then
  log "skip $NAME ($CID): label soc.autoresponse=off"; exit 0
fi

case "$MODE" in
  pause)
    if "$DOCKER" pause "$CID" >/dev/null 2>&1; then log "paused $NAME ($CID)"
    else log "pause-failed $NAME ($CID)"; fi ;;
  kill-shell)
    INIT=$("$DOCKER" inspect -f '{{.State.Pid}}' "$CID" 2>/dev/null); killed=0
    while read -r pid comm; do
      [[ "$pid" == "$INIT" ]] && continue
      case "$comm" in
        sh|bash|dash|ash|zsh) kill -9 "$pid" 2>/dev/null && killed=$((killed + 1)) ;;
      esac
    done < <("$DOCKER" top "$CID" -eo pid,comm 2>/dev/null | tail -n +2)
    log "kill-shell $NAME ($CID): killed $killed shell process(es)" ;;
  quarantine)
    for net in $("$DOCKER" inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$CID" 2>/dev/null); do
      "$DOCKER" network disconnect -f "$net" "$CID" >/dev/null 2>&1 \
        && log "quarantine $NAME ($CID): disconnected from $net"
    done ;;
  *) log "error unknown-mode ($MODE)" ;;
esac
exit 0
