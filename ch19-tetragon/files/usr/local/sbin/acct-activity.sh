#!/bin/bash
# Account Activity Tracker: สรุป event จาก policy account-tracker
LOG=${1:-/var/log/tetragon/tetragon.log}
jq -r 'select(.process_kprobe.policy_name == "account-tracker")
  | .process_kprobe as $k
  | [ .time[0:19],
      ($k.process.auid | tostring),
      ($k.process.uid | tostring),
      ($k.args[0].linux_binprm_arg.path // $k.args[0].file_arg.path // "-"),
      ($k.process.binary // "-"),
      (($k.process.arguments // "") | if . == "" then "-" else . end) ] | @tsv' "$LOG" |
while IFS=$'\t' read -r t auid uid target bin args; do
  who=$(getent passwd "$auid" | cut -d: -f1); who=${who:-$auid}
  printf '%s  login=%-8s uid=%-5s target=%-18s by=%s %s\n' \
         "$t" "$who" "$uid" "$target" "$bin" "$args"
done
