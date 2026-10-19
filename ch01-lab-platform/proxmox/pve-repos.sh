#!/usr/bin/env bash
# EN: Chapter 1 step 5: switch Proxmox VE 9 to the no-subscription repository, then update the system
# บทที่ 1 ขั้นที่ 5: เปลี่ยน Proxmox VE 9 ไปใช้ no-subscription repository แล้วอัปเดตระบบ
# EN: Run on pve-01 as root: bash pve-repos.sh
# รันบน pve-01 ในฐานะ root:  bash pve-repos.sh
set -euo pipefail

SRC_DIR=/etc/apt/sources.list.d
. /etc/os-release                      # VERSION_CODENAME = trixie บน PVE 9 (EN: VERSION_CODENAME = trixie on PVE 9)
SUITE=${VERSION_CODENAME:?ไม่พบ VERSION_CODENAME ใน /etc/os-release}

[ "$(id -u)" -eq 0 ] || { echo "ต้องรันในฐานะ root" >&2; exit 1; }
command -v pveversion >/dev/null || { echo "เครื่องนี้ไม่ใช่ Proxmox VE" >&2; exit 1; }

disable_repo() {                       # ปิด repo แบบ deb822 โดยไม่ลบไฟล์ (เปิดคืนได้) (EN: disable a deb822 repo without deleting the file (can be re-enabled))
  local f=$1
  [ -f "$f" ] || return 0
  if grep -q '^Enabled:' "$f"; then
    sed -i 's/^Enabled:.*/Enabled: false/' "$f"
  else
    echo 'Enabled: false' >> "$f"
  fi
  echo "disabled  $f"
}

# EN: 1) The enterprise repo needs a subscription key, otherwise apt update gets a 401
# 1) enterprise repo ต้องมี subscription key ไม่งั้น apt update จะได้ 401
disable_repo "$SRC_DIR/pve-enterprise.sources"
# EN: 2) This lab does not use Ceph; disable the whole file
# 2) lab นี้ไม่ใช้ Ceph ปิดไว้ทั้งไฟล์
disable_repo "$SRC_DIR/ceph.sources"

# EN: 3) The no-subscription repo (fine for a lab, not recommended for production)
# 3) no-subscription repo (เหมาะกับ lab ไม่แนะนำสำหรับ production)
cat > "$SRC_DIR/pve-no-subscription.sources" <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: $SUITE
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
echo "created   $SRC_DIR/pve-no-subscription.sources"

# EN: Old-style (.list) files left from an upgrade from PVE 8 would duplicate the repos
# รูปแบบเก่า (.list) จากการอัปเกรดจาก PVE 8 จะทำให้มี repo ซ้ำ
ENT_RE='^[[:space:]]*deb[[:space:]].*enterprise\.proxmox\.com'
if grep -Eqs "$ENT_RE" "$SRC_DIR"/*.list /etc/apt/sources.list 2>/dev/null; then
  echo "พบ enterprise repo ในไฟล์ .list ให้ลบหรือ comment บรรทัดนั้นก่อน:" >&2
  grep -Ens "$ENT_RE" "$SRC_DIR"/*.list /etc/apt/sources.list >&2 || true
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
apt-get -y install git curl rsync     # ใช้ในบทถัดไป (EN: used in later chapters)

echo
pveversion
if [ -f /var/run/reboot-required ] || [ "$(uname -r)" != "$(ls -1 /boot/vmlinuz-*-pve | sort -V | tail -1 | sed 's|/boot/vmlinuz-||')" ]; then
  echo ">>> มี kernel ใหม่ ให้ reboot:  reboot"
fi
