#!/usr/bin/env bash
# หา image ของ Rocky Linux 10 ใน region ที่ระบุ แล้วแสดงค่าที่ต้องใส่ใน terraform.tfvars
# ใช้: ./scripts/find-rocky-image.sh [region]
set -euo pipefail
LOC="${1:-southeastasia}"

echo "== Marketplace images ของ publisher resf ใน ${LOC} (Rocky 10)"
az vm image list --publisher resf --location "$LOC" --all \
  --query "[?starts_with(sku, '10')].{offer:offer, sku:sku, version:version, urn:urn}" -o table

URN=$(az vm image list --publisher resf --offer rockylinux-x86_64 --location "$LOC" --all \
  --query "[?starts_with(sku, '10')] | sort_by(@, &version) | [-1].urn" -o tsv)

if [[ -z "$URN" ]]; then
  echo "ไม่พบ Rocky 10 ใน Marketplace ของ ${LOC} ให้ลอง region อื่น หรือใช้ image.source = \"image_id\"" >&2
  exit 1
fi

echo
echo "== รายละเอียดของ ${URN}"
az vm image show --urn "$URN" \
  --query "{urn: '${URN}', hyperVGeneration: hyperVGeneration, plan: plan, architecture: architecture}" -o json

IFS=: read -r PUB OFFER SKU VER <<<"$URN"
cat <<TFVARS

== ค่าที่ใส่ใน terraform.tfvars
image = {
  source        = "marketplace"
  publisher     = "${PUB}"
  offer         = "${OFFER}"
  sku           = "${SKU}"
  version       = "latest"
  plan_required = $(az vm image show --urn "$URN" --query "plan != null" -o tsv | tr 'A-Z' 'a-z')
}

ถ้า plan_required = true ต้องยอมรับ terms 1 ครั้งต่อ subscription:
  az vm image terms accept --urn ${PUB}:${OFFER}:${SKU}:latest
หรือตั้ง accept_marketplace_terms = true ใน terraform.tfvars
TFVARS
