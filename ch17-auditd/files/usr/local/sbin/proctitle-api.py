#!/usr/bin/env python3
"""Decode hex-encoded auditd proctitle values for Graylog lookup tables."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs
import json
import re

HEX = re.compile(r'^[0-9A-Fa-f]{2,8192}$')


def decode(value):
    value = value.strip('"')
    if len(value) % 2 or not HEX.match(value):
        return value                      # already plain text
    raw = bytes.fromhex(value).replace(b'\x00', b' ')
    return raw.decode('utf-8', errors='replace').strip()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        if url.path != '/decode':
            self.send_error(404)
            return
        value = parse_qs(url.query).get('hex', [''])[0]
        body = json.dumps({'decoded': decode(value)}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == '__main__':
    ThreadingHTTPServer(('0.0.0.0', 8085), Handler).serve_forever()
