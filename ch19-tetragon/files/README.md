# ไฟล์ config ของบทที่ 19

สำเนาของไฟล์ที่บทที่ 19 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้)

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/usr/local/sbin/acct-activity.sh` | `/usr/local/sbin/acct-activity.sh` | |
| `files/etc/tetragon/tetragon.tp.d/10-block-tmp-exec.yaml` | `/etc/tetragon/tetragon.tp.d/10-block-tmp-exec.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/20-guillotine.yaml` | `/etc/tetragon/tetragon.tp.d/20-guillotine.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/30-protect-shadow.yaml` | `/etc/tetragon/tetragon.tp.d/30-protect-shadow.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/40-keyguard.yaml` | `/etc/tetragon/tetragon.tp.d/40-keyguard.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/50-suid-guard.yaml` | `/etc/tetragon/tetragon.tp.d/50-suid-guard.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/60-sensitive-files.yaml` | `/etc/tetragon/tetragon.tp.d/60-sensitive-files.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/70-account-tracker.yaml` | `/etc/tetragon/tetragon.tp.d/70-account-tracker.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/80-egress-private-only.yaml` | `/etc/tetragon/tetragon.tp.d/80-egress-private-only.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/etc/tetragon/tetragon.tp.d/81-connect-audit.yaml` | `/etc/tetragon/tetragon.tp.d/81-connect-audit.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/rules/160-container_rules.tetragon-snippet.xml` | `/var/ossec/etc/rules/160-container_rules.tetragon-snippet.xml` | ไฟล์สมบูรณ์หลังจบบท |
