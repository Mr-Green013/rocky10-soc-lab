# ไฟล์ config ของบทที่ 8

สำเนาของไฟล์ที่บทที่ 8 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้)

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/ssh/sshd_config.d/01-soclab-auth.conf` | `/etc/ssh/sshd_config.d/01-soclab-auth.conf` | |
| `files/etc/ssh/sshd_config.d/20-session-limit.conf` | `/etc/ssh/sshd_config.d/20-session-limit.conf` | |
| `files/etc/security/limits.d/90-maxlogins.conf` | `/etc/security/limits.d/90-maxlogins.conf` | |
| `files/etc/profile.d/tmout.sh` | `/etc/profile.d/tmout.sh` | |
