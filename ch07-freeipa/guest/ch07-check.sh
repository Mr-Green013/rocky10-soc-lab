#!/usr/bin/env bash
# EN: Chapter 7 verification: on ipa-01 checks the server services, on other machines checks client enrollment (sudo bash ch07-check.sh)
# บทที่ 7 วิธีตรวจสอบ: บน ipa-01 ตรวจ service ของ server, เครื่องอื่นตรวจการเป็น client  (sudo bash ch07-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
t()   { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
IPA_IP=192.168.10.10

if systemctl cat ipa.service >/dev/null 2>&1; then   # ipa.service มีเฉพาะบน server (EN: ipa.service exists only on the server)
  echo "== บทบาท: IPA server"
  out=$(ipactl status 2>&1)
  for s in "Directory Service" krb5kdc kadmin named httpd pki-tomcatd; do
    if grep -q "$s Service: RUNNING" <<<"$out"; then ok "$s RUNNING"; else bad "$s ไม่ RUNNING"; fi
  done
  t "DNS ตอบ ipa-01.lab.internal" sh -c "dig +short ipa-01.lab.internal @127.0.0.1 | grep -qx $IPA_IP"
  t "SRV _kerberos._udp.lab.internal" sh -c "dig +short SRV _kerberos._udp.lab.internal @127.0.0.1 | grep -q ipa-01"
  t "forwarder ทำงาน (resolve ชื่อภายนอก)" sh -c "dig +short rockylinux.org @127.0.0.1 | grep -q ."
  t "firewall เปิด freeipa-4 และ dns" sh -c "firewall-cmd --list-services | grep -qw freeipa-4 && firewall-cmd --list-services | grep -qw dns"
else
  echo "== บทบาท: IPA client"
  if [ -f /etc/ipa/default.conf ] && grep -q 'LAB.INTERNAL' /etc/ipa/default.conf; then ok "/etc/ipa/default.conf มีอยู่ (realm LAB.INTERNAL)"; else bad "ยังไม่ได้ join domain"; fi
  t "sssd active" systemctl is-active --quiet sssd
  if grep -Eq "^nameserver\s+$IPA_IP" /etc/resolv.conf; then ok "DNS ชี้ไปที่ $IPA_IP"; else bad "DNS ไม่ได้ชี้ไปที่ $IPA_IP"; fi
  t "SRV _ldap._tcp.lab.internal → ipa-01.lab.internal" sh -c "dig +short SRV _ldap._tcp.lab.internal | grep -q ipa-01.lab.internal"
  t "getent passwd admin ผ่าน SSSD" sh -c "getent passwd admin | grep -q . && ! grep -q '^admin:' /etc/passwd"
  t "nsswitch: sudoers ใช้ sss" grep -Eq '^sudoers:.*sss' /etc/nsswitch.conf
  t "sshd ใช้ sss_ssh_authorizedkeys" sh -c "sshd -T 2>/dev/null | grep -qi 'authorizedkeyscommand /usr/bin/sss_ssh_authorizedkeys'"
  if authselect current 2>/dev/null | grep -q with-mkhomedir; then ok "home ถูกสร้างอัตโนมัติ (with-mkhomedir)"; else warn "ยังไม่เปิด with-mkhomedir"; fi
fi
off=$(chronyc tracking 2>/dev/null | awk '/^System time/ {print $4}')
if [ -n "$off" ] && awk -v o="$off" 'BEGIN{exit !(o < 1)}'; then ok "เวลาต่างจากแหล่งเวลาไม่เกิน 1 วินาที"; else bad "เวลาคลาด (${off:-ไม่ทราบ} วินาที) Kerberos จะล้มเหลว"; fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
