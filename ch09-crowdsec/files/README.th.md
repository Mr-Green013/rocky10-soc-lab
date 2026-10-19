[English](README.md) · **ภาษาไทย**

# ไฟล์ config ของบทที่ 9

สำเนาของไฟล์ที่บทที่ 9 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้) บรรทัด comment ที่ขึ้นต้นด้วย `EN:` คือคำแปลภาษาอังกฤษของ comment ภาษาไทยบรรทัดถัดไป ไม่มีผลต่อการทำงานของไฟล์

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/ssh/sshd_config.d/00-lab-password.conf` | `/etc/ssh/sshd_config.d/00-lab-password.conf` | |
| `files/etc/crowdsec/parsers/s02-enrich/00-lab-admin-whitelist.yaml` | `/etc/crowdsec/parsers/s02-enrich/00-lab-admin-whitelist.yaml` | |
| `files/usr/local/sbin/crowdsec-tor-import.sh` | `/usr/local/sbin/crowdsec-tor-import.sh` | |
| `files/etc/systemd/system/crowdsec-tor-import.service` | `/etc/systemd/system/crowdsec-tor-import.service` | |
| `files/etc/systemd/system/crowdsec-tor-import.timer` | `/etc/systemd/system/crowdsec-tor-import.timer` | |
