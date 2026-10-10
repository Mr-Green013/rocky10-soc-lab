#!/usr/bin/env bash
# บทที่ 1 ขั้นที่ 5: เปลี่ยน Proxmox VE 9 ไปใช้ no-subscription repository แล้วอัปเดตระบบ
# รันบน pve-01 ในฐานะ root:  bash pve-repos.sh
set -euo pipefail

SRC_DIR=/etc/apt/sources.list.d
. /etc/os-release                      # VERSION_CODENAME = trixie บน PVE 9
SUITE=${VERSION_CODENAME:?ไม่พบ VERSION_CODENAME ใน /etc/os-release}

[ "$(id -u)" -eq 0 ] || { echo "ต้องรันในฐานะ root" >&2; exit 1; }
command -v pveversion >/dev/null || { echo "เครื่องนี้ไม่ใช่ Proxmox VE" >&2; exit 1; }

disable_repo() {                       # ปิด repo แบบ deb822 โดยไม่ลบไฟล์ (เปิดคืนได้)
  local f=$1
  [ -f "$f" ] || return 0
  if grep -q '^Enabled:' "$f"; then
    sed -i 's/^Enabled:.*/Enabled: false/' "$f"
  else
    echo 'Enabled: false' >> "$f"
  fi
  echo "disabled  $f"
}

# 1) enterprise repo ต้องมี subscription key ไม่งั้น apt update จะได้ 401
disable_repo "$SRC_DIR/pve-enterprise.sources"
# 2) lab นี้ไม่ใช้ Ceph ปิดไว้ทั้งไฟล์
disable_repo "$SRC_DIR/ceph.sources"

# 3) no-subscription repo (เหมาะกับ lab ไม่แนะนำสำหรับ production)
cat > "$SRC_DIR/pve-no-subscription.sources" <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: $SUITE
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
echo "created   $SRC_DIR/pve-no-subscription.sources"

# รูปแบบเก่า (.list) จากการอัปเกรดจาก PVE 8 จะทำให้มี repo ซ้ำ
ENT_RE='^[[:space:]]*deb[[:space:]].*enterprise\.proxmox\.com'
if grep -Eqs "$ENT_RE" "$SRC_DIR"/*.list /etc/apt/sources.list 2>/dev/null; then
  echo "พบ enterprise repo ในไฟล์ .list ให้ลบหรือ comment บรรทัดนั้นก่อน:" >&2
  grep -Ens "$ENT_RE" "$SRC_DIR"/*.list /etc/apt/sources.list >&2 || true
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
apt-get -y install git curl rsync     # ใช้ในบทถัดไป

echo
pveversion
if [ -f /var/run/reboot-required ] || [ "$(uname -r)" != "$(ls -1 /boot/vmlinuz-*-pve | sort -V | tail -1 | sed 's|/boot/vmlinuz-||')" ]; then
  echo ">>> มี kernel ใหม่ ให้ reboot:  reboot"
fi
