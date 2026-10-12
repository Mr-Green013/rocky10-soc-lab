# บทที่ 9 CrowdSec: Ban Brute-force และบล็อก Tor/Proxy

Lab ในหลักสูตร: 14, 15

ติดตั้ง CrowdSec, acquisition และ scenario ของ sshd, firewall bouncer, ทดสอบ brute-force จำลองจาก lab-linux-02 และบล็อก Tor exit node และ anonymous proxy ด้วย blocklist

สิ่งที่ได้เมื่อจบบท:

- IP ที่ brute-force ถูก ban อัตโนมัติ
- จัดการ decision และ allowlist ได้

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch09-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
