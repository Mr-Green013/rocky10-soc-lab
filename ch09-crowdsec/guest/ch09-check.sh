#!/usr/bin/env bash
# EN: Chapter 9 verification: CrowdSec, bouncer, whitelist, Tor import and restoring sshd (sudo bash ch09-check.sh)
# บทที่ 9 วิธีตรวจสอบ: CrowdSec, bouncer, whitelist, Tor import และการคืนค่า sshd  (sudo bash ch09-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }
ADMIN_IP=${ADMIN_IP:-192.168.10.100}

echo "== CrowdSec"
command -v cscli >/dev/null || { bad "ไม่พบ cscli (ยังไม่ได้ติดตั้ง crowdsec)"; echo "ผลรวม: FAIL $F ข้อ"; exit "$F"; }
for s in crowdsec crowdsec-firewall-bouncer; do
  if systemctl is-active --quiet "$s"; then ok "$s active"; else bad "$s ไม่ active"; fi
done
nb=$(cscli bouncers list -o json 2>/dev/null | grep -c '"name"')
if [ "${nb:-0}" -ge 1 ]; then ok "bouncer ลงทะเบียนกับ LAPI ($nb ตัว)"; else bad "ไม่มี bouncer ที่ลงทะเบียน"; fi
if cscli collections list 2>/dev/null | grep -q 'crowdsecurity/sshd'; then ok "collection crowdsecurity/sshd ติดตั้งแล้ว"; else bad "ไม่มี collection crowdsecurity/sshd"; fi
read_lines=$(cscli metrics show acquisition 2>/dev/null | awk '/file:|journalctl:/ {s+=$2} END {print s+0}')
if [ "${read_lines:-0}" -gt 0 ]; then ok "acquisition อ่าน log แล้ว (Lines read > 0)"; else bad "acquisition ยังไม่อ่าน log (ตรวจ acquis.yaml)"; fi
if grep -rqs -- "$ADMIN_IP" /etc/crowdsec/parsers/s02-enrich/; then ok "whitelist ของเครื่อง admin $ADMIN_IP"; else bad "ไม่พบ whitelist ของ $ADMIN_IP ใน parsers/s02-enrich"; fi
if cscli parsers list 2>/dev/null | grep -q 'crowdsecurity/whitelists'; then warn "ยังมี crowdsecurity/whitelists (การทดสอบจาก lab จะไม่ถูกตรวจจับ)"; else ok "ถอด crowdsecurity/whitelists แล้ว (เฉพาะ lab)"; fi
if cscli alerts list --all -o raw 2>/dev/null | grep -q 'ssh-bf'; then ok "เคยเกิด alert crowdsecurity/ssh-bf"; else bad "ยังไม่เคยเกิด alert ssh-bf (ทำการทดสอบจาก lab-linux-02)"; fi
if cscli decisions list --ip "$ADMIN_IP" -o raw 2>/dev/null | grep -q "$ADMIN_IP"; then bad "$ADMIN_IP ถูก ban อยู่"; else ok "$ADMIN_IP ไม่ถูก ban"; fi
if cscli decisions list --ip 192.168.10.42 -o raw 2>/dev/null | grep -q '192.168.10.42'; then warn "192.168.10.42 (lab-linux-02) ยังถูก ban ปลดก่อนเริ่มบทที่ 10"; fi

echo "== Tor blocklist"
if systemctl is-active --quiet crowdsec-tor-import.timer; then ok "crowdsec-tor-import.timer active"; else bad "crowdsec-tor-import.timer ไม่ active"; fi
ni=$(cscli decisions list --origin cscli-import -o raw --limit 0 2>/dev/null | grep -c 'tor-exit-node')
if [ "${ni:-0}" -ge 100 ]; then ok "decision จาก cscli-import $ni รายการ"; else bad "decision จาก cscli-import มีเพียง ${ni:-0} รายการ"; fi

echo "== คืนค่า sshd"
if [ -e /etc/ssh/sshd_config.d/00-lab-password.conf ]; then bad "ยังมี 00-lab-password.conf"; else ok "ไม่มี 00-lab-password.conf"; fi
pa=$(sshd -T 2>/dev/null | awk '$1=="passwordauthentication" {print $2}')
if [ "$pa" = "no" ]; then ok "passwordauthentication = no"; else bad "passwordauthentication = ${pa:-ไม่พบ}"; fi

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
