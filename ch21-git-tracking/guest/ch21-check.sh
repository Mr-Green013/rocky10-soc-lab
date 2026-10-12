#!/usr/bin/env bash
# บทที่ 21 วิธีตรวจสอบ: git tracking และ blocking  (sudo bash ch21-check.sh บน node-01 หรือ lab-linux-01)
set -uo pipefail
F=0
ok()  { printf '  [PASS] %s\n' "$*"; }
bad() { printf '  [FAIL] %s\n' "$*"; F=$((F+1)); }
warn(){ printf '  [WARN] %s\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "ต้องรันด้วย sudo"; exit 99; }

case "$(hostname -s)" in
  node-01)
    echo "== บทบาท: เครื่องนักพัฒนา (node-01)"
    if auditctl -l 2>/dev/null | grep -q 'key=git_cmd\|-k git_cmd'; then ok "audit rule git_cmd โหลดแล้ว"; else bad "ไม่พบ audit rule git_cmd"; fi
    h=/etc/git-guard/hooks/pre-push
    if [ -x "$h" ] && [ "$(stat -c %a "$h")" = 755 ]; then ok "$h ทำงานได้ (755)"; else bad "$h ไม่มีหรือสิทธิ์ไม่ใช่ 755"; fi
    hp=$(git config --system --get core.hooksPath 2>/dev/null)
    if [ "$hp" = /etc/git-guard/hooks ]; then ok "core.hooksPath ระดับ system = $hp"; else bad "core.hooksPath ระดับ system = ${hp:-ไม่ได้ตั้ง}"; fi
    if command -v tetra >/dev/null && tetra tracingpolicy list 2>/dev/null | grep -q git-egress; then ok "Tetragon policy git-egress โหลดแล้ว"; else bad "Tetragon policy git-egress ยังไม่โหลด"; fi
    if [ -f /etc/tetragon/tetragon.tp.d/85-git-egress.yaml ]; then ok "policy git-egress อยู่ใน tetragon.tp.d (คงอยู่หลัง reboot)"; else warn "ยังไม่ได้คัดลอก policy ไป /etc/tetragon/tetragon.tp.d/ (หัวข้อ Cleanup)"; fi
    ;;
  lab-linux-01)
    echo "== บทบาท: git server ที่อนุมัติ"
    r=/srv/git/demo.git
    if [ -d "$r" ]; then
      for k in receive.denyNonFastForwards receive.denyDeletes; do
        v=$(git --git-dir="$r" config --get "$k" 2>/dev/null)
        if [ "$v" = true ]; then ok "$k = true"; else bad "$k = ${v:-ไม่ได้ตั้ง}"; fi
      done
    else bad "ไม่พบ $r"; fi
    if getent hosts git.lab.internal | grep -q '192.168.10.41'; then ok "git.lab.internal ชี้ไปที่ 192.168.10.41"; else bad "git.lab.internal ไม่ชี้ไปที่ lab-linux-01"; fi
    ;;
  *) warn "รันบน node-01 หรือ lab-linux-01 เท่านั้น" ;;
esac

echo; [ "$F" -eq 0 ] && echo "ผลรวม: ผ่านทุกข้อ" || echo "ผลรวม: FAIL $F ข้อ"
exit "$F"
