[English](README.md) · **ภาษาไทย**

# SOC Lab บน Azure ด้วย Terraform

สร้างเครื่องทั้งหมดของหลักสูตร Lab 1–40 บน Azure ด้วยคำสั่งเดียว พร้อม base config ที่แทน Lab 1–8 ได้ (hostname, FQDN, timezone, `/etc/hosts`, firewalld, SELinux enforcing, ผู้ใช้ `aod` + SSH key) IP ทุกเครื่องตรงกับเอกสารหลักสูตร จึงใช้คำสั่งในเอกสารต่อได้เลย

## สิ่งที่ถูกสร้าง

| Resource | ชื่อ | หมายเหตุ |
| --- | --- | --- |
| Resource group | `rg-soclab` | ลบทั้งหมดด้วย `terraform destroy` |
| VNet / subnet | `vnet-soclab` 192.168.0.0/16, `snet-lab` 192.168.10.0/24 | gateway .1 เป็นของ Azure |
| NSG | `nsg-soclab-lab` | เปิดเฉพาะ SSH จาก `admin_source_cidrs` ไปที่ admin-01 |
| NAT Gateway + public IP | `ng-soclab` | ทุกเครื่องออก internet ทางนี้ทางเดียว |
| VM 7 เครื่อง | ตามตารางล่าง | Rocky Linux 10.1, ไม่มี password, SSH key เท่านั้น |
| Auto-shutdown | ทุก VM | deallocate ทุกวัน 22:00 (เวลาไทย) |

| เครื่อง | IP | ขนาด default | Disk | หน้าที่ |
| --- | --- | --- | --- | --- |
| admin-01 | 192.168.10.100 (+ public IP) | Standard_B2s | 32 GB | jump host แทน admin workstation |
| ipa-01 | 192.168.10.10 | Standard_B2ms | 64 GB | FreeIPA |
| graylog-01 | 192.168.10.20 | Standard_B4ms | 128 GB | Graylog 7.1 (Docker Compose) |
| wazuh-01 | 192.168.10.30 | Standard_B4ms | 128 GB | Wazuh all-in-one |
| lab-linux-01 | 192.168.10.41 | Standard_B2s | 32 GB | Linux server, git server |
| lab-linux-02 | 192.168.10.42 | Standard_B2s | 32 GB | เครื่องโจมตีจำลอง, Samba |
| node-01 | 192.168.10.50 | Standard_B2ms | 64 GB | Docker, Falco, Tetragon, WordPress |

รวม 18 vCPU ตระกูล B-series

## สิ่งที่ต้องมีก่อน

1. Azure CLI login แล้ว (`az login`, `az account set -s <subscription>`)
2. Terraform 1.6 ขึ้นไป
3. SSH key: `ssh-keygen -t ed25519` ถ้ายังไม่มี
4. Quota ของ B-series ใน region ที่ใช้ต้องพอ 18 vCPU (subscription ใหม่มักได้น้อยกว่านี้)

```bash
az vm list-usage -l southeastasia -o table | grep -E "Total Regional vCPUs|Standard BS Family"
```

ถ้าไม่พอ ขอเพิ่มที่ portal: **Quotas → Compute** หรือลดขนาดผ่าน `vm_sizes`

## ขั้นตอน

### 1. หา image ของ Rocky Linux 10.1

ชื่อ SKU ของ Rocky 10 บน Marketplace และการมีหรือไม่มี plan ต่างกันตาม region ให้ตรวจก่อนทุกครั้ง

```bash
./scripts/find-rocky-image.sh southeastasia
```

script จะพิมพ์บล็อก `image = { ... }` ให้คัดลอกไปใส่ใน `terraform.tfvars` ถ้าไม่พบ Rocky 10 ใน region นั้น ให้เปลี่ยน region หรือใช้ `image.source = "image_id"` กับ image จาก Community Gallery หรือ Azure Compute Gallery ของตัวเอง

ถ้า image มี plan ต้องยอมรับ terms 1 ครั้งต่อ subscription

```bash
az vm image terms accept --urn resf:rockylinux-x86_64:<sku>:latest
```

### 2. ตั้งค่า

```bash
cp terraform.tfvars.example terraform.tfvars
curl -s https://api.ipify.org; echo        # public IP ของคุณ ใส่ใน admin_source_cidrs เป็น x.x.x.x/32
vi terraform.tfvars
```

### 3. สร้าง

```bash
terraform init
terraform plan -out lab.tfplan
terraform apply lab.tfplan
```

### 4. เชื่อมต่อ

```bash
terraform output -raw ssh_config >> ~/.ssh/config
ssh ipa-01                     # ผ่าน admin-01 อัตโนมัติด้วย ProxyJump
./scripts/check-lab.sh         # ตรวจ cloud-init, FQDN, SELinux, firewalld, timezone, DNS, internet
```

ผลที่ควรได้จาก `check-lab.sh`: ทุกเครื่อง `CLOUDINIT=done`, `SELINUX=Enforcing`, `FIREWALL=active`, `TZ=Asia/Bangkok` และ node-01 resolve ชื่อ `*.lab.internal` ได้ครบ

เปิด Web UI ผ่าน SSH tunnel (คำสั่งเต็มอยู่ใน `terraform output web_ui_tunnels`)

| UI | URL บนเครื่องตัวเอง |
| --- | --- |
| Graylog | http://localhost:9000 |
| Wazuh dashboard | https://localhost:8443 (หลัง Lab 40 ให้เปลี่ยนปลายทางเป็น 192.168.10.30:8443) |
| WordPress | http://localhost:8081 |

### 5. เปลี่ยน DNS ไปใช้ FreeIPA (หลัง Lab 11)

FreeIPA ที่มี DNS ในตัวต้องเป็น DNS ของทุกเครื่อง จึงแบ่งเป็น 2 รอบ

1. ติดตั้ง IPA บน ipa-01 ตาม Lab 11 โดยตั้ง forwarder เป็น Azure DNS

    ```bash
    sudo ipa-server-install --setup-dns --forwarder=168.63.129.16 \
      --realm LAB.INTERNAL --domain lab.internal --no-ntp
    ```

    `--no-ntp` ให้เครื่องใช้นาฬิกาจาก Hyper-V (PTP) ของ Azure ต่อไป

2. แก้ `use_ipa_dns = true` แล้ว `terraform apply`
3. ให้ทุกเครื่องรับ DNS ใหม่: `sudo systemctl restart NetworkManager` หรือ reboot แล้วตรวจด้วย `resolvectl status` หรือ `cat /etc/resolv.conf`

หลังรอบนี้ ipa-01 ต้อง start ก่อนเครื่องอื่นทุกครั้ง มิฉะนั้นเครื่องอื่นจะ resolve ชื่อไม่ได้

## Lab ที่ต้องปรับเมื่อรันบน Azure

| Lab | ในเอกสาร | บน Azure |
| --- | --- | --- |
| 1 Install Rocky | ติดตั้งจาก ISO | ได้เครื่องจาก image แล้ว ใช้ lab นี้ทบทวน `hostnamectl`, `lsblk`, `rpm -qa` แทน |
| 2 Config Network | ตั้ง static IP ด้วย `nmcli` บน `ens160` | NIC ชื่อ `eth0` และ IP ถูกกำหนดที่ NIC ของ Azure **ห้ามตั้ง static IP ในเครื่อง** จะทำให้เครื่องหลุดจาก network ให้ฝึก `nmcli` ด้วยการอ่านค่า, ตั้ง DNS search หรือสร้าง connection บน dummy interface แทน |
| 6 NTP | ตั้ง chrony ชี้ NTP server | ดู `chronyc sources` ก่อน ถ้ามี refclock `PHC0` (`/dev/ptp_hyperv`) แปลว่าใช้นาฬิกาของ Hyper-V อยู่แล้ว ให้เพิ่ม NTP server ได้แต่อย่าลบ refclock |
| 11 FreeIPA | DNS ของ lab | ใช้ขั้นตอนที่ 5 ด้านบน |
| 14 CrowdSec | โจมตีจาก lab-linux-02 | เหมือนเดิม; เครื่อง lab ไม่มี public IP จึงไม่มี brute force จริงจาก internet |
| 16 Graylog | Cloudflare Tunnel | ใช้ได้เหมือนเดิม (เป็น outbound ผ่าน NAT Gateway) |
| 19 GeoIP | ข้อมูลจาก IP ต่างประเทศ | ใช้วิธีฉีด event ด้วย `logger` ตามเอกสาร |
| 39 Gmail | Postfix relay port 587 | Azure บล็อก outbound port 25 แต่ 587 ใช้ได้ |
| 40 Change port | rich rule ให้ 192.168.10.100 เข้า dashboard | 192.168.10.100 คือ admin-01 ใช้ตามเอกสารได้เลย |
| ทุกหมวด | snapshot `m0X-...-done` | `./scripts/snapshot.sh m05-done` (incremental snapshot ของ OS disk ทุกเครื่อง) |

## ค่าใช้จ่ายและการเปิดปิด

ส่วนที่คิดเงินแม้ VM ปิดอยู่: managed disk (รวม 480 GB), NAT Gateway, public IP 2 ตัว และ snapshot ส่วน VM คิดเงินเฉพาะตอนรัน ประมาณราคาจริงด้วย Azure Pricing Calculator ตาม region ที่เลือก

```bash
RG=rg-soclab
# เปิด: ipa-01 ก่อน แล้วค่อยเครื่องอื่น
az vm start -g $RG -n vm-ipa-01
az vm start --ids $(az vm list -g $RG --query "[?name!='vm-ipa-01'].id" -o tsv)
# ปิดและหยุดคิดเงินค่า compute
az vm deallocate --ids $(az vm list -g $RG --query "[].id" -o tsv)
# ลบทั้ง lab (snapshot ใน RG เดียวกันถูกลบด้วย)
terraform destroy
```

## ความปลอดภัยของ lab

- เข้าจาก internet ได้ทางเดียวคือ SSH ไป admin-01 จาก IP ที่ระบุ ถ้า IP บ้านเปลี่ยนให้แก้ `admin_source_cidrs` แล้ว apply
- ไม่มี password ในไฟล์ใด ๆ state มีเพียง IP และ SSH public key แต่ยังควรเก็บ state ไว้ในที่ปลอดภัย หรือย้ายไป remote backend (`azurerm` backend บน Storage Account)
- หลังทำ Lab 29 (web shell จำลอง) และ Lab 24 (การโจมตี container) ให้ลบไฟล์ทดสอบตาม Cleanup ของแต่ละ lab ก่อนเปิด tunnel ให้ผู้อื่น

## ข้อจำกัดและสิ่งที่ต้องตรวจเอง

- ไฟล์ชุดนี้ยังไม่ได้รัน `terraform validate` หรือ `apply` จริง (sandbox ที่เขียนไม่มีสิทธิ์ดาวน์โหลด provider) ตรวจแล้ว 3 อย่าง: syntax HCL ทุกไฟล์, argument ทั้ง 102 ตัวมีอยู่ในเอกสาร azurerm v4.81.0, และ cloud-init ที่ render แล้วผ่าน schema checker ของ cloud-init
- SKU ของ Rocky 10 บน Marketplace (`10-base` เป็นค่าตั้งต้น) และการต้องมี plan ยังไม่ได้ยืนยัน ให้ใช้ค่าจาก `find-rocky-image.sh`
- ถ้า restore OS disk จาก snapshot ด้วยการสลับ disk ใน portal Terraform จะเห็นว่า `os_disk` เปลี่ยนและเสนอให้สร้าง VM ใหม่ ให้ใช้ snapshot เป็น backup และ restore เฉพาะเมื่อจำเป็น
- B-series เป็น burstable ถ้า Graylog หรือ Wazuh ใช้ CPU ต่อเนื่องจน credit หมด จะช้าลงมาก ให้เปลี่ยนเป็น `Standard_D4as_v5` ผ่าน `vm_sizes`
