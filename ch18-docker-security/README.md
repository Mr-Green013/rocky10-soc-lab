# บทที่ 18 Docker Runtime Security

Lab ในหลักสูตร: 24

จำลองการโจมตี container: terminal hijacking, DoS, data exfiltration ตรวจจับด้วย Falco และ eBPF และป้องกันด้วยการตั้งค่า runtime

สิ่งที่ได้เมื่อจบบท:

- ตรวจจับพฤติกรรมผิดปกติใน container ได้ real-time

สถานะ: เนื้อหาบทเขียนเต็มแล้ว ไฟล์ Lab: `guest/ch18-check.sh` และ config ใน `files/` (ยังต้องยืนยันบนเครื่องจริง)

เริ่มบทนี้จาก snapshot ของบทก่อนหน้า ดู [โครงเล่ม](../docs/book-outline.md)
