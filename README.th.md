[English](README.md) · **ภาษาไทย**

# rocky10-soc-lab

ไฟล์ Lab ประกอบหนังสือ **SOC Lab บน Rocky Linux 10: จากผู้ดูแลระบบ Linux สู่งาน Security Operations**

ห้องแลป 7 เครื่องบน Proxmox VE (nested บน Hyper-V ของ Windows) สำหรับฝึก FreeIPA, CrowdSec, Graylog, Wazuh, auditd, Docker security และ eBPF/Tetragon ตั้งแต่ติดตั้งระบบจนถึงตรวจจับและตอบสนองภัยคุกคามอัตโนมัติ

```
Windows 11 Pro (192.168.10.100)
└─ Hyper-V
   └─ pve-01  Proxmox VE 9  (gateway 192.168.10.1)
      ├─ ipa-01        .10  FreeIPA
      ├─ graylog-01    .20  Graylog SIEM
      ├─ wazuh-01      .30  Wazuh
      ├─ lab-linux-01  .41  Linux server
      ├─ lab-linux-02  .42  attacker simulation
      └─ node-01       .50  Docker / Tetragon / WordPress
```

## เริ่มต้น

1. อ่านบทที่ 1 ในหนังสือ หรือ [`ch01-lab-platform/README.th.md`](ch01-lab-platform/README.th.md) สำหรับลำดับคำสั่งแบบย่อ
2. Clone repo นี้ไว้บน Windows (`git clone` หรือ Download ZIP) แล้วคัดลอกไปที่ pve-01 ในขั้นที่ 5 ของบทที่ 1
3. ทำตามบทตามลำดับ จบบทที่มี snapshot ให้รัน `pve-snapshot.sh <ชื่อ>` เพื่อมีจุดกลับ

ไม่มีเครื่อง Windows ที่แรงพอ: ใช้ [`infra/azure-terraform`](infra/azure-terraform/README.th.md) สร้าง lab เดียวกันบน Azure (ภาคผนวก ก)

## สองภาษา

- เอกสาร `X.md` เป็นภาษาอังกฤษ และ `X.th.md` เป็นภาษาไทย ทุกหน้ามีลิงก์สลับภาษาที่บรรทัดแรก
- comment ใน script และไฟล์ config มีบรรทัด `EN:` (ภาษาอังกฤษ) อยู่เหนือ comment ภาษาไทย ส่วนข้อความที่ script แสดงผลและ description ของ rule เป็นภาษาไทยตรงกับในหนังสือ
- diagram ภาษาไทย (ชุดที่ใช้ในหนังสือ) อยู่ที่ `assets/diagrams/chNN/` และชุดภาษาอังกฤษอยู่ที่ `assets/diagrams/chNN/en/`
- เครื่องมือดูแลสองภาษาอยู่ที่ [`tools/i18n/`](tools/i18n/README.th.md)

## โครงสร้าง

| Path | เนื้อหา |
| --- | --- |
| `lab-hosts.csv` | IP, VM ID, ขนาดของทุกเครื่อง (script ทุกตัวอ่านจากไฟล์นี้) |
| `docs/` | โครงเล่ม ([book-outline.th.md](docs/book-outline.th.md)), แผนเรียน 60 วัน ([study-plan.th.md](docs/study-plan.th.md)), ผลตรวจหัวข้อ ([topic-verification.th.md](docs/topic-verification.th.md)) และข้อตกลงในเล่ม ([chapter-template.th.md](docs/chapter-template.th.md)) |
| `chNN-*/` | ไฟล์ Lab ของแต่ละบท แยกตามเครื่องที่รัน: `windows/`, `proxmox/`, `guest/` และ config ใน `files/` |
| `assets/diagrams/` | ต้นฉบับ SVG และ PNG ของ diagram ในหนังสือ (`en/` = ภาษาอังกฤษ) |
| `tools/` | script ฝั่ง Windows ที่ใช้หลายบท (`tools/windows/`) และเครื่องมือดูแลสองภาษา (`tools/i18n/`) |
| `infra/azure-terraform/` | Terraform สร้าง lab บน Azure |

## สารบัญ

| ภาค | บท | Folder | ชื่อบท | Lab ในหลักสูตร |
| --- | --- | --- | --- | --- |
| 0 เตรียมห้องแลป | 1 | [ch01-lab-platform](ch01-lab-platform/README.th.md) | สร้างห้องแลป: Proxmox VE บน Hyper-V และ Rocky Linux 10 | 1, 7 |
| 1 พื้นฐานระบบและเครือข่าย | 2 | [ch02-network-ssh-hostname](ch02-network-ssh-hostname/README.th.md) | Network, SSH และ Hostname | 2, 3, 5 |
| | 3 | [ch03-kernel-time-ntp](ch03-kernel-time-ntp/README.th.md) | Kernel, เวอร์ชันระบบ, Timezone และ NTP | 4, 6, 7 |
| | 4 | [ch04-selinux-systemd](ch04-selinux-systemd/README.th.md) | SELinux และ systemd | 8 |
| 2 คำสั่งและตัวตน | 5 | [ch05-command-line](ch05-command-line/README.th.md) | Command Line ที่ SOC ต้องใช้ทุกวัน | 9.1–9.15 |
| | 6 | [ch06-users-groups](ch06-users-groups/README.th.md) | ผู้ใช้ กลุ่ม และนโยบายรหัสผ่าน | 10.1–10.13 |
| | 7 | [ch07-freeipa](ch07-freeipa/README.th.md) | Centralized Identity ด้วย FreeIPA | 11 |
| | 8 | [ch08-ssh-hardening](ch08-ssh-hardening/README.th.md) | SSH Hardening: Key Authentication และ Session Limit | 12, 13 |
| 3 ป้องกันภัยคุกคามเบื้องต้น | 9 | [ch09-crowdsec](ch09-crowdsec/README.th.md) | CrowdSec: Ban Brute-force และบล็อก Tor/Proxy | 14, 15 |
| 4 SIEM ด้วย Graylog | 10 | [ch10-graylog-install](ch10-graylog-install/README.th.md) | ติดตั้ง Graylog และเปิดใช้อย่างปลอดภัย | 16 |
| | 11 | [ch11-graylog-ingest](ch11-graylog-ingest/README.th.md) | รับ Log: Inputs, rsyslog, Streams และ Pipeline | 16 |
| | 12 | [ch12-graylog-search](ch12-graylog-search/README.th.md) | การค้นหาและสืบสวนใน Graylog | 17 |
| | 13 | [ch13-threat-intel](ch13-threat-intel/README.th.md) | Threat Intelligence: CrowdSec, GeoIP และ Global Dashboard | 18, 19, 20 |
| 5 Wazuh: ตรวจจับและตอบสนอง | 14 | [ch14-wazuh-install](ch14-wazuh-install/README.th.md) | ติดตั้ง Wazuh, Agent และ Agent Group | 21, 34 |
| | 15 | [ch15-wazuh-rules](ch15-wazuh-rules/README.th.md) | Rule, Tuning และ Active Response | 21 |
| | 16 | [ch16-fim-identity](ch16-fim-identity/README.th.md) | File Integrity และ Identity Monitoring | 22 |
| | 17 | [ch17-auditd](ch17-auditd/README.th.md) | Linux Audit (auditd) สำหรับการสืบสวน | 23 |
| 6 Container และ eBPF | 18 | [ch18-docker-security](ch18-docker-security/README.th.md) | Docker Runtime Security | 24 |
| | 19 | [ch19-tetragon](ch19-tetragon/README.th.md) | Tetragon: มองเห็นและหยุดภัยระดับ Kernel | 33, 35, 36, 37 |
| 7 SOC Operations ขั้นสูง | 20 | [ch20-soc-access](ch20-soc-access/README.th.md) | SOC Analyst Access และ Sudo Violation Dashboard | 25, 26 |
| | 21 | [ch21-git-tracking](ch21-git-tracking/README.th.md) | ติดตามและบล็อกคำสั่ง Git แบบ Real-time | 27 |
| | 22 | [ch22-web-logging](ch22-web-logging/README.th.md) | Application และ Web Logging: Nginx, WordPress, Redis และ WAF | 28, 29, 30, 31, 32 |
| 8 แจ้งเตือนและปรับแต่ง | 23 | [ch23-alerting](ch23-alerting/README.th.md) | Alert ไป LINE, Telegram และ Gmail; ปรับ Port ของ Wazuh | 38, 39, 40 |
| 9 ตรวจสอบความพร้อมของการตรวจจับ | 24 | [ch24-detection-validation](ch24-detection-validation/README.th.md) | ทดสอบการโจมตีในห้องแลปเพื่อศึกษาการป้องกัน (detection validation) | บทสรุป |

รายละเอียดของแต่ละบท เครื่องที่ใช้ และ snapshot อยู่ใน [docs/book-outline.th.md](docs/book-outline.th.md)

## ข้อควรระวัง

- Lab นี้มีการจำลองการโจมตี (brute-force, web shell, container escape) ด้วยเครื่องมือและข้อมูลที่ไม่เป็นอันตราย ทำเฉพาะใน network ของ lab เท่านั้น
- ไม่มี password หรือ token ใน repo script ที่ต้องใช้ความลับจะถามตอนรัน
- `*.sh` ต้องเป็น LF เสมอ (`.gitattributes` จัดการให้เมื่อ clone ด้วย git) ถ้าแก้ไฟล์บน Windows ให้ใช้ editor ที่เลือก LF ได้ เช่น VS Code
