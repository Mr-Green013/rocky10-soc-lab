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

## เส้นทางการอ่าน

- **ครบทั้งเล่ม (มือใหม่)**: บท 1 → 23 ตามลำดับ
- **Fast track (admin)**: บท 1 → 7 → 8 → 9 → 10–13 → 14–17 → เลือก 18–23 ตามงาน
- **เฉพาะ SIEM**: บท 1, 2, 7, 10–13
- **เฉพาะ Detection & Response**: บท 1, 2, 7, 14–17, 19, 23

บทที่มี snapshot เมื่อจบ คือจุดที่ rollback กลับมาเริ่มบทถัดไปใหม่ได้
