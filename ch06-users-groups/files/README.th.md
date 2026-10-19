[English](README.md) · **ภาษาไทย**

# ไฟล์ config ของบทที่ 6

สำเนาของไฟล์ที่บทที่ 6 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้) บรรทัด comment ที่ขึ้นต้นด้วย `EN:` คือคำแปลภาษาอังกฤษของ comment ภาษาไทยบรรทัดถัดไป ไม่มีผลต่อการทำงานของไฟล์

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/etc/security/pwhistory.conf` | `/etc/security/pwhistory.conf` | |
| `files/etc/security/pwquality.conf.d/10-lab.conf` | `/etc/security/pwquality.conf.d/10-lab.conf` | |
| `files/etc/security/faillock.conf` | `/etc/security/faillock.conf` | ไฟล์สมบูรณ์หลังจบบท |
