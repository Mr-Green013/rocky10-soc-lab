# แผนเรียน 60 วัน (2 ชั่วโมง/วัน)

สัปดาห์ละ 5 วัน รวม 12 สัปดาห์ ฉบับจัดรูปแบบพร้อมภาพประกอบอยู่ในคู่มือผู้เรียน (.docx) ไฟล์นี้สร้างจากข้อมูลชุดเดียวกัน

![แผนเรียน](../assets/diagrams/study-plan/fig01-roadmap.png)

## Rubric

| ด้าน | 4 ดีเยี่ยม | 3 ผ่าน | 2 ต้องปรับ | 1 ยังไม่ผ่าน |
| --- | --- | --- | --- | --- |
| ทำงานได้ (40%) | ทุกข้อผ่าน และรันซ้ำได้ (idempotent) | ทุกข้อในเกณฑ์ผ่าน | ผ่านบางข้อ ต้องมีคนช่วย | ระบบไม่ทำงาน |
| หลักฐานและการตรวจสอบ (25%) | มี output, เวลา และอธิบายว่าพิสูจน์อะไร | มี output ครบตามที่ระบุ | มีบางส่วน หรือไม่ระบุเครื่อง/เวลา | ไม่มีหลักฐาน |
| ความปลอดภัย (20%) | least privilege, ไม่มี secret รั่ว, ย้อนกลับได้ และเพิ่มการป้องกันเอง | ไม่ปิด SELinux/firewall, secret ไม่อยู่ใน config หรือ repo | มีจุดเสี่ยง 1 จุด เช่น สิทธิ์ไฟล์กว้างเกิน | ปิดชั้นป้องกัน หรือ secret รั่ว |
| ความเข้าใจและการสื่อสาร (15%) | อธิบายเหตุผลและทางเลือกอื่นได้ สอนคนอื่นได้ | อธิบายได้ว่าทำอะไรและทำไม | อธิบายได้แค่ขั้นตอน | อธิบายไม่ได้ |

คะแนน = Σ(ระดับ ÷ 4 × น้ำหนัก) ผ่านเมื่อ ≥ 75% และไม่มีด้านใดได้ระดับ 1 ด้านความปลอดภัยได้ระดับ 1 = ไม่ผ่านทันที

## ภาค 0 เตรียมห้องแลป

### วันที่ 1 · บทที่ 1 — เปิด Hyper-V และสร้าง pve-01

**เป้าหมาย:** เครื่อง Windows พร้อมรัน nested virtualization และมี VM pve-01 ที่บูตตัวติดตั้ง Proxmox

**ทฤษฎี**
- Hypervisor type 1 กับ type 2 และเหตุที่ lab ซ้อน 2 ชั้น (Hyper-V → Proxmox → Rocky)
- Nested virtualization ต้องเปิด ExposeVirtualizationExtensions ให้ VM ชั้นแรก
- Rocky Linux 10 ต้องการ CPU ระดับ x86-64-v3 VM จึงต้องใช้ CPU type host

**ขั้นตอนปฏิบัติ**
1. ตรวจ CPU, RAM และพื้นที่ disk ตามตาราง Hardware ในบทที่ 1
2. เปิด feature Hyper-V แล้ว restart
3. ดาวน์โหลด Proxmox VE ISO และไฟล์ Lab
4. สร้าง pve-01 ด้วย New-ProxmoxLabHost.ps1

**คำสั่งหลัก** (Windows · PowerShell)
```bash
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All
.\windows\New-ProxmoxLabHost.ps1 -IsoPath D:\ISO\proxmox-ve_9.2-1.iso -VMPath D:\Hyper-V
Get-VMProcessor pve-01 | Format-List ExposeVirtualizationExtensions
```

**แบบฝึกหัด**
- อธิบายด้วยคำของตัวเองว่าทำไม Hyper-V checkpoint ของ pve-01 ไม่เหมาะกับการ rollback รายเครื่อง

**เกณฑ์ผ่าน**
- [ ] ExposeVirtualizationExtensions = True
- [ ] pve-01 บูตเข้าหน้าติดตั้ง Proxmox

**หลักฐาน:** ภาพหน้าจอผล Get-VMProcessor

อ่านเพิ่ม: บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10

### วันที่ 2 · บทที่ 1 — ติดตั้ง Proxmox VE และ network ของ lab

**เป้าหมาย:** Proxmox ใช้งานได้ มี vmbr1 (192.168.10.1/24) พร้อม NAT ออก internet

**ทฤษฎี**
- Linux bridge คือ switch เสมือน vmbr0 ต่อ uplink, vmbr1 คือ network ของ lab
- NAT (masquerade) ทำให้ VM ออก internet ผ่าน IP ของ pve-01
- repository แบบ no-subscription สำหรับ lab

**ขั้นตอนปฏิบัติ**
1. ติดตั้ง Proxmox VE จาก ISO แล้วถอด ISO
2. คัดลอก repo ไปที่ pve-01 และตั้ง repository
3. สร้าง vmbr1 และ NAT ด้วย script
4. สร้าง SSH key ed25519 บน Windows

**คำสั่งหลัก** (pve-01 · root)
```bash
bash pve-repos.sh
bash pve-setup-network.sh
ip -br addr show vmbr1
nft list ruleset | grep -i masquerade
```

**แบบฝึกหัด**
- วาดผัง network ของ lab ด้วยมือ ระบุ bridge, IP และทิศทางของ NAT

**เกณฑ์ผ่าน**
- [ ] เปิด Web UI https://pve-01:8006 ได้
- [ ] vmbr1 มี IP 192.168.10.1/24

**หลักฐาน:** ผลของ ip -br addr และภาพผังที่วาด

อ่านเพิ่ม: บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10

### วันที่ 3 · บทที่ 1 — Rocky Linux 10 golden image และ template

**เป้าหมาย:** มี template rocky10-tpl (VM 9000) ที่สะอาดพร้อม clone

**ทฤษฎี**
- Golden image คือเครื่องต้นแบบที่ลบข้อมูลเฉพาะเครื่องออกแล้ว
- ข้อมูลที่ต้องลบ: machine-id, SSH host key, NetworkManager profile
- cloud-init ตั้งค่าเครื่องใหม่ตอนบูตครั้งแรกจาก drive ของ Proxmox

**ขั้นตอนปฏิบัติ**
1. ดาวน์โหลด Rocky 10 Minimal ISO บน pve-01
2. สร้าง VM 9000 และติดตั้ง Rocky ด้วย IP ชั่วคราว .99
3. ตรวจเวอร์ชัน, LVM และ SELinux (Lab 1)
4. รัน golden-prep.sh แล้วแปลงเป็น template

**คำสั่งหลัก** (pve-01 · root)
```bash
bash pve-get-iso.sh https://download.rockylinux.org/pub/rocky/10/isos/x86_64/<minimal.iso>
bash pve-create-golden.sh
bash pve-make-template.sh
qm config 9000 | grep -E "^(template|cpu|ide2)"
```

**แบบฝึกหัด**
- ก่อนรัน golden-prep.sh ให้จด machine-id ไว้ หลัง clone ในวันที่ 4 ตรวจว่าทุกเครื่องได้ค่าใหม่

**เกณฑ์ผ่าน**
- [ ] VM 9000 เป็น template
- [ ] cpu: host
- [ ] getenforce = Enforcing (ก่อนแปลง)

**หลักฐาน:** ผลของ qm config 9000

อ่านเพิ่ม: บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10

### วันที่ 4 · บทที่ 1 — Clone 6 เครื่อง, snapshot และการใช้งานประจำวัน

**เป้าหมาย:** ห้องแลป 7 เครื่องผ่าน Test-SocLab.ps1 และมี snapshot ch01-base

**ทฤษฎี**
- Full clone ต่างจาก linked clone อย่างไร
- Snapshot ต่างจาก backup: snapshot อยู่บน storage เดียวกับ VM
- ลำดับการเปิดเครื่องตาม startup order (ipa-01 ขึ้นก่อน)

**ขั้นตอนปฏิบัติ**
1. Clone ทุกเครื่องจาก lab-hosts.csv
2. รัน Initialize-SocLab.ps1 จาก Windows
3. ตรวจด้วย Test-SocLab.ps1
4. สร้าง snapshot ch01-base
5. ลองเปิดปิดเครื่องด้วย pve-lab-power.sh

**คำสั่งหลัก** (pve-01 · root)
```bash
bash pve-clone-lab.sh
bash pve-snapshot.sh ch01-base
bash pve-snapshot.sh --list
bash pve-lab-power.sh status
```

**แบบฝึกหัด**
- ทำแบบฝึกหัด "ทดสอบ rollback" ท้ายบทที่ 1 กับ lab-linux-02

**เกณฑ์ผ่าน**
- [ ] Test-SocLab.ps1 ไม่มี FAIL (exit code 0)
- [ ] machine-id ไม่ซ้ำกันทุกเครื่อง
- [ ] มี snapshot ch01-base ครบ 6 เครื่อง

**หลักฐาน:** ภาพผลของ Test-SocLab.ps1

อ่านเพิ่ม: บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10

## ภาค 1 พื้นฐานระบบและเครือข่าย

### วันที่ 5 · บทที่ 2 — NetworkManager, DNS search และ hostname แบบ FQDN

**เป้าหมาย:** ทุกเครื่องมี FQDN ที่ resolve เป็น IP จริง ไม่ใช่ 127.0.0.1

**ทฤษฎี**
- NetworkManager แยก device (การ์ด) กับ connection (profile ค่า)
- ลำดับการแปลงชื่อ: /etc/hosts → DNS ตาม /etc/nsswitch.conf
- FreeIPA ต้องการ FQDN ที่ชี้ IP จริง cloud-init ใส่ FQDN ไว้กับ 127.0.0.1 จึงต้องแก้

**ขั้นตอนปฏิบัติ**
1. สำรวจ device และ connection ของ lab-linux-01
2. เปลี่ยนชื่อ profile เป็น lab และตั้ง DNS search
3. ฝึกเพิ่มและลบ IP ที่สองชั่วคราว
4. ตั้ง FQDN ทุกเครื่องด้วย set-identity.sh

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
nmcli -f NAME,DEVICE,TYPE connection show
nmcli connection show lab | grep -E "ipv4\.(addresses|dns|dns-search)"
hostnamectl
getent hosts $(hostname -f)
```

**แบบฝึกหัด**
- ใช้ nmtui ดูค่า profile lab บน lab-linux-02 (ห้ามบันทึก) แล้วเทียบกับผลของ nmcli

**เกณฑ์ผ่าน**
- [ ] hostname -f คืนค่า <ชื่อ>.lab.internal
- [ ] getent hosts คืน IP 192.168.10.x ไม่ใช่ 127.0.0.1

**หลักฐาน:** ผลของ ch02-check.sh ทุกเครื่อง

อ่านเพิ่ม: บทที่ 2 Network, SSH และ Hostname

### วันที่ 6 · บทที่ 2 — SSH server, ลำดับ config และ host key

**เป้าหมาย:** อ่านค่าจริงของ sshd ได้ และ Windows รู้จักชื่อเครื่องใน lab

**ทฤษฎี**
- sshd อ่านไฟล์ใน sshd_config.d ตามลำดับชื่อ และค่าที่เจอก่อนเป็นค่าที่ใช้
- sshd -T แสดงค่าหลังรวมทุกไฟล์แล้ว
- host key fingerprint ใช้ยืนยันว่าต่อถูกเครื่อง (ป้องกัน MITM)

**ขั้นตอนปฏิบัติ**
1. ดูไฟล์ใน /etc/ssh/sshd_config.d และ drop-in ของ cloud-init
2. ตรวจค่าด้วย sshd -T
3. ยืนยัน host key ของทุกเครื่อง
4. ตั้ง hosts และ ssh config บน Windows
5. snapshot ch02-network

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
ls -1 /etc/ssh/sshd_config.d/
sudo sshd -T | grep -E "^(permitrootlogin|passwordauthentication|pubkeyauthentication)"
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

**แบบฝึกหัด**
- หาบรรทัด login ล่าสุดของ aod ใน /var/log/secure แล้วระบุ key ที่ใช้จาก fingerprint

**เกณฑ์ผ่าน**
- [ ] ssh lab-linux-01 จาก Windows เข้าได้โดยไม่ถามรหัสผ่าน
- [ ] อธิบายได้ว่าค่า permitrootlogin มาจากไฟล์ใด

**หลักฐาน:** ผลของ sshd -T และ ch02-check.sh

อ่านเพิ่ม: บทที่ 2 Network, SSH และ Hostname

### วันที่ 7 · บทที่ 3 — Kernel, เวอร์ชันระบบ, timezone และ NTP

**เป้าหมาย:** ทุกเครื่อง sync เวลาจาก pve-01 และระบุเวอร์ชัน OS/kernel ได้

**ทฤษฎี**
- อ่านเลข kernel 6.12.0-xxx.el10 และ dist tag
- BTF ใน kernel คือสิ่งที่ eBPF tools (Tetragon, Falco) ต้องใช้ในภาค 6
- เวลาที่คลาดกันทำให้เรียง timeline ของ log จากหลายเครื่องผิด

**ขั้นตอนปฏิบัติ**
1. อ่านเวอร์ชัน kernel และ OS (Lab 4, 7)
2. ตรวจ /sys/kernel/btf/vmlinux
3. ตั้ง pve-01 เป็น NTP server
4. ตั้ง timezone และ chrony ทุกเครื่องด้วย set-time.sh
5. snapshot ch03-time

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
uname -r; rpm -q kernel
. /etc/os-release; echo "$ID $VERSION_ID"
ls -l /sys/kernel/btf/vmlinux
timedatectl
chronyc sources -v; chronyc tracking
```

**แบบฝึกหัด**
- เขียน script 1 บรรทัดที่พิมพ์ ID, VERSION_ID และ kernel แล้วรันกับทุกเครื่องด้วย Invoke-SocLabScript.ps1

**เกณฑ์ผ่าน**
- [ ] chronyc sources มี ^* ที่ 192.168.10.1
- [ ] Time zone = Asia/Bangkok
- [ ] System clock synchronized: yes

**หลักฐาน:** ผลของ ch03-check.sh ทุกเครื่อง

อ่านเพิ่ม: บทที่ 3 Kernel, เวอร์ชันระบบ, Timezone และ NTP

### วันที่ 8 · บทที่ 4 — SELinux: label, AVC และการแก้โดยไม่ปิด SELinux

**เป้าหมาย:** วินิจฉัย AVC denial แล้วแก้ด้วย semanage

**ทฤษฎี**
- DAC (rwx) กับ MAC (SELinux) ต้องผ่านทั้งสองชั้น
- Label รูปแบบ user:role:type:level และ type enforcement
- ลำดับแก้: อ่าน AVC → audit2why → boolean / semanage → restorecon (ไม่ใช่ setenforce 0)

**ขั้นตอนปฏิบัติ**
1. สำรวจโหมดและ label ของไฟล์และ process
2. Mini-lab: ย้าย sshd ไป port 2222 แล้วดู SELinux บล็อก
3. แก้ด้วย semanage port
4. คืนค่าเดิม (cleanup)

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sestatus; ls -Z /etc/ssh/sshd_config; ps -eZ | grep sshd
sudo ausearch -m AVC -ts recent | audit2why
sudo semanage port -a -t ssh_port_t -p tcp 2222
sudo semanage port -l | grep ssh_port_t
```

**แบบฝึกหัด**
- สร้าง /srv/labweb ตั้ง label httpd_sys_content_t ด้วย semanage fcontext และ restorecon

**เกณฑ์ผ่าน**
- [ ] อ่าน AVC แล้วระบุ scontext, tcontext และ permission ที่ถูกปฏิเสธได้
- [ ] getenforce ยังเป็น Enforcing ตลอด lab

**หลักฐาน:** บรรทัด AVC ที่อ่าน พร้อมคำอธิบาย 3 บรรทัด

อ่านเพิ่ม: บทที่ 4 SELinux และ systemd

### วันที่ 9 · บทที่ 4 — systemd: unit, drop-in, journal และ service ของตัวเอง

**เป้าหมาย:** สร้าง service ที่ restart อัตโนมัติ และปรับ service ด้วย drop-in

**ทฤษฎี**
- unit, target และ dependency (Wants, After)
- drop-in ใน /etc/systemd/system/<unit>.d ไม่ต้องแก้ไฟล์ของ package
- journalctl กรองตาม unit, priority และช่วงเวลา

**ขั้นตอนปฏิบัติ**
1. ใช้ systemctl status, list-units --failed
2. สร้าง heartbeat.service พร้อม Restart=on-failure
3. kill process แล้วดูว่า systemd เปิดคืน
4. ตรวจทุกเครื่องด้วย ch04-check.sh

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
systemctl list-units --type=service --state=failed
sudo systemctl edit chronyd
systemctl cat chronyd
journalctl -u heartbeat -p warning --since "10 min ago"
```

**แบบฝึกหัด**
- แปลง heartbeat ให้รันทุก 5 นาทีด้วย .timer แทน loop ใน script

**เกณฑ์ผ่าน**
- [ ] heartbeat กลับมาเองภายใน 5 วินาทีหลัง kill
- [ ] systemctl revert คืนค่า chronyd ได้

**หลักฐาน:** ผลของ ch04-check.sh และ unit file ที่เขียน

อ่านเพิ่ม: บทที่ 4 SELinux และ systemd

### ◆ วันที่ 10 — Checkpoint 1: ภาค 0–1

**เป้าหมาย:** พิสูจน์ว่า lab พื้นฐานถูกต้องก่อนเริ่มงาน identity

**ทฤษฎี**
- ทบทวนคำถามท้ายบทที่ 1–4

**ขั้นตอนปฏิบัติ**
1. รัน check script ของบทที่ 1–4 ทุกเครื่องแล้วเก็บผล
2. Rollback lab-linux-02 ไป ch03-time แล้วตรวจซ้ำ
3. ทำ Practical: แก้ปัญหาที่เพื่อนหรือ script สุ่มทำให้เสีย 3 ข้อ (ดูตาราง "วิธีแก้ปัญหา" บทที่ 1–4)

**คำสั่งหลัก** (Windows · PowerShell)
```bash
.\Test-SocLab.ps1
.\tools\windows\Invoke-SocLabScript.ps1 -Script ..\..\ch03-kernel-time-ntp\guest\ch03-check.sh
.\tools\windows\Invoke-SocLabScript.ps1 -Script ..\..\ch04-selinux-systemd\guest\ch04-check.sh
```

**แบบฝึกหัด**
- สอบย่อย 10 ข้อจากคำถามทบทวนบทที่ 1–4

**เกณฑ์ผ่าน**
- [ ] check script ผ่านทุกเครื่อง
- [ ] สอบย่อยได้อย่างน้อย 7/10
- [ ] Rubric รวมได้ระดับ 3 ขึ้นไปทุกด้าน

**หลักฐาน:** ไฟล์ผลของ check script ทั้งหมด + บันทึกการแก้ปัญหา



## ภาค 2 คำสั่งและตัวตน

### วันที่ 11 · บทที่ 5 — Filesystem, navigation, nano และ output (Lab 9.1–9.5)

**เป้าหมาย:** เดินทางใน filesystem และแก้ไฟล์ config อย่างปลอดภัย

**ทฤษฎี**
- FHS: /etc = config, /var/log = log, /usr = โปรแกรม, /home, /tmp
- path แบบ absolute กับ relative
- สำรองไฟล์ก่อนแก้ทุกครั้ง (cp -a ไฟล์ ไฟล์.bak)

**ขั้นตอนปฏิบัติ**
1. สำรวจ / ด้วย ls, tree, du
2. สร้าง directory หลายชั้นด้วย mkdir -p
3. แก้ไฟล์ด้วย nano (บันทึก Ctrl+O, ออก Ctrl+X)
4. จัด output ด้วย head, tail, less, wc

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
ls -la /etc | head; du -sh /var/log/*
mkdir -p ~/lab/day11/{logs,notes}
sudo cp -a /etc/chrony.conf /etc/chrony.conf.bak
tail -n 20 /var/log/messages | less
```

**แบบฝึกหัด**
- หาไฟล์ใน /etc ที่แก้ไขภายใน 7 วัน (find /etc -mtime -7) แล้วอธิบายว่าแต่ละไฟล์ถูกแก้จากบทไหน

**เกณฑ์ผ่าน**
- [ ] อธิบายหน้าที่ของ 6 directory หลักได้
- [ ] แก้ไฟล์แล้วมี .bak ทุกครั้ง

**หลักฐาน:** ผล find พร้อมคำอธิบาย

อ่านเพิ่ม: บทที่ 5 Command Line ที่ SOC ต้องใช้ทุกวัน

### วันที่ 12 · บทที่ 5 — sudo, sudoers และ journalctl แบบกรอง (Lab 9.6–9.10)

**เป้าหมาย:** ให้สิทธิ์ sudo แบบจำกัดคำสั่ง และค้น log ด้วย journalctl

**ทฤษฎี**
- sudo บันทึกทุกคำสั่งลง log (ใช้สืบสวนในบทที่ 20)
- แก้ sudoers ด้วย visudo เสมอ เพื่อตรวจ syntax ก่อนบันทึก
- journalctl: -u, -p, --since, -o json

**ขั้นตอนปฏิบัติ**
1. สร้างไฟล์ใน /etc/sudoers.d ด้วย visudo -f
2. ทดสอบสิทธิ์ด้วย sudo -l -U
3. ค้น log ของ sshd และ sudo ด้วย journalctl

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo visudo -cf /etc/sudoers.d/20-containerops
sudo -l -U anan
journalctl _COMM=sudo --since today
journalctl -u sshd -p warning -o short-iso
```

**แบบฝึกหัด**
- ให้ helpdesk รัน systemctl restart chronyd ได้คำสั่งเดียว แล้วพิสูจน์ว่า restart sshd ไม่ได้

**เกณฑ์ผ่าน**
- [ ] visudo -c ผ่าน
- [ ] helpdesk ทำได้เฉพาะคำสั่งที่อนุญาต และมี log ทุกครั้ง

**หลักฐาน:** ไฟล์ sudoers.d และบรรทัด log ที่พิสูจน์

อ่านเพิ่ม: บทที่ 5 Command Line ที่ SOC ต้องใช้ทุกวัน

### วันที่ 13 · บทที่ 5 — grep/awk, rsync หลักฐาน, shutdown และ I/O redirect (Lab 9.11–9.15)

**เป้าหมาย:** สรุป log ด้วย pipeline และเก็บหลักฐานโดยรักษา metadata

**ทฤษฎี**
- stdin/stdout/stderr และ >, >>, 2>&1, |
- rsync -a รักษาเวลา, สิทธิ์ และเจ้าของ (สำคัญกับหลักฐาน)
- hash (sha256sum) ยืนยันว่าหลักฐานไม่เปลี่ยน

**ขั้นตอนปฏิบัติ**
1. นับ login ที่ล้มเหลวด้วย grep และ awk
2. เก็บ /var/log เป็นสำเนาหลักฐานใน /srv/evidence ด้วย rsync
3. ทำ hash ของสำเนา แล้วตรวจซ้ำภายหลัง (ไฟล์ต้นทางที่ยังถูกเขียนอยู่จะ hash ไม่ตรง จึงต้อง hash ที่สำเนา)
4. ตั้ง shutdown ล่วงหน้าแล้วยกเลิก

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo grep "Failed password" /var/log/secure | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn
E=/srv/evidence/l01-$(date +%F); sudo mkdir -p $E && sudo rsync -aHAX --info=stats1 /var/log/ $E/
cd $E && sudo find . -type f -exec sha256sum {} + | sudo tee /srv/evidence/l01.sha256 > /dev/null
cd $E && sudo sha256sum --quiet -c /srv/evidence/l01.sha256 && echo INTACT
sudo shutdown -r +30 && sudo shutdown -c
```

**แบบฝึกหัด**
- เขียน one-liner ที่แสดง 5 user ที่ใช้ sudo บ่อยที่สุดวันนี้

**เกณฑ์ผ่าน**
- [ ] sha256sum -c ของสำเนาขึ้น INTACT
- [ ] อธิบายได้ว่าทำไมไม่ใช้ cp ธรรมดา

**หลักฐาน:** ผล sha256sum -c และ one-liner

อ่านเพิ่ม: บทที่ 5 Command Line ที่ SOC ต้องใช้ทุกวัน

### วันที่ 14 · บทที่ 6 — passwd, shadow และสร้างผู้ใช้หลายคน (Lab 10.1–10.4)

**เป้าหมาย:** อ่าน /etc/passwd, /etc/shadow ได้ และสร้างผู้ใช้จาก CSV ด้วย script

**ทฤษฎี**
- 7 ช่องของ /etc/passwd และ 9 ช่องของ /etc/shadow
- Rocky 10 ใช้ hash แบบ yescrypt ($y$) และ root ถูกล็อกเป็นค่าเริ่มต้น
- UID < 1000 คือบัญชีระบบ

**ขั้นตอนปฏิบัติ**
1. อ่านโครงสร้างไฟล์ด้วย getent
2. เขียน script อ่าน users.csv แล้ว useradd
3. ตั้งรหัสผ่านเริ่มต้นและบังคับเปลี่ยนตอน login แรก

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
getent passwd aod; grep ^ENCRYPT_METHOD /etc/login.defs
sudo useradd -m -c "Analyst 01" -s /bin/bash somchai
sudo passwd somchai && sudo chage -d 0 somchai
sudo getent shadow somchai | cut -d: -f2 | cut -c1-4   # แสดงเฉพาะต้น hash
sudo awk -F: '$3>=1000 && $3<60000 {print $1}' /etc/passwd
```

**แบบฝึกหัด**
- ปรับ script ให้ข้ามผู้ใช้ที่มีอยู่แล้ว และรันซ้ำได้โดยไม่ error
- เทียบต้น hash ของ aod (ตั้งผ่าน cloud-init ของ Proxmox) กับ somchai แล้วอธิบายว่าทำไมอาจต่างกัน

**เกณฑ์ผ่าน**
- [ ] hash ของ somchai ขึ้นต้นด้วย $y$ (yescrypt)
- [ ] script รันซ้ำแล้วไม่สร้างซ้ำ

**หลักฐาน:** script และผลการรัน 2 ครั้ง

อ่านเพิ่ม: บทที่ 6 ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน

### วันที่ 15 · บทที่ 6 — นโยบายรหัสผ่าน: aging, history, ความซับซ้อน, faillock

**เป้าหมาย:** บังคับนโยบายรหัสผ่านด้วย PAM ผ่าน authselect

**ทฤษฎี**
- chage กำหนดอายุรหัสผ่าน (-M, -m, -W)
- pwquality.conf กำหนดความยาวและความซับซ้อน
- authselect feature with-pwhistory และ with-faillock แทนการแก้ไฟล์ PAM เอง

**ขั้นตอนปฏิบัติ**
1. ตั้งอายุรหัสผ่านให้ผู้ใช้ทดสอบ
2. ตั้ง minlen = 12 ใน pwquality.conf
3. เปิด password history และ faillock แล้วตั้ง deny = 5 ใน /etc/security/faillock.conf
4. ทดสอบใส่รหัสผิด 5 ครั้งแล้วดูการล็อก

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo chage -M 90 -m 1 -W 7 somchai && sudo chage -l somchai
sudo authselect enable-feature with-pwhistory
sudo authselect enable-feature with-faillock
sudo faillock --user somchai
```

**แบบฝึกหัด**
- พิสูจน์ว่าตั้งรหัสผ่านเดิมซ้ำไม่ได้ (remember = 5 ใน /etc/security/pwhistory.conf)

**เกณฑ์ผ่าน**
- [ ] authselect current แสดง feature ทั้งสอง
- [ ] faillock แสดงการล็อกหลังใส่ผิดครบ
- [ ] faillock --reset ปลดได้

**หลักฐาน:** ผล authselect current และ faillock

อ่านเพิ่ม: บทที่ 6 ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน

### วันที่ 16 · บทที่ 6 — สิทธิ์ super user, ล็อก/ปิดบัญชี และกลุ่ม (Lab 10.9–10.13)

**เป้าหมาย:** ทำ offboarding อย่างถูกวิธี และตรวจจุดยกระดับสิทธิ์ผ่านกลุ่ม

**ทฤษฎี**
- กลุ่ม wheel = sudo เต็ม, NOPASSWD ที่ cloud-init ให้ไว้เป็นความเสี่ยง
- ล็อกรหัสผ่านอย่างเดียวไม่พอถ้ามี SSH key ต้องปิด shell หรือหมดอายุบัญชีด้วย
- ไม่ลบบัญชีทันที เพื่อคงเจ้าของไฟล์และหลักฐาน

**ขั้นตอนปฏิบัติ**
1. ตรวจไฟล์ sudoers ที่มี NOPASSWD
2. ล็อกบัญชีด้วย 3 วิธีแล้วเทียบผล (10.10)
3. สร้างกลุ่ม soc-analyst (GID 5000) แล้วเพิ่มสมาชิก
4. ทดสอบ login ของบัญชีที่ปิดต้องถูกปฏิเสธ

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo grep -r NOPASSWD /etc/sudoers /etc/sudoers.d/
sudo useradd -m exstaff && sudo usermod -L -e 1 -s /sbin/nologin exstaff   # บัญชีทดสอบ ลบด้วย userdel -r หลังจบ
sudo passwd -S exstaff; sudo chage -l exstaff
sudo groupadd -g 5000 soc-analyst && sudo usermod -aG soc-analyst somchai && id somchai
```

**แบบฝึกหัด**
- เขียน checklist offboarding 6 ข้อ (รวมถอด authorized_keys และ cron ของผู้ใช้) แล้วทำกับ exstaff

**เกณฑ์ผ่าน**
- [ ] ssh ด้วย exstaff ถูกปฏิเสธทั้ง password และ key
- [ ] id somchai แสดงกลุ่ม soc

**หลักฐาน:** checklist + ผลการทดสอบ login; snapshot ch06-users

อ่านเพิ่ม: บทที่ 6 ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน

### วันที่ 17 · บทที่ 7 — ติดตั้ง FreeIPA server (Lab 11)

**เป้าหมาย:** ipa-01 เป็น IdM, DNS และ CA ของ lab.internal

**ทฤษฎี**
- FreeIPA = LDAP (389-ds) + Kerberos + DNS (BIND) + CA (Dogtag) + SSSD
- Realm LAB.INTERNAL, domain lab.internal
- บน EL10 ไม่มี module stream idm ติดตั้ง package ตรงได้

**ขั้นตอนปฏิบัติ**
1. ตรวจ FQDN และเวลาของ ipa-01 (จากบทที่ 2–3)
2. ติดตั้ง package และรัน ipa-server-install (--no-ntp เพื่อคง pve-01 เป็น NTP ตามบทที่ 3)
3. เปิด firewall service ที่จำเป็น
4. ทดสอบ kinit admin

**คำสั่งหลัก** (ipa-01 · aod)
```bash
sudo dnf install -y ipa-server ipa-server-dns
sudo ipa-server-install --setup-dns --auto-forwarders --auto-reverse --no-ntp --realm LAB.INTERNAL --domain lab.internal
sudo firewall-cmd --permanent --add-service={freeipa-4,dns} && sudo firewall-cmd --reload
kinit admin && ipa user-find --sizelimit=5
```

**แบบฝึกหัด**
- ใช้ dig ถาม SRV record _ldap._tcp.lab.internal จาก ipa-01 แล้วอธิบายว่า client ใช้ record นี้ทำอะไร

**เกณฑ์ผ่าน**
- [ ] ipactl status ทุก service RUNNING
- [ ] kinit admin สำเร็จ

**หลักฐาน:** ผล ipactl status และ dig SRV

อ่านเพิ่ม: บทที่ 7 Centralized Identity ด้วย FreeIPA

### วันที่ 18 · บทที่ 7 — Join domain และ password policy

**เป้าหมาย:** ทุกเครื่องเป็น client ของ FreeIPA และใช้ ipa-01 เป็น DNS

**ทฤษฎี**
- ipa-client-install ตั้ง SSSD, Kerberos และ DNS ให้
- mkhomedir สร้าง home ตอน login แรก
- password policy ของ IPA ใช้แทนค่าในเครื่อง

**ขั้นตอนปฏิบัติ**
1. ชี้ DNS ของทุกเครื่องไป 192.168.10.10
2. รัน ipa-client-install ทุกเครื่อง
3. สร้างผู้ใช้ IPA และตั้ง password policy
4. login ด้วยผู้ใช้ IPA

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo nmcli connection modify lab ipv4.dns 192.168.10.10 && sudo nmcli connection up lab
sudo ipa-client-install --mkhomedir --no-ntp --domain lab.internal --server ipa-01.lab.internal
kinit admin && ipa pwpolicy-mod --minlength=12 --history=5 --maxfail=5 --lockouttime=600
id somsak@lab.internal
```

**แบบฝึกหัด**
- อธิบายความต่างระหว่าง faillock (บทที่ 6) กับ --maxfail ของ IPA และบอกว่าตัวไหนมีผลกับผู้ใช้ IPA

**เกณฑ์ผ่าน**
- [ ] getent passwd <ผู้ใช้ IPA> ได้ผลบนทุกเครื่อง
- [ ] login ssh ด้วยผู้ใช้ IPA สำเร็จ

**หลักฐาน:** ผล ipa host-find และ getent

อ่านเพิ่ม: บทที่ 7 Centralized Identity ด้วย FreeIPA

### วันที่ 19 · บทที่ 7 — HBAC, sudo rule, SSH key รวมศูนย์ และ LDAP

**เป้าหมาย:** ควบคุมว่าใคร login เครื่องไหนได้ และใช้ sudo อะไรได้ จากที่เดียว

**ทฤษฎี**
- HBAC rule = ใคร + เครื่องไหน + service ไหน
- ต้องสร้าง rule ที่จำเป็นก่อนปิด allow_all มิฉะนั้นจะ lock ตัวเองออก
- sudo rule และ SSH public key เก็บใน LDAP

**ขั้นตอนปฏิบัติ**
1. สร้าง host group และ HBAC rule สำหรับทีม SOC
2. ทดสอบด้วย ipa hbactest แล้วจึงปิด allow_all
3. สร้าง sudo rule web_nginx_ops ให้กลุ่ม sysadmins
4. เพิ่ม SSH key ให้ผู้ใช้ และค้นด้วย ldapsearch
5. snapshot ch07-ipa

**คำสั่งหลัก** (ipa-01 · aod)
```bash
ipa hbacrule-add allow_sysadmins_web && ipa hbacrule-add-user allow_sysadmins_web --groups=sysadmins
ipa hbactest --user=somsak --host=lab-linux-01.lab.internal --service=sshd --rules=allow_sysadmins_web
ipa hbacrule-disable allow_all
ipa sudorule-add web_nginx_ops && ipa sudorule-add-user web_nginx_ops --groups=sysadmins && ipa sudorule-add-allow-command web_nginx_ops --sudocmdgroups=nginx-ops
ldapsearch -Y GSSAPI -b "cn=users,cn=accounts,dc=lab,dc=internal" uid=somsak ipaSshPubKey
```

**แบบฝึกหัด**
- ออกแบบ HBAC 3 rule สำหรับ admin, soc และ dev แล้วพิสูจน์ด้วย hbactest 6 กรณี

**เกณฑ์ผ่าน**
- [ ] hbactest คืนค่าตรงกับที่ออกแบบทุกกรณี
- [ ] aod ยัง login ทุกเครื่องได้หลังปิด allow_all

**หลักฐาน:** ตาราง hbactest 6 กรณี

อ่านเพิ่ม: บทที่ 7 Centralized Identity ด้วย FreeIPA

### วันที่ 20 · บทที่ 8 — SSH key authentication และปิด password (Lab 12)

**เป้าหมาย:** SSH ใช้ key อย่างเดียว ปิดทั้ง password และ keyboard-interactive โดยไม่ lock ตัวเองออก

**ทฤษฎี**
- กลไก public key: server ท้าให้ client พิสูจน์ด้วย private key
- ed25519 สั้น เร็ว และปลอดภัยกว่า RSA ขนาดเดิม
- 04-ipa.conf เปิด keyboard-interactive ไฟล์ของเราจึงต้องชื่อ 01- เพื่อให้ถูกอ่านก่อน

**ขั้นตอนปฏิบัติ**
1. สร้าง key ใหม่ id_ed25519_lab บน Windows และวางบน lab-linux-01
2. ทดสอบด้วย IdentitiesOnly และเทียบ fingerprint ใน /var/log/secure
3. เพิ่ม Host lab01 ใน ~/.ssh/config
4. เขียน 01-soclab-auth.conf แล้ว sshd -t และ reload

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo sshd -T | grep -E "^(passwordauthentication|kbdinteractiveauthentication)"
sudo grep -H -i -E "challengeresponse|kbdinteractive" /etc/ssh/sshd_config.d/*.conf
printf "PubkeyAuthentication yes\nPasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n" | sudo tee /etc/ssh/sshd_config.d/01-soclab-auth.conf
sudo sshd -t && sudo systemctl reload sshd
sudo grep "Accepted publickey for aod" /var/log/secure | tail -2
```

**แบบฝึกหัด**
- จาก Windows รัน ssh -o PubkeyAuthentication=no -o GSSAPIAuthentication=no lab-linux-01 รายการวิธีใน Permission denied ต้องไม่มี password หรือ keyboard-interactive

**เกณฑ์ผ่าน**
- [ ] sshd -T แสดง passwordauthentication no และ kbdinteractiveauthentication no
- [ ] ssh lab01 เข้าได้ด้วย key ใหม่

**หลักฐาน:** ผล sshd -T และข้อความ Permission denied

อ่านเพิ่ม: บทที่ 8 SSH Hardening: Key Authentication และ Session Limit

### วันที่ 21 · บทที่ 8 — จำกัด session และ connection (Lab 13)

**เป้าหมาย:** จำกัดการลองยืนยันตัวตน, connection ที่รอ, login พร้อมกัน, กลุ่มที่ใช้ SSH และ session ที่ว่าง

**ทฤษฎี**
- MaxSessions = channel ต่อ connection, MaxStartups = connection ที่รอยืนยันตัวตน
- ClientAlive ตัดเฉพาะ client ที่หลุด ส่วน idle ต้องใช้ ChannelTimeout session:*= หรือ TMOUT
- pam_limits maxlogins จำกัดจำนวน login ต่อผู้ใช้

**ขั้นตอนปฏิบัติ**
1. ยืนยันว่า aod อยู่ใน wheel ก่อนใส่ AllowGroups
2. เขียน 20-session-limit.conf และ limits.d/90-maxlogins.conf
3. ตั้ง TMOUT ใน /etc/profile.d
4. ทดสอบ MaxAuthTries, LoginGraceTime, AllowGroups และ maxlogins แล้วอ่าน log
5. snapshot ch08-ssh

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
id aod | grep -o wheel
sudo sshd -T | grep -Ei "^(maxauthtries|logingracetime|maxstartups|channeltimeout|allowgroups|persourcepenalties)"
sudo journalctl -u sshd --since "15 min ago" | grep -E "maximum authentication|Timeout before|AllowGroups"
sudo journalctl --since "15 min ago" | grep "Too many logins"
```

**แบบฝึกหัด**
- คำนวณว่า client ที่หลุดเงียบจะถูกตัดภายในกี่นาทีจาก ClientAliveInterval × ClientAliveCountMax แล้วพิสูจน์ด้วยการลดค่าชั่วคราว

**เกณฑ์ผ่าน**
- [ ] ch08-check.sh ผ่านทุกข้อ
- [ ] อธิบายตัวเลข 3 ตัวของ MaxStartups ได้

**หลักฐาน:** บรรทัด log ของแต่ละ limit + ผล ch08-check.sh

อ่านเพิ่ม: บทที่ 8 SSH Hardening: Key Authentication และ Session Limit

## ภาค 3 ป้องกันภัยเบื้องต้น

### วันที่ 22 · บทที่ 9 — CrowdSec: ติดตั้ง, scenario sshd และ bouncer (Lab 14)

**เป้าหมาย:** IP ที่เดารหัสผ่าน SSH ซ้ำถูก ban อัตโนมัติที่ nftables โดยเครื่อง admin ไม่ถูก ban

**ทฤษฎี**
- CrowdSec แยก Security Engine (ตรวจจับ), LAPI (เก็บ decision) และ bouncer (บังคับใช้)
- scenario ssh-bf เป็น leaky bucket: จุ 5 รั่ว 1 ทุก 10 วินาที
- parser crowdsecurity/whitelists ยกเว้น IP ภายในทั้งหมด จึงต้อง whitelist admin แล้วถอดออกใน lab

**ขั้นตอนปฏิบัติ**
1. เปิด password ชั่วคราวด้วย 00-lab-password.conf (ยกเว้น lab-linux-02 จาก PerSourcePenalties)
2. ติดตั้ง crowdsec และ firewall bouncer แบบ nftables (อ่าน script ของ repository ก่อนรัน)
3. whitelist 192.168.10.100 แล้วถอด crowdsecurity/whitelists
4. จาก lab-linux-02 ทดสอบ login ผิดด้วยผู้ใช้ที่ไม่มีจริง
5. ดู alert, decision และ nftables แล้วลบ decision

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
curl -fsSL https://install.crowdsec.net -o crowdsec-repo.sh && less crowdsec-repo.sh
sudo sh crowdsec-repo.sh && sudo dnf install -y crowdsec crowdsec-firewall-bouncer-nftables
sudo cscli metrics show acquisition
sudo cscli alerts list; sudo cscli decisions list
sudo cscli explain --file /var/log/secure --type syslog | tail -30
sudo cscli decisions delete --ip 192.168.10.42
```

**แบบฝึกหัด**
- ทดสอบ bouncer โดยไม่ต้อง login ผิด: cscli decisions add --ip 192.168.10.42 --duration 5m แล้ว ping จาก lab-linux-02

**เกณฑ์ผ่าน**
- [ ] หลัง login ผิดตามเกณฑ์ lab-linux-02 ต่อ port 22 ไม่ได้
- [ ] ลบ decision แล้วกลับมาต่อได้

**หลักฐาน:** ผล cscli alerts list และ decisions list

อ่านเพิ่ม: บทที่ 9 CrowdSec: Ban Brute-force และบล็อก Tor/Proxy

### วันที่ 23 · บทที่ 9 — บล็อก Tor exit node และ anonymous proxy (Lab 15)

**เป้าหมาย:** IP ของ Tor exit node ถูกบล็อกล่วงหน้าและอัปเดตเองทุก 12 ชั่วโมง

**ทฤษฎี**
- reactive (ssh-bf) ต่างจาก proactive (blocklist ตามชื่อเสียงของ IP)
- decision มีอายุ 13 ชม. แต่นำเข้าใหม่ทุก 12 ชม. IP ที่ยังอยู่ใน list จึงถูกต่ออายุ
- list รวม VPN อาจบล็อกผู้ใช้จริง ต้องเริ่มด้วยการเก็บ log

**ขั้นตอนปฏิบัติ**
1. นำเข้า Tor exit list ด้วย cscli decisions import
2. ติดตั้ง script, service และ timer
3. ทดสอบด้วยการนำเข้า IP ของ lab-linux-02 อายุ 5 นาที
4. ลบ 00-lab-password.conf และปลด ban lab-linux-02
5. snapshot ch09-crowdsec

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo systemctl start crowdsec-tor-import.service
systemctl list-timers crowdsec-tor-import.timer
sudo cscli decisions list --origin cscli-import --limit 3
sudo cscli metrics show decisions
sudo rm /etc/ssh/sshd_config.d/00-lab-password.conf && sudo systemctl reload sshd
```

**แบบฝึกหัด**
- เขียน 1 ย่อหน้า: องค์กรประเภทใดไม่ควรบล็อก Tor ทั้งหมด และควรใช้มาตรการอะไรแทน

**เกณฑ์ผ่าน**
- [ ] มี decision จาก origin cscli-import และ timer มีเวลารันครั้งถัดไป
- [ ] ch09-check.sh ผ่านทุกข้อ

**หลักฐาน:** ผล list-timers และ metrics show decisions

อ่านเพิ่ม: บทที่ 9 CrowdSec: Ban Brute-force และบล็อก Tor/Proxy

### ◆ วันที่ 24 — Checkpoint 2: ภาค 2–3

**เป้าหมาย:** พิสูจน์ identity, SSH และการป้องกันเบื้องต้นทำงานร่วมกัน

**ทฤษฎี**
- ทบทวนคำถามท้ายบทที่ 5–9

**ขั้นตอนปฏิบัติ**
1. Scenario: พนักงาน intern ลาออกวันนี้ ให้ offboard ทั้งใน IPA และเครื่อง local
2. จาก lab-linux-02 ทดสอบ login ด้วยบัญชีนั้น ต้องถูกปฏิเสธ และถ้าผิดซ้ำต้องถูก ban
3. เขียนรายงาน 1 หน้า: ทำอะไร หลักฐานคืออะไร ย้อนกลับอย่างไร

**คำสั่งหลัก** (ipa-01 · aod)
```bash
ipa user-disable intern   # บัญชีที่ผู้สอนสร้างไว้สำหรับ scenario
ipa user-show intern --all | grep -i "account disabled"
sudo cscli decisions list
```

**แบบฝึกหัด**
- สอบย่อย 10 ข้อจากคำถามทบทวนบทที่ 5–9

**เกณฑ์ผ่าน**
- [ ] บัญชีถูกปิดครบทุกช่องทาง (password, key, sudo)
- [ ] รายงานมี timeline พร้อมเวลา
- [ ] Rubric ระดับ 3 ขึ้นไปทุกด้าน

**หลักฐาน:** รายงาน 1 หน้า + log ประกอบ



## ภาค 4 SIEM ด้วย Graylog

### วันที่ 25 · บทที่ 10 — Graylog 7.1 ด้วย Docker Compose

**เป้าหมาย:** Graylog, MongoDB และ Data Node รันบน graylog-01

**ทฤษฎี**
- ส่วนประกอบ: Graylog server, MongoDB (config), Data Node / OpenSearch (เก็บ log)
- Secret (password_secret, root password hash) อยู่ใน .env ที่สิทธิ์ 600 และไม่ commit
- Docker CE บน Rocky 10: ถ้า dockerd ไม่ขึ้นเพราะ addrtype ให้ติดตั้ง kernel-modules-extra

**ขั้นตอนปฏิบัติ**
1. ติดตั้ง Docker CE และ compose plugin
2. สร้าง .env ด้วย secret ที่สุ่มขึ้น
3. sudo docker compose up -d แล้วดู health
4. login Web UI ผ่าน port ภายใน

**คำสั่งหลัก** (graylog-01 · aod)
```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && sudo systemctl enable --now docker
umask 077; printf "GRAYLOG_PASSWORD_SECRET=%s\n" "$(openssl rand -hex 48)" > .env
sudo docker compose up -d && sudo docker compose ps
```

**แบบฝึกหัด**
- อธิบายว่าถ้า MongoDB หาย ข้อมูลอะไรหาย และถ้า Data Node หาย ข้อมูลอะไรหาย

**เกณฑ์ผ่าน**
- [ ] docker compose ps ทุก container healthy/running
- [ ] .env สิทธิ์ 600 และอยู่ใน .gitignore

**หลักฐาน:** ผล docker compose ps + ls -l .env

อ่านเพิ่ม: บทที่ 10 ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย

### วันที่ 26 · บทที่ 10 — Nginx reverse proxy, TLS และ Cloudflare Tunnel (16.16)

**เป้าหมาย:** เข้า Graylog ผ่าน HTTPS และจากภายนอกผ่าน tunnel โดยไม่เปิด port

**ทฤษฎี**
- Reverse proxy รับ TLS แทน application และส่งต่อภายใน
- Cloudflare Tunnel เป็น connection ขาออก จึงไม่ต้องเปิด port ขาเข้าที่ router
- tunnel token เป็น secret ต้องเก็บนอก repo

**ขั้นตอนปฏิบัติ**
1. สร้าง certificate (จาก FreeIPA CA หรือ self-signed)
2. เพิ่ม nginx ใน compose และ proxy ไป graylog:9000
3. เพิ่ม cloudflared ใน network เดียวกัน ชี้ ingress ไป http://nginx:80
4. reload nginx โดยไม่ดับ service
5. snapshot ch10-graylog

**คำสั่งหลัก** (graylog-01 · aod)
```bash
sudo docker compose exec nginx nginx -t && sudo docker compose exec nginx nginx -s reload
sudo docker compose logs cloudflared | grep -i "registered tunnel connection"
curl -skI https://graylog-01.lab.internal/ | head -3
sudo ss -tlnp | grep -E ":(80|443|9000)\b"
```

**แบบฝึกหัด**
- ตรวจจากภายนอกว่า port 9000 ของ Graylog ไม่ได้เปิดให้เข้าตรง (เข้าได้ทาง Nginx เท่านั้น)

**เกณฑ์ผ่าน**
- [ ] เปิด public hostname แล้วได้หน้า login ผ่าน HTTPS
- [ ] nginx -t ผ่านก่อน reload ทุกครั้ง

**หลักฐาน:** ภาพหน้า login + ผล ss -tlnp

อ่านเพิ่ม: บทที่ 10 ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย

### วันที่ 27 · บทที่ 11 — Inputs, DOCKER-USER และ rsyslog จากทุกเครื่อง (16.18–16.20)

**เป้าหมาย:** ทุกเครื่องส่ง log เข้า Graylog แบบ TCP พร้อม disk queue และ port รับ log เปิดเฉพาะ lab

**ทฤษฎี**
- TCP + disk queue ทำให้ log ไม่หายเมื่อ Graylog ล่ม UDP ทิ้งเงียบ ๆ
- port ที่ Docker publish ไม่ผ่าน firewalld ต้องจำกัดด้วย DOCKER-USER
- SELinux อนุญาต rsyslog เฉพาะ syslogd_port_t จึงต้องเพิ่ม 1514

**ขั้นตอนปฏิบัติ**
1. สร้าง input syslog-tcp-1514 และ gelf-http-12201
2. ติดตั้ง docker-user-lab.service บน graylog-01
3. semanage port 1514 และเขียน 90-graylog.conf บน client
4. ทดสอบด้วย logger และทดสอบ queue ด้วยการหยุด Graylog

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo semanage port -a -t syslogd_port_t -p tcp 1514
sudo rsyslogd -N1 && sudo systemctl restart rsyslog
logger -p authpriv.notice -t lab-test "hello graylog from $(hostname -s)"
sudo ss -tnp | grep ':1514'
```

**แบบฝึกหัด**
- หยุด Graylog 2 นาที ส่ง logger 10 ข้อความ แล้วเปิดคืน ตรวจว่าครบ 10

**เกณฑ์ผ่าน**
- [ ] เห็นข้อความทดสอบจากทุกเครื่องใน Search โดย source เป็น FQDN
- [ ] ไม่มีข้อความหายในแบบฝึกหัด

**หลักฐาน:** ภาพ Search + ผล ch11-check.sh บน client

อ่านเพิ่ม: บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline

### วันที่ 28 · บทที่ 11 — auditd เข้า syslog และ Streams (16.21–16.24)

**เป้าหมาย:** audit event เข้า Graylog และ log ถูกแยกเป็น 3 stream

**ทฤษฎี**
- auditd บันทึกจาก kernel ผ่าน PAM และมี auid ที่ติดตัวผู้ใช้แม้ sudo
- stream rule ทำงานใน Filter Chain ก่อน pipeline
- OpenSSH 9.8+ เขียน log ในชื่อ sshd-session จึงต้องใช้ regex ^sshd(-session)?$

**ขั้นตอนปฏิบัติ**
1. เปิด syslog plugin ของ auditd และ 10-audit-local.conf
2. สร้าง stream sudo-activity, auth-logs, suspicious-ip
3. ทดสอบ rule ด้วย Load a message to test rules

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo sed -i 's/^active = no/active = yes/' /etc/audit/plugins.d/syslog.conf
sudo auditctl --signal reload 2>/dev/null || sudo service auditd restart
sudo grep -c "sshd-session\[" /var/log/secure
sudo id   # สร้าง event ของ stream sudo-activity
```

**แบบฝึกหัด**
- ออกแบบ stream 5 ตัวของ lab พร้อมเหตุผลเรื่อง retention ของแต่ละตัว

**เกณฑ์ผ่าน**
- [ ] ข้อความ sshd-session เข้า auth-logs และ sudo เข้า sudo-activity
- [ ] อธิบายผลของ "Remove matches from Default Stream" ได้

**หลักฐาน:** ภาพหน้า Streams 3 ตัวที่ Running

อ่านเพิ่ม: บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline

### วันที่ 29 · บทที่ 11 — Pipeline SOC-SSH และ Test Login (16.25)

**เป้าหมาย:** log SSH ทุกบรรทัดมี ssh_event, ssh_user, src_ip และ severity

**ทฤษฎี**
- rule ใน stage เดียวกันไม่รับประกันลำดับ งานที่พึ่งกันต้องคนละ stage
- stage ต้องตั้ง None or more rules match
- route_to_stream() ส่งข้อความเข้า stream หลังมี field แล้ว

**ขั้นตอนปฏิบัติ**
1. วาง rule 12 ตัวจาก SOC-SSH-pipeline.rules
2. สร้าง pipeline 5 stage และผูกกับ auth-logs
3. ตรวจลำดับ Message Processors
4. Test Login 5 เหตุการณ์ (เปิด password ชั่วคราวแล้วลบ)
5. snapshot ch11-ingest

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
ssh -o BatchMode=yes nosuchuser@192.168.10.41 true   # จาก lab-linux-02
sudo journalctl -u sshd --since '-5min' -o cat | grep -E 'Invalid user|Accepted'
sudo rm -f /etc/ssh/sshd_config.d/00-lab-password.conf && sudo systemctl reload sshd
```

**แบบฝึกหัด**
- เพิ่ม rule ที่ดึง fingerprint จาก Accepted publickey ลง field ssh_key_fp

**เกณฑ์ผ่าน**
- [ ] ค้น ssh_event:invalid_user แล้วได้ ssh_user, src_ip และอยู่ใน suspicious-ip
- [ ] Rule Simulation แสดง field ครบ

**หลักฐาน:** ตาราง Test Login 5 เหตุการณ์พร้อม query

อ่านเพิ่ม: บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline

### วันที่ 30 · บทที่ 12 — ภาษาค้นหาและการกรอง event ยืนยันตัวตน

**เป้าหมาย:** ตอบคำถามสืบสวนพื้นฐานจาก log ได้

**ทฤษฎี**
- Lucene syntax: field:value, AND/OR/NOT, wildcard, range
- Time range แบบ relative และ absolute
- USER_START และ USER_LOGIN ของ auditd บอกการเปิด session

**ขั้นตอนปฏิบัติ**
1. เปิด syslog plugin ของ auditd (/etc/audit/plugins.d/syslog.conf: active = yes) เพื่อให้ USER_START เข้า Graylog
2. ค้น login ล้มเหลวทั้ง lab ใน 24 ชม.
3. ค้น USER_START ของ aod
4. จัดกลุ่มผลด้วย Aggregation ตาม src_ip
5. บันทึก saved search

**คำสั่งหลัก** (graylog-01 · aod)
```bash
ssh_event:auth_failed AND NOT src_ip:192.168.10.100
message:"type=USER_START" AND message:"acct=\"aod\""
_exists_:src_ip AND source:lab-linux-0*
```

**แบบฝึกหัด**
- ตอบคำถาม: เมื่อวานใคร login lab-linux-01 สำเร็จบ้าง จาก IP ไหน กี่ครั้ง (ตอบเป็นตาราง)

**เกณฑ์ผ่าน**
- [ ] query ให้ผลถูกต้องเมื่อเทียบกับ /var/log/secure บนเครื่อง
- [ ] มี saved search อย่างน้อย 3 ตัว

**หลักฐาน:** ตารางคำตอบ + query ที่ใช้

อ่านเพิ่ม: บทที่ 12 การค้นหาและสืบสวนใน Graylog

### วันที่ 31 · บทที่ 12 — เงื่อนไขหลายชั้นสำหรับติดตามบัญชี admin (Lab 17)

**เป้าหมาย:** สร้างชุดค้นหาเฝ้าบัญชีสิทธิ์สูง

**ทฤษฎี**
- บัญชีสิทธิ์สูง = เป้าหมายแรกของผู้บุกรุก
- เงื่อนไขซ้อน: admin + นอกเวลางาน + จาก IP ที่ไม่ใช่ admin workstation
- false positive จากงาน automation ต้องแยกออก

**ขั้นตอนปฏิบัติ**
1. สร้าง query สำหรับ admin login นอกเวลา 08:00–18:00
2. แยก login จาก Ansible/script ออกด้วย NOT
3. ทำ dashboard widget จาก query
4. ทดสอบด้วย login ปลอมจาก lab-linux-02

**คำสั่งหลัก** (graylog-01 · aod)
```bash
ssh_user:(aod OR admin) AND ssh_event:auth_success AND NOT src_ip:192.168.10.100
timestamp:["2026-10-12 18:00:00.000" TO "2026-10-13 08:00:00.000"]
```

**แบบฝึกหัด**
- เขียน query ที่จับ "login สำเร็จหลังล้มเหลว 3 ครั้งติดกันจาก IP เดียว" (ใช้ Aggregation + ผลค้นสองชั้น)

**เกณฑ์ผ่าน**
- [ ] login ทดสอบจาก lab-linux-02 ปรากฏใน widget
- [ ] อธิบาย false positive ที่ตัดออกได้

**หลักฐาน:** ภาพ widget + query

อ่านเพิ่ม: บทที่ 12 การค้นหาและสืบสวนใน Graylog

### วันที่ 32 · บทที่ 13 — CrowdSec decision เข้า Graylog และ GeoIP (Lab 18–19)

**เป้าหมาย:** IP ใน log มีตำแหน่งประเทศ และเห็น decision ของ CrowdSec ใน Graylog

**ทฤษฎี**
- GeoIP ต้องใช้ฐานข้อมูล MaxMind GeoLite2 City (สมัครบัญชีฟรี, license key เป็น secret)
- IP ภายใน (192.168.x) ไม่มีตำแหน่ง
- ทดสอบ IP ต่างประเทศด้วย event จำลองที่ใส่ IP สาธารณะ ไม่ต้องมีการเชื่อมต่อจริง

**ขั้นตอนปฏิบัติ**
1. วางไฟล์ GeoLite2-City.mmdb ใน volume ของ Graylog
2. เปิด Geo-Location Processor
3. ส่ง log ของ crowdsec เข้า stream แยก
4. ส่ง event จำลองที่มี IP ต่างประเทศด้วย logger

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
logger -p authpriv.info -t sshd "Failed password for invalid user test from 203.0.113.50 port 50000 ssh2"
logger -p authpriv.info -t sshd "Failed password for invalid user test from 8.8.8.8 port 50001 ssh2"
sudo journalctl -u crowdsec --since "10 min ago" | tail
```

**แบบฝึกหัด**
- อธิบายว่าทำไม 203.0.113.50 (TEST-NET-3) ไม่มีตำแหน่ง แต่ 8.8.8.8 มี

**เกณฑ์ผ่าน**
- [ ] field src_ip_geolocation มีค่าสำหรับ IP สาธารณะ
- [ ] decision ของ CrowdSec ค้นเจอใน Graylog

**หลักฐาน:** ภาพข้อความที่มี field geo

อ่านเพิ่ม: บทที่ 13 Threat Intelligence: CrowdSec, GeoIP และ Global Dashboard

### วันที่ 33 · บทที่ 13 — Global Threat Intelligence Dashboard (Lab 20)

**เป้าหมาย:** dashboard แผนที่และสถิติภัยคุกคามของ lab

**ทฤษฎี**
- Dashboard ที่ดีตอบคำถามเดียวต่อ widget
- แผนที่ (World Map) ใช้ field geolocation
- ตัวเลขสำคัญ: จำนวน IP ที่ถูก ban, ประเทศต้นทาง, user ที่ถูกลอง

**ขั้นตอนปฏิบัติ**
1. สร้าง widget แผนที่จาก src_ip_geolocation
2. Top 10 ประเทศ, Top 10 username ที่ถูกลอง
3. จำนวน decision ของ CrowdSec ต่อชั่วโมง
4. snapshot ch13-ti

**คำสั่งหลัก** (graylog-01 · aod)
```bash
# Dashboards → Create → Add widget: Aggregation (group by src_ip_country_code)
ssh_event:auth_failed AND _exists_:src_ip_geolocation
```

**แบบฝึกหัด**
- นำเสนอ dashboard 3 นาทีเหมือนรายงานผู้บริหาร: เกิดอะไร รุนแรงแค่ไหน ทำอะไรแล้ว

**เกณฑ์ผ่าน**
- [ ] dashboard มีอย่างน้อย 4 widget ที่ตอบคำถามต่างกัน
- [ ] นำเสนอได้ภายใน 3 นาที

**หลักฐาน:** ภาพ dashboard + บทพูด 5 บรรทัด

อ่านเพิ่ม: บทที่ 13 Threat Intelligence: CrowdSec, GeoIP และ Global Dashboard

### ◆ วันที่ 34 — Checkpoint 3: ภาค 4 SIEM

**เป้าหมาย:** สืบสวนเหตุการณ์จำลองจาก Graylog อย่างเดียว

**ทฤษฎี**
- ทบทวนคำถามท้ายบทที่ 10–13

**ขั้นตอนปฏิบัติ**
1. ผู้สอนหรือ script สร้างเหตุการณ์: login ผิดหลายครั้ง, login สำเร็จ, sudo, แก้ไฟล์
2. ผู้เรียนใช้ Graylog อย่างเดียวตอบ ใคร ทำอะไร ที่ไหน เมื่อไร
3. เขียน timeline 10 บรรทัด

**คำสั่งหลัก** (graylog-01 · aod)
```bash
# ใช้ saved search จากวันที่ 30–31 และ dashboard วันที่ 33
```

**แบบฝึกหัด**
- สอบย่อย 10 ข้อจากคำถามทบทวนบทที่ 10–13

**เกณฑ์ผ่าน**
- [ ] timeline ถูกต้องตามเหตุการณ์ที่สร้างอย่างน้อย 8/10 บรรทัด
- [ ] ทุกบรรทัดอ้าง query ที่หาเจอ
- [ ] Rubric ระดับ 3 ขึ้นไป

**หลักฐาน:** timeline + query ประกอบ



## ภาค 5 Wazuh: ตรวจจับและตอบสนอง

### วันที่ 35 · บทที่ 14 — ติดตั้ง Wazuh 4.14 แบบ all-in-one

**เป้าหมาย:** Wazuh indexer, server และ dashboard รันบน wazuh-01

**ทฤษฎี**
- ส่วนประกอบ: indexer (เก็บ alert), server/manager (วิเคราะห์), dashboard (UI), Filebeat (ส่ง alert ไป indexer)
- เอกสาร Wazuh 4.14 ระบุ RHEL 10 เป็นระบบที่รองรับ Rocky 10 เข้ากันได้ แต่ถ้า assistant ปฏิเสธต้องใช้ -i
- รหัสผ่านเริ่มต้นอยู่ใน wazuh-install-files.tar ต้องเก็บรักษาและเปลี่ยน

**ขั้นตอนปฏิบัติ**
1. ดาวน์โหลด installer ของรุ่น 4.14
2. ติดตั้งแบบ -a และเปิด firewall 1514, 1515, 55000, https
3. เก็บไฟล์รหัสผ่านไว้นอกเครื่องอย่างปลอดภัย
4. ตั้ง heap ของ indexer 2 GB (14.3.1)
5. login dashboard

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a
sudo tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt | head -8
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard filebeat --no-pager | grep -E "●|Active"
```

**แบบฝึกหัด**
- วาดผังการไหลของ alert จาก agent → manager → Filebeat → indexer → dashboard

**เกณฑ์ผ่าน**
- [ ] ทั้ง 4 service active (running)
- [ ] filebeat test output ผ่าน

**หลักฐาน:** ผล systemctl status + ผังที่วาด

อ่านเพิ่ม: บทที่ 14 ติดตั้ง Wazuh, Agent และ Agent Group

### วันที่ 36 · บทที่ 14 — Agent ทุกเครื่อง, alert เข้า Graylog และ Agent Group (Lab 34)

**เป้าหมาย:** ทุกเครื่องรายงานเข้า Wazuh, alert ระดับ 5 ขึ้นไปเข้า Graylog และแยก config ตามบทบาท

**ทฤษฎี**
- agent ลงทะเบียนกับ manager ผ่าน port 1515 และส่งข้อมูลที่ 1514
- Agent group แจก agent.conf จาก /var/ossec/etc/shared/<group>/
- เครื่องหนึ่งอยู่ได้หลาย group

**ขั้นตอนปฏิบัติ**
1. เพิ่ม repo ของ Wazuh (import GPG key + wazuh.repo) แล้วติดตั้ง agent ทุกเครื่องพร้อมตัวแปร WAZUH_MANAGER
2. เปิด syslog_output ไป Graylog และสร้าง stream wazuh-alerts กับ pipeline Wazuh
3. สร้าง group linux-base, container-hosts, file-servers และใส่ agent
4. ตรวจว่า config ถูกแจก (agent_groups -S) และรัน ch14-check.sh
5. snapshot ch14-wazuh

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo WAZUH_MANAGER='192.168.10.30' WAZUH_AGENT_NAME="$(hostname -s)" WAZUH_AGENT_GROUP='default' dnf install -y wazuh-agent
sudo sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/wazuh.repo
sudo /var/ossec/bin/agent_groups -a -g linux-base -q   # บน wazuh-01
sudo /var/ossec/bin/verify-agent-conf -f /var/ossec/etc/shared/linux-base/agent.conf
```

**แบบฝึกหัด**
- พิสูจน์ว่า node-01 ได้ค่าจากทั้ง linux-base และ container-hosts และบอกว่า label role ค่าใดชนะเพราะอะไร

**เกณฑ์ผ่าน**
- [ ] agent_control -l แสดงทั้ง 5 เครื่องเป็น Active
- [ ] Graylog ค้น event_source:wazuh แล้วมี field wazuh_rule_id
- [ ] ch14-check.sh ผ่านทุกข้อ

**หลักฐาน:** ผล agent_control -l + ch14-check.sh

อ่านเพิ่ม: บทที่ 14 ติดตั้ง Wazuh, Agent และ Agent Group

### วันที่ 37 · บทที่ 15 — Decoder, rule และ wazuh-logtest

**เป้าหมาย:** เขียน custom rule ช่วง 100000–100999 และทดสอบก่อนใช้

**ทฤษฎี**
- decoder แยก field, rule ตัดสิน level
- if_sid ต่อยอด rule เดิมแทนการเขียนใหม่
- ทดสอบทุก rule ด้วย wazuh-logtest ก่อน restart manager

**ขั้นตอนปฏิบัติ**
1. เปิด wazuh-logtest วางบรรทัด sshd ตัวอย่าง
2. เขียน rule ใน 110-ssh_rules.xml (ไม่ใช้ local_rules.xml เพื่อให้แบ่งไฟล์ตามช่วง ID)
3. ทดสอบซ้ำจน level และ description ตรง
4. restart manager

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
sudo /var/ossec/bin/wazuh-logtest
ls -l /var/ossec/etc/rules/   # 100-tuning … 170-web
sudo /var/ossec/bin/wazuh-analysisd -t && sudo systemctl restart wazuh-manager
```

**แบบฝึกหัด**
- เขียน rule 100150: login สำเร็จของ aod จาก IP ที่ไม่ใช่ 192.168.10.100 ให้ level 10

**เกณฑ์ผ่าน**
- [ ] wazuh-logtest แสดง rule id 100150 สำหรับบรรทัดทดสอบ
- [ ] wazuh-analysisd -t ไม่มี error

**หลักฐาน:** XML ของ rule + ผล logtest

อ่านเพิ่ม: บทที่ 15 Rule, Tuning และ Active Response

### วันที่ 38 · บทที่ 15 — Tuning false positive และตรวจจับ brute-force

**เป้าหมาย:** ลด alert รบกวนโดยไม่ทำให้พลาดเหตุการณ์จริง

**ทฤษฎี**
- frequency + timeframe ใช้จับเหตุการณ์ซ้ำ
- level 0 ปิด alert เฉพาะกรณี ดีกว่าปิดทั้ง rule
- บันทึกเหตุผลของทุกการ tune ไว้ใน comment

**ขั้นตอนปฏิบัติ**
1. หา rule ที่ alert มากที่สุดใน dashboard
2. เขียน rule ยกเว้นงาน automation ที่รู้จัก
3. ทดสอบ brute-force rule 5712/5763 ด้วย login ผิดจาก lab-linux-02
4. ตรวจว่ายังจับเหตุการณ์จริงได้

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
sudo /var/ossec/bin/wazuh-logtest   # วาง Failed password 5 ครั้ง → 100100
sudo grep -c '"id":"100100"' /var/ossec/logs/alerts/alerts.json
sudo systemctl stop crowdsec-firewall-bouncer   # บน lab-linux-01 ระหว่างทดสอบ แล้ว start คืน
```

**แบบฝึกหัด**
- เขียนบันทึก tuning 3 รายการ: rule เดิม, ปัญหา, การแก้, ความเสี่ยงที่ยอมรับ

**เกณฑ์ผ่าน**
- [ ] alert รบกวนลดลงอย่างน้อย 50%
- [ ] brute-force ทดสอบยังเกิด alert

**หลักฐาน:** บันทึก tuning + ตัวเลขก่อน/หลัง

อ่านเพิ่ม: บทที่ 15 Rule, Tuning และ Active Response

### วันที่ 39 · บทที่ 15 — Active Response บล็อก IP และ dashboard ที่ถูกบล็อก

**เป้าหมาย:** บล็อก IP อัตโนมัติแบบมีเวลาหมดอายุ และย้อนกลับได้

**ทฤษฎี**
- active response = คำสั่งที่ manager สั่ง agent รันเมื่อ rule ตรง
- ต้องมี timeout เสมอ และ allowlist IP ของ admin
- CrowdSec (บทที่ 9) กับ Wazuh AR ทำงานซ้อนกัน ต้องเลือกจุดบังคับให้ชัด

**ขั้นตอนปฏิบัติ**
1. เพิ่ม active-response firewall-drop ผูก rule 5763 timeout 600
2. ใส่ white_list ของ 192.168.10.100
3. ทดสอบจาก lab-linux-02 แล้วดู log ของ AR
4. สร้าง visualization IP ที่ถูกบล็อก
5. snapshot ch15-rules

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
<active-response><command>firewall-drop</command><location>local</location><rules_id>100100,100101,5763,5712</rules_id><timeout>600</timeout></active-response>
sudo tail -n 5 /var/ossec/logs/active-responses.log   # บน agent
wazuh_rule_id:100651   # ค้นใน Graylog
```

**แบบฝึกหัด**
- เขียน runbook ครึ่งหน้า: ถ้า AR บล็อก IP ผิด จะปลดบล็อกอย่างไรและแจ้งใคร

**เกณฑ์ผ่าน**
- [ ] lab-linux-02 ถูกบล็อกแล้วปลดเองหลัง timeout
- [ ] IP admin ไม่ถูกบล็อก

**หลักฐาน:** active-responses.log + ภาพ visualization

อ่านเพิ่ม: บทที่ 15 Rule, Tuning และ Active Response

### วันที่ 40 · บทที่ 16 — FIM: โหมด scan, whodata, report_changes และ nodiff (22.1–22.5, 22.10–22.13)

**เป้าหมาย:** เลือกโหมด FIM ให้เหมาะกับไฟล์แต่ละกลุ่ม และรู้ว่าใครแก้ไฟล์ด้วยโปรแกรมใดโดยไม่ทำให้ความลับรั่ว

**ทฤษฎี**
- scheduled, realtime และ whodata ต่างกันที่ความเร็วและข้อมูล "ใคร/โปรแกรมใด"
- whodata ใช้ auditd จึงต้องมี rule wazuh_fim
- report_changes ส่ง diff ของไฟล์ ห้ามใช้กับ /etc/shadow ให้ใช้ nodiff

**ขั้นตอนปฏิบัติ**
1. ต่อยอด agent.conf ของกลุ่ม linux-base จากบทที่ 14 ด้วย directories ของ /etc/ssh และไฟล์บัญชี
2. ใส่ nodiff ให้ /etc/shadow และ /etc/gshadow
3. แก้ sshd_config ด้วย comment ทดสอบแล้วดู alert พร้อม audit.login_user
4. ลบบรรทัดทดสอบและตรวจ alert ของการแก้กลับ

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
sudo /var/ossec/bin/verify-agent-conf -f /var/ossec/etc/shared/linux-base/agent.conf
echo "# fim test" | sudo tee -a /etc/ssh/sshd_config >/dev/null   # บน lab-linux-01
sudo sed -i '/# fim test/d' /etc/ssh/sshd_config   # บน lab-linux-01
sudo jq -r 'select(.syscheck) | [.syscheck.path, .syscheck.audit.login_user.name] | @tsv' /var/ossec/logs/alerts/alerts.json | tail -3
```

**แบบฝึกหัด**
- ทำตาราง 3 แถว: ไฟล์กลุ่มใดใช้ scheduled, realtime หรือ whodata พร้อมเหตุผลด้านภาระและข้อมูลที่ได้

**เกณฑ์ผ่าน**
- [ ] alert ของ sshd_config ระบุผู้ใช้ที่ login จริงและโปรแกรมที่แก้
- [ ] alert ของ /etc/shadow ไม่มีเนื้อหาหรือ hash ของรหัสผ่าน

**หลักฐาน:** alert JSON 2 รายการ (sshd_config และ shadow)

อ่านเพิ่ม: บทที่ 16 File Integrity และ Identity Monitoring

### วันที่ 41 · บทที่ 16 — Persistence path, SUID baseline และ identity (22.14–22.26, 22.3–22.8)

**เป้าหมาย:** เห็นการฝังตัวผ่าน sudoers, authorized_keys, cron, systemd และไฟล์ SUID ใหม่ และการแก้บัญชีผู้ใช้

**ทฤษฎี**
- ผู้บุกรุกที่ได้ root มักทิ้งทางกลับไว้ที่ sudoers.d, authorized_keys, cron และ systemd unit
- SUID baseline ทำให้ไฟล์ SUID ใหม่ทุกไฟล์เป็น alert
- การแก้บัญชีจับได้ทั้ง FIM และ auditd (rule 100220–100222, 100300–100301)

**ขั้นตอนปฏิบัติ**
1. เฝ้า sudoers.d, authorized_keys, cron.d, systemd unit dir และ /boot ผ่าน linux-base
2. ทำ SUID baseline ด้วย find แล้วเปิด rule ไฟล์ SUID ใหม่
3. ทดสอบด้วยไฟล์ใน sudoers.d ที่มีแต่ comment และการเพิ่ม/ถอนสมาชิกกลุ่ม แล้วลบทันที
4. ดู alert ระดับความเสี่ยงสูงใน Graylog

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo find / -xdev -perm /6000 -type f 2>/dev/null | sort > ~/suid-baseline.txt
sudo visudo -f /etc/sudoers.d/99-ch16-test   # ใส่ comment บรรทัดเดียว แล้วลบไฟล์
sudo usermod -aG wheel somchai && sudo gpasswd -d somchai wheel
sudo rm -f /etc/sudoers.d/99-ch16-test
```

**แบบฝึกหัด**
- เลือก persistence path มา 2 จุดที่ไม่ได้อยู่ในบท แล้วเสนอ directories ของ syscheck พร้อมระดับ alert

**เกณฑ์ผ่าน**
- [ ] การเพิ่ม somchai เข้า wheel ได้ alert ระดับสูงพร้อมผู้สั่ง
- [ ] ไม่มีไฟล์ทดสอบค้างใน sudoers.d (ch16-check.sh)

**หลักฐาน:** alert ของ identity + diff ของ SUID baseline

อ่านเพิ่ม: บทที่ 16 File Integrity และ Identity Monitoring

### วันที่ 42 · บทที่ 16 — SMB share, การลบไฟล์จำนวนมาก และบล็อกต้นทาง (22.9, 22.30–22.34)

**เป้าหมาย:** ตรวจจับการลบหรือเปลี่ยนชื่อไฟล์จำนวนมากบน share และบล็อก IP ต้นทางอัตโนมัติ

**ทฤษฎี**
- vfs full_audit ของ Samba บันทึกทุก operation พร้อม user และ IP
- rule 100423/100424 นับการลบและ rename ซ้ำในเวลาสั้น
- Active Response บล็อกต้นทางแบบมีเวลาหมดอายุ และต้องยกเว้น IP ของ admin

**ขั้นตอนปฏิบัติ**
1. ตั้ง share บน lab-linux-02 ด้วยบัญชี smbuser1 (ไม่มี shell)
2. ส่ง log ของ full_audit เข้า Wazuh
3. จาก lab-linux-01 คัดลอกไฟล์ทดสอบ 30 ไฟล์แล้วลบทั้งหมด
4. ดู alert 100423/100424 และกฎ DROP ชั่วคราว แล้วรอให้หมดเวลา

**คำสั่งหลัก** (lab-linux-02 · aod)
```bash
sudo useradd -M -s /sbin/nologin smbuser1 && sudo smbpasswd -a smbuser1
for i in $(seq 1 30); do echo "test $i" > "doc$i.txt"; done   # lab-linux-01 ใน ~/smbtest
smbclient //192.168.10.42/share -U smbuser1 -c 'prompt OFF; mput doc*.txt; mdel doc*.txt'
sudo iptables -S INPUT | grep 192.168.10.41   # ระหว่างถูกบล็อก
```

**แบบฝึกหัด**
- อธิบายว่าเกณฑ์ "ลบ 20 ไฟล์ใน 60 วินาที" จะพลาดหรือเตือนผิดในงานใดของผู้ใช้จริง และจะปรับอย่างไร

**เกณฑ์ผ่าน**
- [ ] เกิด alert 100423 หรือ 100424 พร้อม IP ของ lab-linux-01
- [ ] หลังหมดเวลาไม่มีกฎ DROP ค้าง (ch16-check.sh)

**หลักฐาน:** alert + log ของ active-responses.log

อ่านเพิ่ม: บทที่ 16 File Integrity และ Identity Monitoring

### วันที่ 43 · บทที่ 17 — auditd พื้นฐาน, การต่อเข้า Wazuh และลด log ขยะ (23.1–23.4, 23.6)

**เป้าหมาย:** เขียน audit rule แบบ watch และ syscall ที่มี key และค้นย้อนหลังได้ด้วย ausearch/aureport

**ทฤษฎี**
- rule แบบ watch (-w) กับ syscall (-a) และ key ที่ใช้ค้น
- auid ไม่เปลี่ยนเมื่อ sudo/su จึงระบุคนจริงได้
- ลด log ขยะด้วย exclude ตาม record type และ executable ก่อนส่งออก

**ขั้นตอนปฏิบัติ**
1. ดู rule ปัจจุบันด้วย auditctl -l
2. วางไฟล์ 10-base, 20-exclude, 25-identity และ 30-soc ใน /etc/audit/rules.d/
3. โหลดด้วย augenrules แล้วทดสอบ chmod ไฟล์ทดสอบ (key perm_mod)
4. ส่ง audit log เข้า Wazuh และดู alert 1003xx

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo auditctl -l | head
sudo augenrules --check && sudo augenrules --load
touch /tmp/ch17 && chmod 600 /tmp/ch17 && sudo ausearch -k perm_mod -ts recent -i | tail -5
sudo aureport -k --summary | head
```

**แบบฝึกหัด**
- เขียน rule ที่บันทึกการแก้ /etc/hosts แล้วอธิบายว่าทำไม watch เหมาะกว่า syscall rule ในกรณีนี้

**เกณฑ์ผ่าน**
- [ ] ausearch -k perm_mod พบ event ที่มี auid ของ aod
- [ ] auditctl -s แสดง lost 0

**หลักฐาน:** ผล ausearch + aureport

อ่านเพิ่ม: บทที่ 17 Linux Audit (auditd) สำหรับการสืบสวน

### วันที่ 44 · บทที่ 17 — ไฟล์ rule ตามหมวดแนว CIS และการล็อก rule (23.10–23.29)

**เป้าหมาย:** จัด audit rule เป็นไฟล์ตามหมวด และตั้ง -e 2 โดยไม่ทำให้ whodata ของ Wazuh เสีย

**ทฤษฎี**
- ลำดับไฟล์ใน rules.d มีผล: exclude ต้องมาก่อน rule ที่จะยกเว้น
- -e 2 ทำให้แก้ rule ได้ด้วยการ reboot เท่านั้น
- Wazuh ต้องเพิ่ม rule wazuh_fim ก่อนล็อก

**ขั้นตอนปฏิบัติ**
1. เขียน 40-cis.rules ทีละหมวดพร้อม trigger ที่ไม่เป็นอันตราย
2. สร้าง rule privileged จาก SUID baseline วันที่ 41
3. ใส่ -e 2 ใน 99-finalize.rules หลังทดสอบเสร็จ แล้ว reboot
4. ตรวจ enabled 2, lost 0 และ rule wazuh_fim

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=unset -k delete
-w /etc/sudoers -p wa -k scope
sudo auditctl -s | grep -E "enabled|lost|backlog"
```

**แบบฝึกหัด**
- อธิบายขั้นตอนแก้ rule หลังตั้ง -e 2 ไปแล้วแบบไม่ปิด auditd และไม่เสีย log ระหว่างนั้น

**เกณฑ์ผ่าน**
- [ ] auditctl -s แสดง enabled 2 และ lost 0
- [ ] ch17-check.sh ผ่านข้อ wazuh_fim

**หลักฐาน:** ไฟล์ rules.d + ผล auditctl -s

อ่านเพิ่ม: บทที่ 17 Linux Audit (auditd) สำหรับการสืบสวน

### วันที่ 45 · บทที่ 17 — ตรวจจับระดับ syscall และ proctitle ใน Graylog (23.5, 23.7–23.9, 23.30–23.35)

**เป้าหมาย:** ตรวจจับ shell จาก web server, การโหลด kernel module, การใช้บัญชี nobody, process injection และ LD_PRELOAD ด้วยเหตุการณ์จำลองที่ไม่เป็นอันตราย

**ทฤษฎี**
- key webshell_exec, modules, nobody_exec, process_injection, ld_preload
- trigger ใช้คำสั่งปกติของระบบ เช่น modprobe โมดูล dummy ที่มากับ kernel
- proctitle เป็น hex ต้องถอดรหัสก่อนอ่านใน Graylog

**ขั้นตอนปฏิบัติ**
1. ทดสอบทีละ key ตามส่วน B ของบทแล้วดู alert ใน Wazuh
2. ถอดรหัส proctitle ผ่าน pipeline ของ Graylog
3. สร้าง dashboard SOC Critical
4. ลบบัญชีและ module ทดสอบ แล้ว snapshot ch17-auditd

**คำสั่งหลัก** (lab-linux-01 · aod)
```bash
sudo modprobe dummy && sudo modprobe -r dummy
sudo ausearch -k modules -ts recent -i | grep -E "type=(SYSCALL|KERN_MODULE)" | tail -4
sudo ausearch -k ld_preload -ts recent -i | tail -2
bash pve-snapshot.sh ch17-auditd   # บน pve-01
```

**แบบฝึกหัด**
- เปรียบเทียบ alert ของการโหลด module จาก auditd กับสิ่งที่ Tetragon (บทที่ 19) จะเห็น เขียนเป็นตาราง 3 แถว

**เกณฑ์ผ่าน**
- [ ] ทุก key ในส่วน B มี alert อย่างน้อย 1 ครั้ง
- [ ] Graylog แสดง proctitle เป็นข้อความอ่านได้

**หลักฐาน:** ภาพ dashboard SOC Critical + ผล ch17-check.sh

อ่านเพิ่ม: บทที่ 17 Linux Audit (auditd) สำหรับการสืบสวน

### ◆ วันที่ 46 — Checkpoint 4: ภาค 5 Detection & Response

**เป้าหมาย:** ตรวจจับและตอบสนองเหตุการณ์ persistence จำลองครบวงจร

**ทฤษฎี**
- ทบทวนคำถามท้ายบทที่ 14–17

**ขั้นตอนปฏิบัติ**
1. Scenario: บัญชีถูกยึด ผู้บุกรุกเพิ่ม authorized_keys, สร้าง cron และเพิ่มตัวเองเข้า wheel (ผู้สอนทำด้วยคำสั่งปกติ)
2. ผู้เรียนต้องเห็น alert ทั้ง 3 เรื่อง ระบุ timeline จาก Wazuh + ausearch
3. ย้อนสถานะให้สะอาด และพิสูจน์ด้วย FIM ว่ากลับเป็น baseline

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
# Wazuh Dashboard → Threat Hunting: rule.groups:syscheck AND agent.name:lab-linux-01
sudo ausearch -k identity -k scope -k cron -i --start today
```

**แบบฝึกหัด**
- สอบย่อย 10 ข้อจากคำถามทบทวนบทที่ 14–17

**เกณฑ์ผ่าน**
- [ ] พบ alert ครบ 3 เรื่องภายใน 30 นาที
- [ ] รายงานมี MITRE technique ID ถูกต้อง
- [ ] Rubric ระดับ 3 ขึ้นไป

**หลักฐาน:** รายงานเหตุการณ์ + หลักฐาน



## ภาค 6 Container และ eBPF

### วันที่ 47 · บทที่ 18 — Docker Engine ที่ปลอดภัยและการมองเห็นชั้น Docker API (24-A, 24-B)

**เป้าหมาย:** ติดตั้ง Docker แบบใช้ SELinux และ seccomp ไม่มีสมาชิกในกลุ่ม docker และส่ง event ของ Docker API เข้า Wazuh

**ทฤษฎี**
- container ใช้ kernel ร่วมกับ host: namespace, cgroup v2, capability, seccomp, SELinux
- ใครสั่ง Docker ได้เทียบเท่า root จึงใช้ sudo docker แทนกลุ่ม docker
- docker-listener เห็น exec, kill, commit, cp ผ่าน Docker API

**ขั้นตอนปฏิบัติ**
1. ติดตั้ง Docker CE บน node-01 และตรวจ SecurityOptions
2. สร้าง network lab-net และ container web-01, app-01, tools-01 (label soc.autoresponse=off)
3. เพิ่ม audit rule ของ docker runtime
4. เปิด docker-listener และทดสอบ docker exec

**คำสั่งหลัก** (node-01 · aod)
```bash
sudo docker info --format '{{.CgroupVersion}} {{.SecurityOptions}}'
getent group docker   # ต้องไม่มีสมาชิก
sudo docker run -d --name app-01 --network lab-net alpine:3.20 sleep infinity
sudo docker exec tools-01 id   # สร้าง alert ของ Docker API
```

**แบบฝึกหัด**
- รัน web-01 ใหม่แบบ --read-only, --cap-drop ALL และเพิ่มเฉพาะ capability ที่ nginx ต้องใช้ แล้วยืนยันว่ายังให้บริการได้

**เกณฑ์ผ่าน**
- [ ] docker info แสดง selinux และ seccomp
- [ ] alert ของ docker exec มีชื่อ container และผู้สั่งจาก auditd

**หลักฐาน:** ผล docker info + alert

อ่านเพิ่ม: บทที่ 18 Docker Runtime Security

### วันที่ 48 · บทที่ 18 — rule ของ container และ Active Response แบบไล่ระดับ (24-B, 24-C)

**เป้าหมาย:** ตรวจจับ terminal hijacking, DoS และการนำข้อมูลออกใน container แล้วตอบสนองด้วย pause/stop/kill พร้อม whitelist

**ทฤษฎี**
- rule 1007xx ใน 160-container_rules.xml
- pause แช่แข็งโดยไม่ทำลายหลักฐานในหน่วยความจำ
- label soc.autoresponse=off ทำให้ยังเกิด alert แต่ไม่ถูกตอบโต้

**ขั้นตอนปฏิบัติ**
1. วาง rule และ decoder ของ container บน wazuh-01
2. ติดตั้ง container-response.sh (root:wazuh 750) และทดสอบด้วยมือก่อนผูก rule
3. ทดสอบทั้ง 3 โหมดและ whitelist ตามขั้นตอนที่ 5 ของ 24-C
4. เก็บหลักฐานจาก container ที่ถูก pause แล้ว unpause

**คำสั่งหลัก** (node-01 · aod)
```bash
sudo tail -n 3 /var/ossec/logs/active-responses.log
sudo docker ps -a --format 'table {{.Names}}\t{{.Status}}'
sudo docker unpause app-01
sudo docker inspect -f '{{.Name}} {{.HostConfig.Privileged}}' $(sudo docker ps -q)
```

**แบบฝึกหัด**
- กรอกแบบฟอร์มรายงานผลทดสอบ 4 ขั้น (24.13) ของ 1 สถานการณ์

**เกณฑ์ผ่าน**
- [ ] เห็นผล pause, kill และ skip ตาม label ใน active-responses.log
- [ ] ไม่มี container privileged หรือ mount docker.sock ค้าง

**หลักฐาน:** log ของ Active Response + แบบฟอร์ม 4 ขั้น

อ่านเพิ่ม: บทที่ 18 Docker Runtime Security

### วันที่ 49 · บทที่ 18 — Falco แบบ modern eBPF และ SOC Command Center (24-D, 24-F)

**เป้าหมาย:** ตรวจจับพฤติกรรมใน container ระดับ syscall ด้วย Falco ลด false positive และรวมภาพใน dashboard

**ทฤษฎี**
- Falco ใช้ driver modern_ebpf บน Rocky 10
- rule ของตัวเองอยู่ใน rules.d และ override ได้โดยไม่แก้ rule หลัก
- access log ของ nginx ใน web-01 ใช้ตรวจ scan และบล็อก IP

**ขั้นตอนปฏิบัติ**
1. ติดตั้ง Falco และเปิด JSON output
2. เขียน rule ของตัวเองและส่งเข้า Wazuh
3. ลด false positive ของ tools-01
4. ส่ง access log ของ web-01 เข้า Wazuh และสร้าง dashboard SOC Command Center
5. รัน ch18-check.sh แล้ว snapshot ch18-docker

**คำสั่งหลัก** (node-01 · aod)
```bash
systemctl is-active falco-modern-bpf.service
sudo docker exec -it app-01 sh -c exit
sudo jq -r 'select(.rule=="Terminal shell in container") | .output' /var/log/falco/falco.json | tail -1
bash pve-snapshot.sh ch18-docker   # บน pve-01
```

**แบบฝึกหัด**
- เขียน Falco rule ที่เตือนเมื่อ container เขียนไฟล์ใน /etc และยกเว้น container ที่ตั้งใจเขียน

**เกณฑ์ผ่าน**
- [ ] Falco alert ของ shell ใน app-01 ไปถึง Wazuh
- [ ] ch18-check.sh ผ่านทุกข้อ

**หลักฐาน:** alert ของ Falco + ภาพ SOC Command Center

อ่านเพิ่ม: บทที่ 18 Docker Runtime Security

### วันที่ 50 · บทที่ 19 — ติดตั้ง Tetragon และ eBPF Shield ของ container (Lab 33, 24-E, 35)

**เป้าหมาย:** หยุด process ใน container ที่ละเมิด policy ทันทีในระดับ kernel และส่ง event เข้า Wazuh

**ทฤษฎี**
- Tetragon = eBPF ที่ทั้งสังเกตและบังคับ (Sigkill) ใน kernel
- TracingPolicy: kprobe + selector + action; host_ns NotIn = เฉพาะ container
- Sigkill ไม่ยับยั้ง operation ที่กำลังทำ ต้องใช้ Override หรือ no-new-privileges เป็นชั้นสำรอง

**ขั้นตอนปฏิบัติ**
1. ติดตั้ง Tetragon 1.7.1 จาก tarball และจำกัด export เฉพาะ PROCESS_KPROBE
2. smoke-test แล้วต่อ tetragon.log เข้า Wazuh (rule 100800–100802)
3. โหลด block-tmp-exec, guillotine, protect-shadow ด้วย tetra tracingpolicy add แล้วทดสอบใน ebpf-01
4. โหลด 50-suid-guard.yaml: chmod u+s ใน container ถูก kill ส่วนบน host แค่บันทึก

**คำสั่งหลัก** (node-01 · aod)
```bash
tar -xf tetragon-v1.7.1-amd64.tar.gz && cd tetragon-v1.7.1-amd64 && sudo ./install.sh
sudo tetra tracingpolicy add ~/tp/50-suid-guard.yaml
sudo docker exec ebpf-01 chmod u+s /root/suid-test; echo "exit=$?"
sudo docker exec ebpf-01 ls -l /root/suid-test
```

**แบบฝึกหัด**
- ตรวจ kernel ด้วย grep BPF_KPROBE_OVERRIDE /boot/config-$(uname -r) แล้วอธิบายว่า suid-guard ของ lab ป้องกันได้ระดับใด

**เกณฑ์ผ่าน**
- [ ] chmod u+s ใน container ได้ exit 137 และ bit ไม่ค้าง (หรือแก้คืนแล้ว)
- [ ] chmod g+s บน host ได้ exit 0 และ alert 100813

**หลักฐาน:** exit code + alert 100802/100811/100813

อ่านเพิ่ม: บทที่ 19 Tetragon: มองเห็นและหยุดภัยระดับ Kernel

### วันที่ 51 · บทที่ 19 — keyguard, sensitive file และ Account Activity Tracker (Lab 36–37)

**เป้าหมาย:** ปกป้อง SSH host key แบบสังเกตก่อนบังคับ และรู้ว่าใครอ่านไฟล์ลับหรือแก้บัญชี

**ทฤษฎี**
- policy ฝั่ง host: Post + rateLimit ก่อน แล้วจึง Sigkill
- matchBinaries NotIn ยกเว้น binary ที่อ่านตามหน้าที่ (sshd, sshd-session, sudo)
- auid ระบุคนที่ login จริงแม้ใช้ sudo

**ขั้นตอนปฏิบัติ**
1. เปิด SSH session สำรองและ Console ของ Proxmox
2. keyguard ระยะสังเกต → นับ binary ด้วย jq → ระยะบังคับ แล้วทดสอบ SSH ใหม่
3. โหลด sensitive-files และ account-tracker ทดสอบด้วย tester1 แล้วรัน acct-activity.sh
4. เพิ่ม rule ราย policy และ 100805 → quarantine แล้วติดตั้งถาวรใน tetragon.tp.d
5. รัน ch19-check.sh แล้ว snapshot ch19-ebpf

**คำสั่งหลัก** (node-01 · aod)
```bash
sudo jq -r 'select(.process_kprobe.policy_name=="keyguard") | .process_kprobe.process.binary' /var/log/tetragon/tetragon.log | sort | uniq -c
sudo /usr/local/sbin/acct-activity.sh | tail -5
sudo install -m 600 -o root -g root ~/tp/*.yaml /etc/tetragon/tetragon.tp.d/
sudo systemctl restart tetragon && sudo tetra tracingpolicy list
```

**แบบฝึกหัด**
- เปรียบเทียบสิ่งที่ auditd (บทที่ 17) กับ Tetragon เห็นจากเหตุการณ์ cat /etc/shadow เดียวกัน เป็นตาราง 5 แถว

**เกณฑ์ผ่าน**
- [ ] หลังบังคับ keyguard SSH ใหม่ยังเข้าได้
- [ ] policy 9 ตัวโหลดหลัง restart
- [ ] ch19-check.sh ผ่านทุกข้อ

**หลักฐาน:** ผล ch19-check.sh + ตารางเปรียบเทียบ

อ่านเพิ่ม: บทที่ 19 Tetragon: มองเห็นและหยุดภัยระดับ Kernel

## ภาค 7 SOC Operations ขั้นสูง

### วันที่ 52 · บทที่ 20 — SOC Analyst login Graylog ด้วย FreeIPA และ Sudo Violation Dashboard (Lab 25–26)

**เป้าหมาย:** analyst เข้า Graylog ด้วยบัญชี FreeIPA ตามกลุ่ม และเห็นการใช้ sudo ที่ละเมิดนโยบายใน dashboard

**ทฤษฎี**
- LDAPS 636 ต้องให้ JVM ของ Graylog เชื่อ CA ของ IPA
- filter ตามกลุ่ม soc-analysts ทำให้ intern1 เข้าไม่ได้
- rule 100213 นับการละเมิด sudo ซ้ำของผู้ใช้เดียวกัน

**ขั้นตอนปฏิบัติ**
1. สร้างกลุ่ม soc-analysts และผู้ใช้ analyst1, intern1 ใน IPA
2. ทดสอบ LDAPS จาก graylog-01 ก่อนตั้ง Authentication Service
3. ให้ role แบบ SOC Analyst แล้วทดสอบ login ทั้งสองบัญชี
4. สร้างข้อมูลทดสอบด้วย su - anan / chai แล้วสร้าง dashboard และ event definition
5. snapshot ch20-soc

**คำสั่งหลัก** (graylog-01 · aod)
```bash
ipa group-add soc-analysts --desc="Graylog SOC analysts"   # บน ipa-01
LDAPTLS_CACERT=/opt/graylog/ipa-ca.crt ldapsearch -LLL -H ldaps://ipa-01.lab.internal:636 -D "uid=graylog-bind,cn=sysaccounts,cn=etc,dc=lab,dc=internal" -W -b "cn=users,cn=accounts,dc=lab,dc=internal" "(&(uid=analyst1)(memberOf=cn=soc-analysts,cn=groups,cn=accounts,dc=lab,dc=internal))" uid
su - anan   # บน lab-linux-01 แล้ว sudo cat /etc/shadow 3 ครั้ง
wazuh_rule_id:100213   # ค้นใน Graylog
```

**แบบฝึกหัด**
- เขียนขั้นตอนตอบสนองเมื่อ dashboard แสดง 100213 ของบัญชีหนึ่ง: ตรวจ auid, ถามเจ้าของ, ล็อกบัญชีใน IPA

**เกณฑ์ผ่าน**
- [ ] analyst1 login ได้ และ intern1 ถูกปฏิเสธ
- [ ] dashboard แสดง 100213 ของ anan

**หลักฐาน:** ภาพ dashboard + ผล ldapsearch

อ่านเพิ่ม: บทที่ 20 SOC Analyst Access และ Sudo Violation Dashboard

### วันที่ 53 · บทที่ 21 — ติดตามและบล็อกคำสั่ง Git แบบ real-time (Lab 27)

**เป้าหมาย:** push ไป remote ที่ไม่อนุมัติหรือ force push ถูกหยุด และการพยายามข้าม hook กลายเป็น alert

**ทฤษฎี**
- 4 ชั้น: Track (audit), Guard (pre-push hook), Kernel block (Tetragon git-egress), Server (กฎของ repository)
- hook ฝั่ง client ข้ามได้ด้วย --no-verify จึงเป็นราวกันตก ไม่ใช่กำแพง
- rule 100370–100378 แยกตามชั้น

**ขั้นตอนปฏิบัติ**
1. สร้าง repository ที่อนุมัติบน lab-linux-01 (git.lab.internal) และ remote ทดสอบบน lab-linux-02
2. audit rule และ Wazuh rule ของ git
3. ติดตั้ง system-wide pre-push hook และ policy git-egress
4. ทดสอบ 6 กรณีตามตารางในบท
5. snapshot ch21-git

**คำสั่งหลัก** (node-01 · aod)
```bash
git init --bare -b main /srv/git/demo.git   # บน lab-linux-01
git push --force origin main   # ต้องถูก git-guard หยุด
git push --no-verify evil main   # ต้องถูก Tetragon ตัด
wazuh_rule_id:[100370 TO 100378]   # ค้นใน Graylog
```

**แบบฝึกหัด**
- อธิบายว่าถ้าไม่มีชั้น Kernel block ผู้ใช้จะนำ code ออกได้ด้วยวิธีใดบ้าง (ระดับแนวคิด) และชั้นใดจะยังเห็น

**เกณฑ์ผ่าน**
- [ ] ผลทั้ง 6 กรณีตรงกับตารางในบท
- [ ] ch21-check.sh ผ่านทุกข้อ

**หลักฐาน:** ตารางผลทดสอบ 6 กรณี + alert

อ่านเพิ่ม: บทที่ 21 ติดตามและบล็อกคำสั่ง Git แบบ Real-time

### วันที่ 54 · บทที่ 22 — App log เข้า Graylog, WordPress stack และ Web logging (Lab 28, 30, 31)

**เป้าหมาย:** ส่ง log ของ application 3 วิธี แยก log ของ Nginx กับ WordPress และเร่ง WordPress ด้วย Redis

**ทฤษฎี**
- GELF จาก application, Docker gelf driver และไฟล์ผ่าน rsyslog
- log_format แบบ JSON ทำให้ Graylog ไม่ต้อง parse ด้วย regex
- Redis object cache วัดผลด้วย keyspace_hits/misses

**ขั้นตอนปฏิบัติ**
1. ทำ Lab 28 วิธี A และ B แล้วสร้าง stream และ pipeline
2. start WordPress stack ใน /opt/wordpress และติดตั้ง WordPress
3. สร้าง stream และ pipeline Web แยก nginx กับ WordPress แล้วทำ dashboard Web Overview
4. วัด baseline ด้วย ab แล้วเปิด Redis และวัดซ้ำ

**คำสั่งหลัก** (node-01 · aod)
```bash
cd /opt/wordpress && sudo docker compose up -d && sudo docker compose ps
ab -n 300 -c 10 http://192.168.10.50:8081/ | grep -E "Requests per second|Time per request"
rcli info stats | grep -E 'keyspace_(hits|misses)'   # rcli ตามขั้นตอนที่ 4 ของ Lab 31
log_type:nginx_access AND http_status:>=400   # ค้นใน Graylog
```

**แบบฝึกหัด**
- เทียบตัวเลขก่อนและหลังเปิด Redis และอธิบายว่าทำไมหน้าที่ login แล้วได้ประโยชน์จาก cache น้อยกว่า

**เกณฑ์ผ่าน**
- [ ] Graylog แยก log_type ของ nginx และ WordPress
- [ ] keyspace_hits มากกว่า misses หลังเรียกหน้าซ้ำ

**หลักฐาน:** ผล ab ก่อน/หลัง + ภาพ Web Overview

อ่านเพิ่ม: บทที่ 22 Application และ Web Logging: Nginx, WordPress, Redis และ WAF

### วันที่ 55 · บทที่ 22 — ตรวจจับและหยุด shell execution ใน WordPress (Lab 29)

**เป้าหมาย:** ไฟล์ PHP ทดสอบที่เรียก shell ถูกตรวจจับ, IP ถูกบล็อก, shell ถูกฆ่าใน kernel และปิดทางที่ configuration

**ทฤษฎี**
- 3 รอบ: ตรวจจับและ block IP → ฆ่า shell ใน kernel (Tetragon wp-no-shell, rule 100903) → hardening
- ไฟล์ทดสอบเรียกแค่ id และลบทันทีหลังทดสอบ
- disable_functions และการห้ามรัน PHP ใน uploads ปิดทางตั้งแต่ต้นทาง

**ขั้นตอนปฏิบัติ**
1. ให้ Wazuh เห็นไฟล์และ log ของ WordPress แล้ววาง rule 1009xx
2. วางไฟล์ทดสอบ lab-shelltest.php ตามขั้นตอนที่ 3 แล้วดู alert 100901
3. โหลด policy wp-no-shell แล้วทดสอบซ้ำ
4. เปิด LAB29-HARDENING ใน nginx และลบไฟล์ทดสอบ

**คำสั่งหลัก** (node-01 · aod)
```bash
curl -s http://192.168.10.50:8081/wp-content/uploads/lab-shelltest.php
sudo tetra tracingpolicy list | grep wp-no-shell
sudo docker compose exec -T nginx nginx -t && sudo docker compose exec -T nginx nginx -s reload
sudo docker compose exec -T wordpress rm -f /var/www/html/wp-content/uploads/lab-shelltest.php
```

**แบบฝึกหัด**
- อธิบายว่ารอบที่ 3 (hardening) ทำให้รอบที่ 1–2 ยังจำเป็นอยู่หรือไม่ เพราะอะไร

**เกณฑ์ผ่าน**
- [ ] รอบที่ 2 ไม่มีผลลัพธ์ของ id และมี alert 100903
- [ ] หลัง hardening เรียกไฟล์ PHP ใน uploads ได้ 403

**หลักฐาน:** alert 100901 + 100903 + ผล curl ทั้ง 3 รอบ

อ่านเพิ่ม: บทที่ 22 Application และ Web Logging: Nginx, WordPress, Redis และ WAF

### วันที่ 56 · บทที่ 22 — WAF: ModSecurity + OWASP CRS หน้า WordPress (Lab 32)

**เป้าหมาย:** WAF ทำงานโหมด DetectionOnly ก่อน tune false positive แล้วจึงบล็อก และปิดทางเข้าอ้อม

**ทฤษฎี**
- DetectionOnly บันทึกแต่ไม่บล็อก ใช้เก็บ false positive ก่อน
- exclusion ของ WordPress admin ทำเฉพาะ path และ rule ที่จำเป็น
- ถ้า port 8081 ของ nginx ยังเปิด ผู้ใช้เลี่ยง WAF ได้

**ขั้นตอนปฏิบัติ**
1. เพิ่ม service waf ใน compose โหมด DetectionOnly
2. ส่งคำขอทดสอบ 5 แบบแล้วนับ ruleId
3. tune false positive ของ wp-admin
4. เปลี่ยนเป็น On ปิด port 8081 และย้าย URL ไป 8080
5. ส่ง log ของ WAF เข้า Wazuh/Graylog แล้ว snapshot ch22-web

**คำสั่งหลัก** (node-01 · aod)
```bash
cd /opt/wordpress && sudo docker compose up -d waf
curl -s -o /dev/null -w "%{http_code}\n" "$W/?id=1%27%20OR%20%271%27=%271"   # 403 หลังเปิด On
sudo docker compose logs --since 5m waf | grep -o '"ruleId":"[0-9]*"' | sort | uniq -c | sort -rn | head
curl -s -o /dev/null -w "%{http_code}\n" --max-time 3 http://192.168.10.50:8081/ || echo "8081 ปิดแล้ว"
```

**แบบฝึกหัด**
- เลือก ruleId ที่ชน wp-admin มา 1 ตัว อธิบายว่ายกเว้นแคบที่สุดได้อย่างไร

**เกณฑ์ผ่าน**
- [ ] คำขอปกติได้ 200 และคำขอทดสอบได้ 403
- [ ] port 8081 เข้าตรงไม่ได้

**หลักฐาน:** ตารางผล curl + ไฟล์ exclusion

อ่านเพิ่ม: บทที่ 22 Application และ Web Logging: Nginx, WordPress, Redis และ WAF

## ภาค 8 แจ้งเตือน และ Capstone

### วันที่ 57 · บทที่ 23 — Alert ไป LINE Messaging API และ Telegram (Lab 38)

**เป้าหมาย:** alert level 12 ขึ้นไปถึง LINE รายคน level 10 ขึ้นไปถึงกลุ่ม Telegram ไม่ส่งซ้ำใน 5 นาที และ token ไม่อยู่ใน ossec.conf

**ทฤษฎี**
- LINE Notify ปิดบริการแล้ว ใช้ Messaging API ที่ต้องระบุผู้รับและมีโควตา
- integration ชื่อ custom-* อ่าน token จาก notify.env (640 root:wazuh)
- ส่งเฉพาะ field ที่จำเป็น ไม่ส่ง full_log

**ขั้นตอนปฏิบัติ**
1. ออก Channel access token และหา user ID ของผู้รับ
2. สร้าง Telegram bot และหา chat ID ของกลุ่ม
3. ทดสอบ token ด้วย curl โดยรับค่าด้วย read -s
4. ติดตั้ง custom-line / custom-telegram และ notify.env แล้วทดสอบ script ด้วยมือก่อนผูก
5. ผูก <integration> ตามเกณฑ์ level

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
read -rs LINE_TOKEN; export LINE_TOKEN
curl -s -H "Authorization: Bearer $LINE_TOKEN" https://api.line.me/v2/bot/message/quota; echo
sudo stat -c "%U:%G %a" /var/ossec/etc/notify.env   # root:wazuh 640
sudo tail -n 5 /var/ossec/logs/integrations.log
```

**แบบฝึกหัด**
- ออกแบบเกณฑ์ส่งของทีมคุณ: alert ใดไป dashboard อย่างเดียว ไปกลุ่ม หรือถึงรายคน พร้อมเหตุผล

**เกณฑ์ผ่าน**
- [ ] alert ทดสอบ level 12 ถึง LINE และ level 10 ถึง Telegram
- [ ] alert เดิมซ้ำใน 5 นาทีไม่ถูกส่งซ้ำ

**หลักฐาน:** ภาพข้อความบนมือถือ (ปิด token/ID) + integrations.log

อ่านเพิ่ม: บทที่ 23 Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh

### วันที่ 58 · บทที่ 23 — Gmail ผ่าน Postfix relay, ย้าย port ของ Wazuh และย้าย config เข้ากลุ่ม (Lab 39–40, 34)

**เป้าหมาย:** alert ถึงอีเมลผ่าน relay ที่ใช้ App Password, agent ย้ายจาก 1514 ไป 1614 โดยไม่มีเครื่องใดหลุด และ config ของบริการอยู่ในกลุ่ม

**ทฤษฎี**
- App Password เก็บใน sasl_passwd สิทธิ์ 600 เท่านั้น
- manager ต้องฟังสอง port ชั่วคราวก่อนย้าย agent
- การเปลี่ยน port ไม่ใช่มาตรการความปลอดภัย ต้องจำกัดต้นทางด้วย rich rule

**ขั้นตอนปฏิบัติ**
1. ตั้ง Postfix relay และทดสอบด้วย mail ก่อนเปิด email_notification
2. ย้าย dashboard ไป 8443 แล้วปิด 443
3. เพิ่ม <remote> 1614 ย้าย agent ทีละเครื่องด้วย agent-port.sh แล้วลบ 1514
4. จำกัดต้นทางด้วย rich rule และย้าย config ของ Docker/Samba เข้ากลุ่ม
5. รัน ch23-check.sh แล้ว snapshot ch23-final

**คำสั่งหลัก** (wazuh-01 · aod)
```bash
sudo postconf -e "relayhost = [smtp.gmail.com]:587" "smtp_sasl_auth_enable = yes" "smtp_tls_security_level = encrypt"
sudo chmod 600 /etc/postfix/sasl_passwd && sudo postmap /etc/postfix/sasl_passwd
.\Invoke-SocLabScript.ps1 -Script ..\..\ch23-alerting\guest\agent-port.sh -Name lab-linux-02   # บน Windows
sudo /var/ossec/bin/agent_control -l | grep -c Active
```

**แบบฝึกหัด**
- เขียน runbook ย้อนกลับ (rollback) ถ้า agent ครึ่งหนึ่งหลุดหลังเปลี่ยน port

**เกณฑ์ผ่าน**
- [ ] อีเมล alert ทดสอบถึง Gmail
- [ ] agent ทั้ง 5 ตัว Active ที่ 1614 และ ch23-check.sh ผ่าน

**หลักฐาน:** header ของอีเมล (ปิดข้อมูลส่วนตัว) + ผล agent_control -l

อ่านเพิ่ม: บทที่ 23 Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh

### ◆ วันที่ 59 — Capstone: เหตุการณ์จำลองครบวงจร

**เป้าหมาย:** ใช้ทุกเครื่องมือในเล่มรับมือเหตุการณ์เดียวตั้งแต่ตรวจพบถึงปิดเหตุ

**ทฤษฎี**
- วงจร Incident Response: Detect → Triage → Contain → Eradicate → Recover → Lessons learned

**ขั้นตอนปฏิบัติ**
1. ผู้สอนรันเหตุการณ์จำลอง (ไม่เป็นอันตราย): login ผิดจาก lab-linux-02 → login สำเร็จด้วยบัญชีทดสอบ → เพิ่ม authorized_keys → วางไฟล์ทดสอบ PHP → ลบไฟล์ dummy ใน share
2. ผู้เรียนรับ alert ทางมือถือ แล้วสืบด้วย Graylog, Wazuh, ausearch และ Tetragon
3. Contain: ปิดบัญชีใน IPA, บล็อก IP, ลบ key และไฟล์
4. ยืนยันกลับ baseline ด้วย FIM และ check script

**คำสั่งหลัก** (Windows · PowerShell)
```bash
# ใช้ทุกคำสั่งจากวันที่ 16, 24, 30–31, 39–46, 55
```

**แบบฝึกหัด**
- เขียนรายงานเหตุการณ์ (template ในภาคผนวกของคู่มือ) ไม่เกิน 3 หน้า

**เกณฑ์ผ่าน**
- [ ] ตรวจพบครบ 5 ขั้นของเหตุการณ์
- [ ] containment เสร็จภายใน 60 นาทีจาก alert แรก
- [ ] รายงานมี timeline, MITRE ID, หลักฐาน และข้อเสนอปรับปรุง

**หลักฐาน:** รายงานเหตุการณ์ + หลักฐาน



### ◆ วันที่ 60 — ประเมินผลสุดท้ายและ Portfolio

**เป้าหมาย:** สรุปผลงานทั้งหมดเป็น portfolio ที่นำไปใช้สมัครงานได้

**ทฤษฎี**
- Portfolio ที่ดีแสดงทั้งการตั้งค่า, หลักฐาน และการตัดสินใจ

**ขั้นตอนปฏิบัติ**
1. รวมหลักฐานของ checkpoint 1–4 และ capstone
2. นำเสนอ 15 นาที: สถาปัตยกรรม lab, detection 3 ตัวที่ภูมิใจที่สุด, บทเรียน
3. ตอบคำถามเชิงเทคนิค 10 นาที
4. ลบ secret ทั้งหมดออกจาก portfolio ก่อนส่ง

**คำสั่งหลัก** (Windows · PowerShell)
```bash
git -C D:\soclab\my-portfolio log --oneline | Select-Object -First 20
Select-String -Path D:\soclab\my-portfolio\* -Pattern "BEGIN .*PRIVATE KEY|password\s*=" -List
```

**แบบฝึกหัด**
- ประเมินตัวเองด้วย Rubric รวม แล้วเทียบกับผลประเมินของผู้สอน

**เกณฑ์ผ่าน**
- [ ] คะแนนรวม Rubric ≥ 75%
- [ ] ไม่มี secret ใน portfolio
- [ ] นำเสนอครบเวลา

**หลักฐาน:** Portfolio + slide นำเสนอ


