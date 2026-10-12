#!/usr/bin/env bash
# บทที่ 2 วิธีตรวจสอบ: network, hostname และ SSH ของเครื่องนี้  (sudo bash ch02-check.sh)
set -uo pipefail
F=0
ok()   { printf '  [PASS] %s\n' "$*"; }
bad()  { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
t()    { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }

dev=$(ip -4 route show default | awk '{print $5; exit}')
echo "== Network ($dev)"
t "มี default route ผ่าน 192.168.10.1"            sh -c "ip -4 route show default | grep -q 'via 192.168.10.1'"
t "connection ชื่อ lab ใช้งานอยู่"                sh -c "nmcli -g GENERAL.CONNECTION device show $dev | grep -qx lab"
t "lab เป็น static (ipv4.method manual)"          sh -c "nmcli -g ipv4.method connection show lab | grep -qx manual"
t "lab เปิด autoconnect"                          sh -c "nmcli -g connection.autoconnect connection show lab | grep -qx yes"
t "DNS search มี lab.internal"                    grep -q '^search .*lab.internal' /etc/resolv.conf
t "ping gateway 192.168.10.1"                     ping -c1 -W2 192.168.10.1
t "resolve rockylinux.org"                        getent hosts rockylinux.org

echo "== Hostname"
t "hostname -f เป็น FQDN ใน lab.internal"         sh -c "hostname -f | grep -q '\.lab\.internal$'"
t "hostname -i ไม่ใช่ loopback"                   sh -c "! hostname -i | grep -qE '(^| )(127\.|::1)'"
t "ไม่มี FQDN อยู่บรรทัด 127.0.0.1"                sh -c "! grep -E '^127\.' /etc/hosts | grep -q lab.internal"
for h in ipa-01 graylog-01 wazuh-01 lab-linux-01 lab-linux-02 node-01 pve-01; do
  t "resolve $h.lab.internal"                     getent hosts "$h.lab.internal"
done

echo "== SSH"
t "sshd active"                                   systemctl is-active sshd
t "sshd enabled"                                  systemctl is-enabled sshd
t "firewalld อนุญาต service ssh"                  sh -c "firewall-cmd --list-services | grep -qw ssh"
t "sshd -t ผ่าน (syntax ถูก)"                     sshd -t
t "PasswordAuthentication no"                     sh -c "sshd -T | grep -qx 'passwordauthentication no'"
t "PermitRootLogin ไม่ใช่ yes"                    sh -c "! sshd -T | grep -qx 'permitrootlogin yes'"
t "มี host key แบบ ed25519"                       test -s /etc/ssh/ssh_host_ed25519_key.pub
echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
