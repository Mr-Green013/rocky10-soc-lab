#!/usr/bin/env bash
# บทที่ 3 วิธีตรวจสอบ: kernel, เวอร์ชันระบบ และเวลา  (sudo bash ch03-check.sh)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
t()   { local m=$1; shift; if "$@" >/dev/null 2>&1; then ok "$m"; else bad "$m"; fi; }
. /etc/os-release

echo "== Kernel ($(uname -r))"
t "kernel ตระกูล 6.12 ของ EL10"                     sh -c "uname -r | grep -qE '^6\.12\.0-.*\.el10'"
t "kernel ที่รันอยู่ = kernel default ตอนบูต"       sh -c "[ \"/boot/vmlinuz-\$(uname -r)\" = \"\$(grubby --default-kernel)\" ]"
t "มี BTF (/sys/kernel/btf/vmlinux) สำหรับ eBPF"   test -f /sys/kernel/btf/vmlinux
for k in CONFIG_BPF CONFIG_BPF_SYSCALL CONFIG_DEBUG_INFO_BTF; do
  t "$k=y"                                         grep -qx "$k=y" "/boot/config-$(uname -r)"
done

echo "== OS ($PRETTY_NAME)"
t "ID=rocky และ major version 10"                  sh -c "[ '$ID' = rocky ] && [ '${VERSION_ID%%.*}' = 10 ]"
t "rpm -E %rhel = 10"                              sh -c "[ \"\$(rpm -E %rhel)\" = 10 ]"

echo "== Time"
t "timezone Asia/Bangkok"                          sh -c "timedatectl show -p Timezone --value | grep -qx Asia/Bangkok"
t "NTP synchronized"                               sh -c "timedatectl show -p NTPSynchronized --value | grep -qx yes"
t "chronyd active"                                 systemctl is-active chronyd
t "pve-01 (192.168.10.1) อยู่ใน source"            sh -c "chronyc -n sources | grep -q '192\.168\.10\.1'"
t "มี source ที่เลือกใช้อยู่ (^*)"                  sh -c "chronyc -n sources | grep -q '^\^\*'"
off=$(chronyc tracking | awk -F': ' '/^System time/{print $2}')
echo "  [INFO] System time: ${off:-?}"
echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
