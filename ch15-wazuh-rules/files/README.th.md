[English](README.md) · **ภาษาไทย**

# ไฟล์ config ของบทที่ 15

สำเนาของไฟล์ที่บทที่ 15 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้) บรรทัด comment ที่ขึ้นต้นด้วย `EN:` คือคำแปลภาษาอังกฤษของ comment ภาษาไทยบรรทัดถัดไป ไม่มีผลต่อการทำงานของไฟล์

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/opt/graylog/lookup/assets.csv` | `/opt/graylog/lookup/assets.csv` | |
| `files/var/ossec/etc/rules/100-tuning_rules.xml` | `/var/ossec/etc/rules/100-tuning_rules.xml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/rules/110-ssh_rules.xml` | `/var/ossec/etc/rules/110-ssh_rules.xml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/rules/120-identity_rules.xml` | `/var/ossec/etc/rules/120-identity_rules.xml` | ไฟล์สมบูรณ์หลังจบบท |
| `files/var/ossec/etc/rules/150-response_rules.xml` | `/var/ossec/etc/rules/150-response_rules.xml` | ไฟล์สมบูรณ์หลังจบบท |
