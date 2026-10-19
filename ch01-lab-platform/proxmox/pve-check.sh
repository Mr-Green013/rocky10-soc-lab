#!/usr/bin/env bash
# EN: Chapter 1 verification: check that pve-01 is fully ready, in one run
# บทที่ 1 วิธีตรวจสอบ: ตรวจความพร้อมของ pve-01 ทั้งหมดในครั้งเดียว
# EN: Run on pve-01 as root: bash pve-check.sh
# รันบน pve-01 ในฐานะ root:  bash pve-check.sh
# EN: exit code = number of FAILed checks
# exit code = จำนวนข้อที่ FAIL
set -uo pipefail

FAILS=0
pass() { printf '  [PASS] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*"; FAILS=$((FAILS + 1)); }
warn() { printf '  [WARN] %s\n' "$*"; }
check() { local msg=$1; shift; if "$@" >/dev/null 2>&1; then pass "$msg"; else fail "$msg"; fi; }

echo "== Proxmox"
if command -v pveversion >/dev/null; then pass "$(pveversion)"; else fail "ไม่พบ pveversion"; fi

echo "== Nested virtualization"
check "CPU มี flag vmx/svm (Hyper-V ส่ง VT-x/AMD-V ให้ VM)" grep -qwE 'vmx|svm' /proc/cpuinfo
check "/dev/kvm พร้อมใช้" test -c /dev/kvm
check "kvm_intel หรือ kvm_amd module โหลดแล้ว" grep -qwE 'kvm_intel|kvm_amd' /proc/modules
missing=""
for f in avx avx2 bmi1 bmi2 f16c fma abm movbe xsave; do grep -qw "$f" /proc/cpuinfo || missing="$missing $f"; done
if [ -z "$missing" ]; then pass "CPU รองรับ x86-64-v3 (Rocky Linux 10 ต้องการ)"; else fail "CPU ขาด flag:$missing"; fi

echo "== Network"
ip -4 -br addr show vmbr0 | grep -q '172\.31\.255\.2/24' && pass "vmbr0 = 172.31.255.2/24" || fail "vmbr0 ไม่ใช่ 172.31.255.2/24"
ip -4 -br addr show vmbr1 2>/dev/null | grep -q '192\.168\.10\.1/24' && pass "vmbr1 = 192.168.10.1/24" || fail "vmbr1 ไม่ใช่ 192.168.10.1/24"
[ "$(cat /proc/sys/net/ipv4/ip_forward)" = 1 ] && pass "ip_forward = 1" || fail "ip_forward = 0"
iptables -t nat -S POSTROUTING 2>/dev/null | grep -q -- '-s 192.168.10.0/24 -o vmbr0 -j MASQUERADE' \
  && pass "NAT 192.168.10.0/24 -> vmbr0" || fail "ไม่พบ NAT rule ของ 192.168.10.0/24"
check "ping gateway ของ Windows (172.31.255.1)" ping -c1 -W2 172.31.255.1
check "ping internet (1.1.1.1)" ping -c1 -W2 1.1.1.1
check "DNS resolve download.proxmox.com" getent hosts download.proxmox.com
if ping -c1 -W2 192.168.10.100 >/dev/null 2>&1; then
  pass "ping Windows ฝั่ง lab (192.168.10.100)"
else
  warn "ping 192.168.10.100 ไม่ตอบ: ปกติถ้า Windows Firewall บล็อก ICMP (ดูหัวข้อวิธีแก้ปัญหา)"
fi

echo "== Repository"
ent=/etc/apt/sources.list.d/pve-enterprise.sources
if [ ! -f "$ent" ] || grep -q '^Enabled: false' "$ent"; then pass "ปิด enterprise repo แล้ว"; else fail "enterprise repo ยังเปิดอยู่"; fi
check "มี pve-no-subscription repo" test -f /etc/apt/sources.list.d/pve-no-subscription.sources

echo "== Storage"
if pvesm status 2>/dev/null | awk '$1=="local-lvm" && $3=="active"{f=1} END{exit !f}'; then
  free_gb=$(pvesm status 2>/dev/null | awk '$1=="local-lvm"{printf "%d", $6/1024/1024}')
  pass "local-lvm active (ว่าง ${free_gb} GB)"
  [ "${free_gb:-0}" -ge 400 ] || warn "ที่ว่างใน local-lvm น้อยกว่า 400 GB (ทั้ง lab ใช้ประมาณ 370 GB)"
else
  fail "ไม่พบ storage local-lvm"
fi

echo "== VMs"
if qm list 2>/dev/null | awk 'NR>1' | grep -q .; then
  qm list | sed 's/^/  /'
else
  warn "ยังไม่มี VM (ปกติถ้ายังไม่ถึงขั้นที่ 8)"
fi

echo
if [ "$FAILS" -eq 0 ]; then echo "ผลรวม: ผ่านทุกข้อ"; else echo "ผลรวม: FAIL $FAILS ข้อ ดูตารางวิธีแก้ปัญหาในบทที่ 1"; fi
exit "$FAILS"
