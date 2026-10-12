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

1. อ่านบทที่ 1 ในหนังสือ หรือ [`ch01-lab-platform/README.md`](ch01-lab-platform/README.md) สำหรับลำดับคำสั่งแบบย่อ
2. Clone repo นี้ไว้บน Windows (`git clone` หรือ Download ZIP) แล้วคัดลอกไปที่ pve-01 ในขั้นที่ 5 ของบทที่ 1
3. ทำตามบทตามลำดับ จบบทที่มี snapshot ให้รัน `pve-snapshot.sh <ชื่อ>` เพื่อมีจุดกลับ

ไม่มีเครื่อง Windows ที่แรงพอ: ใช้ [`infra/azure-terraform`](infra/azure-terraform/README.md) สร้าง lab เดียวกันบน Azure (ภาคผนวก ก)

## โครงสร้าง

| Path | เนื้อหา |
| --- | --- |
| `lab-hosts.csv` | IP, VM ID, ขนาดของทุกเครื่อง (script ทุกตัวอ่านจากไฟล์นี้) |
| `docs/` | โครงเล่ม, แผนเรียน 60 วัน ([study-plan.md](docs/study-plan.md)), ผลตรวจหัวข้อ ([topic-verification.md](docs/topic-verification.md)) และข้อตกลงในเล่ม |
| `chNN-*/` | ไฟล์ Lab ของแต่ละบท แยกตามเครื่องที่รัน: `windows/`, `proxmox/`, `guest/` |
| `assets/diagrams/chNN/` | ต้นฉบับ SVG ของ diagram ในหนังสือ |
| `infra/azure-terraform/` | Terraform สร้าง lab บน Azure |

## สารบัญ

| บท | Folder | Lab ในหลักสูตร |
| --- | --- | --- |
| 1 | [ch01-lab-platform](ch01-lab-platform/) | 1, 7 |
| 2–23 | ดู [docs/book-outline.md](docs/book-outline.md) | 2–40 |

## ข้อควรระวัง

- Lab นี้มีการจำลองการโจมตี (brute-force, web shell, container escape) ด้วยเครื่องมือและข้อมูลที่ไม่เป็นอันตราย ทำเฉพาะใน network ของ lab เท่านั้น
- ไม่มี password หรือ token ใน repo script ที่ต้องใช้ความลับจะถามตอนรัน
- `*.sh` ต้องเป็น LF เสมอ (`.gitattributes` จัดการให้เมื่อ clone ด้วย git) ถ้าแก้ไฟล์บน Windows ให้ใช้ editor ที่เลือก LF ได้ เช่น VS Code
