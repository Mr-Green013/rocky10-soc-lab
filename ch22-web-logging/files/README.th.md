[English](README.md) · **ภาษาไทย**

# ไฟล์ config ของบทที่ 22

สำเนาของไฟล์ที่บทที่ 22 สร้างด้วย `sudo tee FILE <<'EOF'` จัดตาม path จริงบนเครื่อง ใช้เทียบเมื่อพิมพ์ผิด หรือคัดลอกไปวางแทนการพิมพ์ (ตรวจค่าเฉพาะเครื่อง เช่น IP และชื่อโดเมนก่อนใช้) บรรทัด comment ที่ขึ้นต้นด้วย `EN:` คือคำแปลภาษาอังกฤษของ comment ภาษาไทยบรรทัดถัดไป ไม่มีผลต่อการทำงานของไฟล์

| ไฟล์ใน repo | ตำแหน่งบนเครื่อง | หมายเหตุ |
| --- | --- | --- |
| `files/opt/orders-api/orders_api.py` | `/opt/orders-api/orders_api.py` | |
| `files/etc/systemd/system/orders-api.service` | `/etc/systemd/system/orders-api.service` | |
| `files/etc/rsyslog.d/91-legacy-app.conf` | `/etc/rsyslog.d/91-legacy-app.conf` | |
| `files/opt/wordpress/compose.yaml` | `/opt/wordpress/compose.yaml` | |
| `files/opt/wordpress/nginx/default.conf` | `/opt/wordpress/nginx/default.conf` | |
| `files/etc/logrotate.d/wp-nginx` | `/etc/logrotate.d/wp-nginx` | |
| `files/opt/wordpress/waf/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf` | `/opt/wordpress/waf/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf` | |
