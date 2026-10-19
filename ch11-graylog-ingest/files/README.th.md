[English](README.md) · **ภาษาไทย**

# ไฟล์ config ของบทที่ 11

สำเนาของไฟล์ที่บทที่ 11 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้) บรรทัด comment ที่ขึ้นต้นด้วย `EN:` คือคำแปลภาษาอังกฤษของ comment ภาษาไทยบรรทัดถัดไป ไม่มีผลต่อการทำงานของไฟล์

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/systemd/system/docker-user-lab.service` | `/etc/systemd/system/docker-user-lab.service` | |
| `files/etc/rsyslog.d/90-graylog.conf` | `/etc/rsyslog.d/90-graylog.conf` | |
| `files/etc/rsyslog.d/10-audit-local.conf` | `/etc/rsyslog.d/10-audit-local.conf` | |
| `files/graylog/SOC-SSH-pipeline.rules` | Graylog Web UI (System → Pipelines → Manage rules) คัดลอกวาง | ไฟล์สมบูรณ์หลังจบบท |
