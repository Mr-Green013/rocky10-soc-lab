# ไฟล์ config ของบทที่ 21

สำเนาของไฟล์ที่บทที่ 21 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้)

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/git-guard/hooks/pre-push` | `/etc/git-guard/hooks/pre-push` | |
| `files/etc/tetragon/tetragon.tp.d/85-git-egress.yaml` | `/etc/tetragon/tetragon.tp.d/85-git-egress.yaml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/decoders/ch21-git-guard.snippet.xml` | `/var/ossec/etc/decoders/ch21-git-guard.snippet.xml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/rules/ch21-git-rules.snippet.xml` | `/var/ossec/etc/rules/ch21-git-rules.snippet.xml` | ไฟล์สมบูรณ์หลังจบบท |
