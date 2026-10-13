# Detection coverage — บทที่ 24

กรอกหลังจำลองสัญญาณของแต่ละ CVE (benign เท่านั้น) บันทึกเวลาและ rule ที่ยิง
ใช้วัดว่าระบบ "เห็นอะไร" ไม่ใช่ว่า "มี rule กี่ตัว"

| CVE            | สัญญาณที่จำลอง                     | ชั้นที่เห็น (net/host/kernel) | rule/alert ที่ยิง | เวลา (ถึง alert) | ตรวจเจอ | หมายเหตุ / ช่องว่าง |
| -------------- | --------------------------------- | ----------------------------- | ----------------- | ---------------- | ------- | ------------------- |
| CVE-2021-44228 | egress ออกนอก private (ebpf-01)   |                               |                   |                  |         |                     |
| CVE-2017-5638  | รันเครื่องมือ network ใน container |                               |                   |                  |         |                     |
| CVE-2014-6271  | web → bash (Lab 29)               |                               |                   |                  |         |                     |
| CVE-2024-6387  | SSH ล้มเหลวซ้ำจาก lab-linux-02    |                               |                   |                  |         |                     |
| CVE-2021-4034  | pkexec execve + SUID ใหม่         |                               |                   |                  |         |                     |
| CVE-2024-3094  | แก้ไฟล์ของระบบที่เฝ้าไว้           |                               |                   |                  |         |                     |

## OWASP Top 10 (2021)

| หมวด | สัญญาณ/วิธีทดสอบ (benign)          | ตัวตรวจจับ | ตรวจเจอ | หมายเหตุ |
| ---- | --------------------------------- | ---------- | ------- | -------- |
| A01 Broken Access Control | curl /wp-admin จาก lab-linux-02 |            |         |          |
| A02 Cryptographic Failures | FIM บน TLS config               |            |         |          |
| A03 Injection | สตริงทดสอบ CRS ของ Lab 32          |            |         |          |
| A04 Insecure Design | (threat modeling ไม่ใช่ detection) | —          | —       | ปิดด้วยการออกแบบ |
| A05 Security Misconfiguration | FIM test + ตรวจ port           |            |         |          |
| A06 Vulnerable Components | Wazuh vuln / dnf check-update     |            |         |          |
| A07 Auth Failures | brute-force (24.3.5)                |            |         |          |
| A08 Integrity Failures | FIM test บนไฟล์ WordPress         |            |         |          |
| A09 Logging/Monitoring | logger → ยืนยันถึง Graylog         |            |         |          |
| A10 SSRF | egress test (24.3.2)                      |            |         |          |

## สรุป
- ช่องว่างที่ใหญ่ที่สุด (สัญญาณที่ไม่มีชั้นใดเห็น หรือเห็นช้าเกินไป):
- แผนปิดช่องว่าง (rule/policy ที่จะเพิ่ม):
