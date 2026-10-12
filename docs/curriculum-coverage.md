# เทียบสารบัญหลักสูตรกับเนื้อหาที่มี

ตรวจหัวข้อในสารบัญหลักสูตร 40 Lab เทียบกับเอกสาร 8 หมวดและบทในหนังสือ (ตรวจเมื่อ 11 ต.ค. 2026)

สถานะ: **ครบ** = มีเนื้อหาครบทุกหัวข้อย่อย · **ขาดบางส่วน** = มีหัวข้อย่อยที่ยังไม่มีเนื้อหา · **ต้องยืนยัน** = ต้องดูชื่อหัวข้อจากสารบัญต้นฉบับ

| Lab | หัวข้อในสารบัญ | เอกสารหมวด | บทในหนังสือ | สถานะ | หมายเหตุ |
| --- | --- | --- | --- | --- | --- |
| 1 | Install Rocky Linux 10.1 | 1 | 1 | ครบ | บทที่ 1 เขียนแล้ว |
| 2 | Config Network | 1 | 2 | ครบ | ต้องปรับให้เข้ากับ lab ที่ cloud-init ตั้ง IP ให้แล้ว (NIC `eth0`, connection ของ cloud-init) |
| 3 | Install SSH | 1 | 2 | ครบ | ต้องอธิบาย drop-in `50-cloud-init.conf` ที่ cloud-init สร้าง |
| 4 | Checking the Linux Kernel Version | 1 | 3 | ครบ | |
| 5 | Config Hostname | 1 | 2 | ครบ | ต้องแก้ `/etc/hosts` ที่ cloud-init ใส่ FQDN ไว้กับ 127.0.0.1 |
| 6 | Timezone และ NTP | 1 | 3 | ครบ | เพิ่ม: pve-01 เป็น NTP ของ lab |
| 7 | Check Rocky Linux Version | 1 | 1, 3 | ครบ | |
| 8 | Understanding SELinux and Systemctl | 1 | 4 | ครบ | |
| 9 | Command Line Fundamentals 9.1–9.15 | 2 | 5 | ครบ | มีครบ 15 หัวข้อ |
| 10 | Manage local users and groups 10.1–10.13 | 2 | 6 | เติมแล้ว | 10.10 ล็อก ปลดล็อก และปิดบัญชีผู้ใช้ (หัวข้อใหม่) |
| 11 | LAB IPA | 2 | 7 | ครบ | Install, join, password policy, HBAC, sudo, SSH keys, LDAP |
| 12 | SSH Key Authentication | 2 | 8 | ครบ | |
| 13 | Limit session SSH | 2 | 8 | ครบ | |
| 14 | CrowdSec Ban IP ssh Brute-force | 3 | 9 | ครบ | |
| 15 | Block Anonymous Proxies / Tor | 3 | 9 | ครบ | |
| 16 | Project-Graylog 16.1–16.25 | 4 | 10, 11 | เติมแล้ว | 16.16 เชื่อม cloudflared เข้ากับ Nginx (หัวข้อใหม่) |
| 17 | การค้นหา | 4 | 12 | ครบ | |
| 18 | CrowdSec บน Graylog | 4 | 13 | ครบ | |
| 19 | SSH GeoIP จาก IP ต่างประเทศ | 4 | 13 | ครบ | |
| 20 | Global Threat Intelligence Dashboard | 4 | 13 | ครบ | |
| 21 | Project Wazuh 21.1–21.26 | 5 | 14, 15 | ครบ | แบ่งเป็นส่วน A–E ครบ 26 หัวข้อ |
| 22 | Syscheck (FIM) & Identity Monitoring | 5 | 16 | เติมแล้ว | 22.10–22.26 FIM เชิงลึก 17 หัวข้อ (หัวข้อใหม่) |
| 23 | Auditd File 23.1–23.35 | 5 | 17 | เติมแล้ว | 23.10–23.29 หมวดหมู่ audit rule 20 หัวข้อ (หัวข้อใหม่) |
| 24 | Docker Lab 24.1–24.49 | 6 | 18 | ครบ | แบ่งเป็นส่วน A–F ครบ 49 หัวข้อ |
| 25 | SOC Analyst Mode ผ่าน FreeIPA | 7 | 20 | ครบ | |
| 26 | Dashboard Sudo Access Violation | 7 | 20 | ครบ | |
| 27 | Git Command Tracking and Blocking | 7 | 21 | ครบ | |
| 28 | Config App log to Graylog | 7 | 22 | ครบ | |
| 29 | Block Shell Execution ใน WordPress | 7 | 22 | ครบ | |
| 30 | Centralized Web Logging | 7 | 22 | ครบ | |
| 31 | WordPress + Redis Cache | 7 | 22 | ครบ | |
| 32 | Web Application Firewall หน้า WordPress (ModSecurity + OWASP CRS) | – | 22 | เติมแล้ว | หัวข้อใหม่ ทางเลือก B |
| 33 | Install Tetragon | 6 | 19 | ครบ | |
| 34 | Group Agent on Wazuh | 8 | 14 | ครบ | |
| 35 | Kill คำสั่งสร้าง SUID/SGID | 6 | 19 | ครบ | |
| 36 | Monitor sensitive file access | 6 | 19 | ครบ | |
| 37 | Account Activity Tracker | 6 | 19 | ครบ | |
| 38 | Wazuh Alert ไป LINE / Telegram | 8 | 23 | ครบ | ใช้ LINE Messaging API แทน LINE Notify ที่ปิดบริการแล้ว |
| 39 | Wazuh แจ้งเตือนผ่าน Gmail | 8 | 23 | ครบ | |
| 40 | Change port wazuh | 8 | 23 | ครบ | |

## สรุป

ทุกหัวข้อในสารบัญมีเนื้อหาหรือมีชื่อหัวข้อที่อนุมัติแล้ว รายละเอียดของหัวข้อที่เติมใหม่อยู่ใน [proposed-subtopics.md](proposed-subtopics.md)
