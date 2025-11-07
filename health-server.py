#!/usr/bin/env python3
import os
import http.server
import socketserver

PORT = int(os.environ.get('HTTP_PORT', '8080'))

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, format, *args):
        pass  # Suppress logs

with socketserver.TCPServer(("", PORT), HealthHandler) as httpd:
    print(f"Health server listening on port {PORT}")
    httpd.serve_forever()
