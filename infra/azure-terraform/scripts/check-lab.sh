#!/usr/bin/env bash
# ตรวจผลของ cloud-init ทุกเครื่องผ่าน ssh config ที่ได้จาก `terraform output -raw ssh_config`
# ใช้: ./scripts/check-lab.sh
set -uo pipefail
HOSTS=(admin-01 ipa-01 graylog-01 wazuh-01 lab-linux-01 lab-linux-02 node-01)

printf '%-13s %-26s %-10s %-9s %-9s %s\n' HOST FQDN CLOUDINIT SELINUX FIREWALL TZ
for h in "${HOSTS[@]}"; do
  out=$(ssh -o BatchMode=yes -o ConnectTimeout=10 "$h" '
    s=$(cloud-init status --wait 2>/dev/null | awk "/status:/ {print \$2}")
    printf "%s|%s|%s|%s|%s" "$(hostname -f)" "${s:-unknown}" "$(getenforce)" \
      "$(systemctl is-active firewalld)" "$(timedatectl show -p Timezone --value)"
  ' 2>/dev/null) || out="unreachable||||"
  IFS='|' read -r fqdn ci se fw tz <<<"$out"
  printf '%-13s %-26s %-10s %-9s %-9s %s\n' "$h" "$fqdn" "$ci" "$se" "$fw" "$tz"
done

echo
echo "== ทุกเครื่อง resolve ชื่อกันได้และออก internet ได้ (ทดสอบจาก node-01)"
ssh -o BatchMode=yes node-01 '
  for n in ipa-01 graylog-01 wazuh-01 lab-linux-01 lab-linux-02; do
    printf "%-26s %s\n" "$n.lab.internal" "$(getent hosts $n.lab.internal | awk "{print \$1}")"
  done
  curl -s -o /dev/null -w "internet (via NAT): HTTP %{http_code}\n" https://rockylinux.org/
'
