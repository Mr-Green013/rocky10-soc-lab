# บทที่ 9 CrowdSec: Ban Brute-force และบล็อก Tor/Proxy

Lab ในหลักสูตร: 14, 15

ติดตั้ง CrowdSec, acquisition และ scenario ของ sshd, firewall bouncer, ทดสอบ brute-force จำลองจาก lab-linux-02 และบล็อก Tor exit node และ anonymous proxy ด้วย blocklist

สิ่งที่ได้เมื่อจบบท:

- IP ที่ brute-force ถูก ban อัตโนมัติ
- จัดการ decision และ allowlist ได้

สถานะ: กำลังเขียน ไฟล์ Lab ของบทนี้จะเพิ่มเมื่อทดสอบบนเครื่องจริงแล้ว

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
