# โครงเล่ม: SOC Lab บน Rocky Linux 10

จากผู้ดูแลระบบ Linux สู่งาน Security Operations ด้วย FreeIPA, CrowdSec, Graylog, Wazuh และ eBPF

## สำหรับใคร

- **มือใหม่**: ไม่เคยใช้ Linux หรือเคยใช้น้อย อ่านตามลำดับทุกบท
- **System admin ที่จะย้ายไปสาย security**: ใช้ Linux เป็นแล้ว ทำบทที่ 1 แล้วอ่านภาค 1–2 แบบเร็ว (ทำเฉพาะ "วิธีตรวจสอบ" และกล่อง "มุมมอง Security") แล้วเริ่มเต็มที่ตั้งแต่ภาค 3

## ห้องแลป

| เครื่อง | IP | VM ID | vCPU / RAM / Disk | หน้าที่ |
| --- | --- | --- | --- | --- |
| Windows (host) | 192.168.10.100 | – | – | admin workstation, Hyper-V |
| pve-01 | 192.168.10.1 (lab), 172.31.255.2 (uplink) | – | 20 / 56 GB / 600 GB | Proxmox VE, gateway ของ lab |
| ipa-01 | 192.168.10.10 | 110 | 2 / 4 GB / 40 GB | FreeIPA (IdM, DNS, CA) |
| graylog-01 | 192.168.10.20 | 120 | 4 / 10 GB / 100 GB | Graylog 7.1 (SIEM) |
| wazuh-01 | 192.168.10.30 | 130 | 4 / 8 GB / 100 GB | Wazuh 4.14 (XDR/SOAR) |
| lab-linux-01 | 192.168.10.41 | 141 | 2 / 2 GB / 32 GB | Linux server, git server |
| lab-linux-02 | 192.168.10.42 | 142 | 2 / 2 GB / 32 GB | เครื่องโจมตีจำลอง, Samba |
| node-01 | 192.168.10.50 | 150 | 4 / 6 GB / 64 GB | Docker, Tetragon, WordPress |

Domain `lab.internal`, ผู้ใช้ admin `aod`, template `rocky10-tpl` (VM ID 9000)

## สารบัญ

| ภาค | บท | ชื่อบท | Lab ในหลักสูตร | เครื่องที่ใช้ | Snapshot เมื่อจบ |
| --- | --- | --- | --- | --- | --- |
| 0 เตรียมห้องแลป | 1 | สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10 | 1, 7 | Windows, pve-01, ทุก VM | `ch01-base` |
| 1 พื้นฐานระบบและเครือข่าย | 2 | Network, SSH และ Hostname | 2, 3, 5 | ทุก VM | `ch02-network` |
| | 3 | Kernel, เวอร์ชันระบบ, Timezone และ NTP | 4, 6, 7 | ทุก VM | `ch03-time` |
| | 4 | SELinux และ systemd | 8 | lab-linux-01 | – |
| 2 คำสั่งและตัวตน | 5 | Command Line ที่ SOC ต้องใช้ทุกวัน | 9.1–9.15 | lab-linux-01 | – |
| | 6 | ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน | 10.1–10.13 | lab-linux-01 | `ch06-users` |
| | 7 | Centralized Identity ด้วย FreeIPA | 11 | ipa-01 + ทุก VM | `ch07-ipa` |
| | 8 | SSH Hardening: Key Authentication และ Session Limit | 12, 13 | lab-linux-01/02 | `ch08-ssh` |
| 3 ป้องกันภัยคุกคามเบื้องต้น | 9 | CrowdSec: Ban Brute-force และบล็อก Tor/Proxy | 14, 15 | lab-linux-01/02 | `ch09-crowdsec` |
| 4 SIEM ด้วย Graylog | 10 | ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย | 16 (ติดตั้ง, Cloudflare Tunnel, Nginx, SSL) | graylog-01 | `ch10-graylog` |
| | 11 | รับ Log: Inputs, rsyslog, Streams และ Pipeline | 16 (Inputs, rsyslog, Streams, Pipeline Rules) | graylog-01 + ทุก VM | `ch11-ingest` |
| | 12 | การค้นหาและสืบสวนใน Graylog | 17 | graylog-01 | – |
| | 13 | Threat Intelligence: CrowdSec, GeoIP และ Global Dashboard | 18, 19, 20 | graylog-01 | `ch13-ti` |
| 5 Wazuh: ตรวจจับและตอบสนอง | 14 | ติดตั้ง Wazuh, Agent และ Agent Group | 21 (Native deploy, Filebeat, Agent), 34 | wazuh-01 + ทุก VM | `ch14-wazuh` |
| | 15 | Rule, Tuning และ Active Response | 21 (Syscheck rule, Tuning, Brute-force, Auto-defense, Dashboard) | wazuh-01 | `ch15-rules` |
| | 16 | File Integrity และ Identity Monitoring | 22 | wazuh-01, lab-linux-01/02 | – |
| | 17 | Linux Audit (auditd) สำหรับการสืบสวน | 23 | lab-linux-01, node-01 | `ch17-auditd` |
| 6 Container และ eBPF | 18 | Docker Runtime Security | 24 | node-01 | `ch18-docker` |
| | 19 | Tetragon: มองเห็นและหยุดภัยระดับ Kernel | 33, 35, 36, 37 | node-01 | `ch19-tetragon` |
| 7 SOC Operations ขั้นสูง | 20 | SOC Analyst Access และ Sudo Violation Dashboard | 25, 26 | ipa-01, graylog-01 | – |
| | 21 | ติดตามและบล็อกคำสั่ง Git แบบ Real-time | 27 | lab-linux-01 | – |
| | 22 | Application และ Web Logging: Nginx, WordPress, Redis | 28, 29, 30, 31 | node-01, graylog-01 | `ch22-web` |
| 8 แจ้งเตือนและปรับแต่ง | 23 | Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh | 38, 39, 40 | wazuh-01 | `ch23-final` |
| ภาคผนวก | ก | สร้างห้องแลปบน Azure ด้วย Terraform | – | – | – |
| | ข | ตาราง Port, Service และ Firewall ของทุกเครื่อง | – | – | – |
| | ค | แผนที่ Wazuh Rule ID และ Graylog Stream | – | – | – |
| | ง | ดัชนีปัญหาและวิธีแก้ (รวมจากทุกบท) | – | – | – |
| | จ | อภิธานศัพท์ ไทย–อังกฤษ | – | – | – |

หมายเหตุ: หลักสูตรต้นฉบับข้ามเลข Lab 32 (จาก 31 ไป 33) เล่มนี้คงเลข Lab เดิมไว้เพื่อให้อ้างอิงกับหลักสูตรได้ การแบ่ง Lab 16 และ 21 ออกเป็น 2 บทจะยืนยันเลขหัวข้อย่อยอีกครั้งตอนเขียนบทนั้น

## เนื้อหาแต่ละบทโดยย่อ

**บทที่ 1 สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10** (Lab 1, 7)  
เปิด nested virtualization บน Hyper-V ติดตั้ง Proxmox VE 9 สร้าง network ของ lab ที่แยกจาก LAN บ้าน ติดตั้ง Rocky Linux 10 จาก ISO ทำ golden image แล้ว clone ออกเป็น 6 เครื่องด้วย cloud-init  
ได้: ห้องแลป 7 เครื่องที่ตรวจได้อัตโนมัติ; template rocky10-tpl สำหรับสร้างเครื่องใหม่; snapshot และ backup ของทั้ง lab

**บทที่ 2 Network, SSH และ Hostname** (Lab 2, 3, 5)  
ตั้ง IP, DNS และ search domain ด้วย nmcli อ่าน NetworkManager profile ตั้ง hostname แบบ FQDN และ /etc/hosts ให้ตรงกับที่ FreeIPA ต้องการ ติดตั้งและตรวจ sshd รวมถึงลำดับของไฟล์ใน sshd_config.d  
ได้: ทุกเครื่องมี FQDN ที่ resolve เป็น IP จริง; เข้าใจว่า sshd อ่านค่าจากไฟล์ใดก่อนหลัง (sshd -T)

**บทที่ 3 Kernel, เวอร์ชันระบบ, Timezone และ NTP** (Lab 4, 6, 7)  
ตรวจเวอร์ชันของ kernel และระบบด้วย uname, rpm, os-release ตั้ง timezone Asia/Bangkok และ chrony ให้ทุกเครื่องเวลาตรงกัน พร้อมเหตุผลว่าทำไมเวลาที่คลาดกันทำให้สืบสวนเหตุการณ์จาก log ไม่ได้  
ได้: ทุกเครื่อง sync เวลาจากแหล่งเดียวกัน; อ่าน chronyc sources และ tracking ได้

**บทที่ 4 SELinux และ systemd** (Lab 8)  
โหมดและ context ของ SELinux, boolean, semanage port, อ่าน AVC denial ด้วย ausearch และ audit2why จัดการ service ด้วย systemctl, unit drop-in และ target  
ได้: แก้ปัญหา SELinux โดยไม่ปิด SELinux; เขียน unit drop-in เพื่อปรับ service อย่างปลอดภัย

**บทที่ 5 Command Line ที่ SOC ต้องใช้ทุกวัน** (Lab 9.1–9.15)  
โครงสร้าง filesystem, การเดินทางใน directory, nano, การจัดการ output, sudo และ sudoers, journalctl แบบกรอง, rsync, shutdown และ I/O redirection โดยใช้ตัวอย่างจาก log จริงของ lab  
ได้: ค้นและกรอง log ด้วย journalctl, grep, awk; คัดลอกข้อมูลหลักฐานด้วย rsync โดยรักษา metadata

**บทที่ 6 ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน** (Lab 10.1–10.13)  
โครงสร้าง /etc/passwd และ /etc/shadow, script สร้างผู้ใช้หลายคน, password history และ aging, สิทธิ์ super user และการจัดการกลุ่ม รวมถึงตรวจสิทธิ์ NOPASSWD ที่ cloud-init ให้ไว้ในบทที่ 1  
ได้: นโยบายรหัสผ่านที่บังคับใช้จริงด้วย PAM; รู้จุดที่ผู้โจมตีใช้ยกระดับสิทธิ์ผ่านบัญชีและกลุ่ม

**บทที่ 7 Centralized Identity ด้วย FreeIPA** (Lab 11)  
ติดตั้ง FreeIPA พร้อม DNS และ CA ให้ทุกเครื่อง join domain ตั้ง password policy, HBAC rule, sudo rule และ SSH key แบบรวมศูนย์ และค้นข้อมูลผ่าน LDAP  
ได้: login ทุกเครื่องด้วยบัญชีเดียว; ipa-01 เป็น DNS ของทั้ง lab

**บทที่ 8 SSH Hardening: Key Authentication และ Session Limit** (Lab 12, 13)  
กลไกของ SSH key authentication, ปิด password authentication, จำกัด session และ connection ด้วย MaxSessions, MaxStartups, ClientAlive และ limit ของ PAM  
ได้: SSH ที่ใช้ key อย่างเดียวและจำกัด session; อ่าน log การ login ของ sshd ได้ถูกต้อง

**บทที่ 9 CrowdSec: Ban Brute-force และบล็อก Tor/Proxy** (Lab 14, 15)  
ติดตั้ง CrowdSec, acquisition และ scenario ของ sshd, firewall bouncer, ทดสอบ brute-force จำลองจาก lab-linux-02 และบล็อก Tor exit node และ anonymous proxy ด้วย blocklist  
ได้: IP ที่ brute-force ถูก ban อัตโนมัติ; จัดการ decision และ allowlist ได้

**บทที่ 10 ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย** (Lab 16)  
ติดตั้ง Graylog 7.1 ด้วย Docker Compose บน Rocky 10, Nginx reverse proxy พร้อม TLS และเปิดให้เข้าจากภายนอกผ่าน Cloudflare Tunnel โดยไม่เปิด port  
ได้: Graylog ที่เข้าผ่าน HTTPS; เข้าใจส่วนประกอบของ Graylog, MongoDB และ search backend

**บทที่ 11 รับ Log: Inputs, rsyslog, Streams และ Pipeline** (Lab 16)  
สร้าง input แบบ Syslog และ GELF ส่ง log จากทุกเครื่องด้วย rsyslog แยก stream ตามประเภท และเขียน pipeline rule แยก field ของ SSH สำหรับงาน SOC  
ได้: log ของทุกเครื่องเข้า Graylog แบบ real-time; field ของ event SSH พร้อมใช้ค้นหา

**บทที่ 12 การค้นหาและสืบสวนใน Graylog** (Lab 17)  
ภาษาค้นหาของ Graylog, กรอง event การยืนยันตัวตน, USER_START และเงื่อนไขหลายชั้นสำหรับติดตามบัญชี admin พร้อม saved search  
ได้: ตอบคำถามสืบสวน ใคร ทำอะไร ที่ไหน เมื่อไร จาก log

**บทที่ 13 Threat Intelligence: CrowdSec, GeoIP และ Global Dashboard** (Lab 18, 19, 20)  
นำ decision ของ CrowdSec เข้า Graylog, เพิ่ม GeoIP ให้ IP, ทดสอบ SSH จาก IP ต่างประเทศด้วย event จำลอง และสร้าง dashboard แผนที่ภัยคุกคาม  
ได้: dashboard ภัยคุกคามที่มีตำแหน่งทางภูมิศาสตร์

**บทที่ 14 ติดตั้ง Wazuh, Agent และ Agent Group** (Lab 21, 34)  
ติดตั้ง Wazuh manager, indexer และ dashboard ส่ง alert ด้วย Filebeat ติดตั้ง agent ทุกเครื่องและจัดกลุ่ม agent เพื่อแจก configuration ตามหน้าที่ของเครื่อง  
ได้: ทุกเครื่องรายงานเข้า Wazuh; agent group ที่แยก config ตามบทบาท

**บทที่ 15 Rule, Tuning และ Active Response** (Lab 21)  
decoder และ rule แบบ custom (ช่วง ID 100000–100999), ลด false positive, ตรวจจับ brute-force, active response บล็อก IP อัตโนมัติ และ dashboard ของ IP ที่ถูกบล็อก  
ได้: rule ที่ tune แล้วพร้อม test ด้วย wazuh-logtest; ตอบสนองอัตโนมัติที่ย้อนกลับได้

**บทที่ 16 File Integrity และ Identity Monitoring** (Lab 22)  
syscheck แบบ realtime และ whodata ติดตามไฟล์สำคัญ ตรวจการแก้กลุ่ม การสวมรอยด้วย usermod เฝ้าดู SMB share และแจ้งเตือนการลบไฟล์จำนวนมากแบบ ransomware  
ได้: รู้ว่าใครแก้ไฟล์ไหนเมื่อไร; alert การลบไฟล์จำนวนมาก

**บทที่ 17 Linux Audit (auditd) สำหรับการสืบสวน** (Lab 23)  
เขียน audit rule, ใช้ ausearch และ aureport, จำลอง web shell, ดักจับ privilege dropping, การโหลด kernel module แบบ rootkit และการเรียกใช้ eBPF API  
ได้: audit rule ที่ใช้ตรวจเทคนิคการโจมตีระดับ syscall

**บทที่ 18 Docker Runtime Security** (Lab 24)  
จำลองการโจมตี container: terminal hijacking, DoS, data exfiltration ตรวจจับด้วย Falco และ eBPF และป้องกันด้วยการตั้งค่า runtime  
ได้: ตรวจจับพฤติกรรมผิดปกติใน container ได้ real-time

**บทที่ 19 Tetragon: มองเห็นและหยุดภัยระดับ Kernel** (Lab 33, 35, 36, 37)  
ติดตั้ง Tetragon บน node-01 เขียน TracingPolicy เพื่อ kill คำสั่งสร้าง SUID/SGID เฝ้าดูการเข้าถึงไฟล์สำคัญ และติดตามกิจกรรมของบัญชีผู้ใช้  
ได้: หยุด process อันตรายได้ทันทีในระดับ kernel

**บทที่ 20 SOC Analyst Access และ Sudo Violation Dashboard** (Lab 25, 26)  
ให้ analyst login Graylog ด้วยบัญชี FreeIPA ผ่าน LDAP กำหนด role และสร้าง dashboard การใช้ sudo ที่ผิดนโยบาย  
ได้: สิทธิ์ของทีม SOC จัดการจากที่เดียว

**บทที่ 21 ติดตามและบล็อกคำสั่ง Git แบบ Real-time** (Lab 27)  
ติดตามคำสั่ง git ด้วย audit และ log ส่ง event เข้า SIEM และบล็อกการ push ที่ผิดนโยบายด้วย hook  
ได้: มองเห็นและควบคุมการเปลี่ยนแปลง source code

**บทที่ 22 Application และ Web Logging: Nginx, WordPress, Redis** (Lab 28, 29, 30, 31)  
ส่ง log ของ application เข้า Graylog, เขียน rule ดักจับและบล็อก shell execution ใน WordPress, แยก log ของ Nginx กับ WordPress และเร่งความเร็ว WordPress ด้วย Redis  
ได้: log ของ web stack แยกและค้นได้; ตรวจจับ web shell ได้

**บทที่ 23 Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh** (Lab 38, 39, 40)  
integration ของ Wazuh ส่ง alert ไป LINE Messaging API (แทน LINE Notify ที่ปิดบริการ), Telegram bot และ Gmail ผ่าน SMTP relay และย้าย port ของ Wazuh dashboard พร้อม firewall rule  
ได้: alert ระดับสำคัญถึงมือถือภายในไม่กี่วินาที

## เส้นทางการอ่าน

- **ครบทั้งเล่ม (มือใหม่)**: บท 1 → 23 ตามลำดับ
- **Fast track (admin)**: บท 1 → 7 → 8 → 9 → 10–13 → 14–17 → เลือก 18–23 ตามงาน
- **เฉพาะ SIEM**: บท 1, 2, 7, 10–13
- **เฉพาะ Detection & Response**: บท 1, 2, 7, 14–17, 19, 23

บทที่มี snapshot เมื่อจบ คือจุดที่ rollback กลับมาเริ่มบทถัดไปใหม่ได้
