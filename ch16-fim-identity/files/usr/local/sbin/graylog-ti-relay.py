#!/usr/bin/env python3
"""Graylog HTTP notification -> syslog line that a Wazuh rule turns into an Active Response."""
import hmac
import ipaddress
import json
import os
import syslog
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

TOKEN = os.environ['RELAY_TOKEN']
NEVER_BLOCK = [ipaddress.ip_network(n.strip()) for n in
               os.environ.get('NEVER_BLOCK', '127.0.0.0/8,192.168.10.0/24').split(',')]
syslog.openlog('graylog-ti', syslog.LOG_PID, syslog.LOG_AUTHPRIV)


class Handler(BaseHTTPRequestHandler):
    def reply(self, code, text):
        body = text.encode()
        self.send_response(code)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if not hmac.compare_digest(self.headers.get('X-Relay-Token', ''), TOKEN):
            return self.reply(403, 'forbidden')
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length > 65536:
                return self.reply(413, 'too large')
            event = json.loads(self.rfile.read(length))
            ip = ipaddress.ip_address(event['event']['fields']['src_ip'])
        except (ValueError, KeyError, TypeError):
            return self.reply(400, 'bad request')
        if any(ip in net for net in NEVER_BLOCK):
            syslog.syslog(syslog.LOG_NOTICE, f'skip srcip={ip} reason=never-block')
            return self.reply(200, 'skipped')
        syslog.syslog(syslog.LOG_WARNING, f'block srcip={ip} reason=graylog-threat-intel')
        return self.reply(200, 'queued')

    def log_message(self, *args):
        pass


if __name__ == '__main__':
    ThreadingHTTPServer(('0.0.0.0', 8086), Handler).serve_forever()
