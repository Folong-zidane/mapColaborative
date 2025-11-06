#!/usr/bin/env python3
"""
Solution directe : Serveur web simple sur port 80
"""
import http.server
import socketserver
import os

PORT = 8000  # Port alternatif si 80 bloqué

class SimpleHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="web", **kwargs)
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

if __name__ == "__main__":
    print(f"🌐 Serveur direct sur port {PORT}")
    print(f"📱 Accès: http://165.211.32.25:{PORT}")
    print("🔄 Ctrl+C pour arrêter")
    
    with socketserver.TCPServer(("0.0.0.0", PORT), SimpleHandler) as httpd:
        httpd.serve_forever()