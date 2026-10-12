# ไฟล์ config ของบทที่ 16

สำเนาของไฟล์ที่บทที่ 16 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้)

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/audit/rules.d/25-identity.rules` | `/etc/audit/rules.d/25-identity.rules` | |
| `files/var/ossec/etc/shared/linux/agent.conf` | `/var/ossec/etc/shared/linux/agent.conf` | |
| `files/etc/rsyslog.d/20-samba-audit.conf` | `/etc/rsyslog.d/20-samba-audit.conf` | |
| `files/etc/logrotate.d/smbd_audit` | `/etc/logrotate.d/smbd_audit` | |
| `files/usr/local/sbin/graylog-ti-relay.py` | `/usr/local/sbin/graylog-ti-relay.py` | |
| `files/etc/systemd/system/graylog-ti-relay.service` | `/etc/systemd/system/graylog-ti-relay.service` | |
