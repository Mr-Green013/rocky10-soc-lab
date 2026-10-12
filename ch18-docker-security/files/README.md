# ไฟล์ config ของบทที่ 18

สำเนาของไฟล์ที่บทที่ 18 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้)

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/docker/daemon.json` | `/etc/docker/daemon.json` | |
| `files/etc/audit/rules.d/27-container-runtime.rules` | `/etc/audit/rules.d/27-container-runtime.rules` | |
| `files/usr/local/sbin/docker-sock-check.sh` | `/usr/local/sbin/docker-sock-check.sh` | |
| `files/var/ossec/active-response/bin/container-response.sh` | `/var/ossec/active-response/bin/container-response.sh` | |
| `files/etc/falco/config.d/10-lab.yaml` | `/etc/falco/config.d/10-lab.yaml` | |
| `files/etc/logrotate.d/falco` | `/etc/logrotate.d/falco` | |
| `files/etc/falco/rules.d/lab_rules.yaml` | `/etc/falco/rules.d/lab_rules.yaml` | |
| `files/etc/logrotate.d/web-01` | `/etc/logrotate.d/web-01` | |
