#!/usr/bin/env python3
"""orders-api: แอปตัวอย่างที่ส่ง structured log แบบ GELF (UDP) ไป Graylog โดยไม่ใช้ library ภายนอก"""
import json, os, random, socket, time, uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

GELF_HOST = os.environ.get("GELF_HOST", "192.168.10.20")
GELF_PORT = int(os.environ.get("GELF_PORT", "12201"))
APP = os.environ.get("APP_NAME", "orders-api")
ENV = os.environ.get("APP_ENV", "lab")
SOCK = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
LEVELS = {"error": 3, "warning": 4, "info": 6, "debug": 7}   # syslog severity


def log(level, message, **fields):
    """ส่ง GELF 1.1 หนึ่งข้อความ field เพิ่มเติมต้องขึ้นต้นด้วย _"""
    doc = {
        "version": "1.1",
        "host": socket.gethostname(),
        "short_message": message,
        "timestamp": round(time.time(), 3),
        "level": LEVELS[level],
        "_app": APP,
        "_env": ENV,
    }
    doc.update({f"_{k}": v for k, v in fields.items() if v is not None})
    try:
        SOCK.sendto(json.dumps(doc).encode("utf-8"), (GELF_HOST, GELF_PORT))
    except OSError:
        pass                      # การ log ต้องไม่ทำให้แอปล้ม


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        start = time.monotonic()
        rid = uuid.uuid4().hex[:12]
        user = self.headers.get("X-User", "anonymous")
        if self.path.startswith("/orders"):
            status, body = 200, {"orders": random.randint(0, 5)}
        elif self.path.startswith("/fail"):
            status, body = 500, {"error": "database timeout"}
        else:
            status, body = 404, {"error": "not found"}
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)
        took = round((time.monotonic() - start) * 1000, 2)
        level = "error" if status >= 500 else "warning" if status >= 400 else "info"
        log(level, f"{self.command} {self.path} -> {status}",
            request_id=rid, user=user, http_method=self.command, http_path=self.path,
            http_status=status, took_ms=took, client_ip=self.client_address[0])

    def log_message(self, *args):   # ปิด log แบบ text ของ http.server
        pass


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8090"))
    log("info", f"{APP} started", port=port)
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
