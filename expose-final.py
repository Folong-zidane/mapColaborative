#!/usr/bin/env python3
"""
Solution finale : Serveur avec toutes les fonctionnalités
"""
import http.server
import socketserver
import urllib.request
import json
import subprocess
import threading
import time

PORT = 8000

class FinalHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/tile/'):
            # Proxy vers le serveur de tuiles
            self.proxy_request('http://localhost:8080')
        elif self.path == '/' or self.path == '/index.html':
            # Servir la page web
            self.serve_web_page()
        elif self.path == '/status':
            # Status du serveur
            self.serve_status()
        else:
            self.send_error(404)
    
    def proxy_request(self, target_url):
        try:
            url = f"{target_url}{self.path}"
            req = urllib.request.Request(url)
            
            with urllib.request.urlopen(req) as response:
                self.send_response(response.getcode())
                
                for header, value in response.headers.items():
                    if header.lower() not in ['connection', 'transfer-encoding']:
                        self.send_header(header, value)
                
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(response.read())
                
        except Exception as e:
            self.send_error(502, f"Erreur proxy: {e}")
    
    def serve_web_page(self):
        try:
            with open('web/index.html', 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Remplacer localhost par l'URL actuelle
            content = content.replace('http://localhost:8080', '')
            
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(content.encode('utf-8'))
            
        except FileNotFoundError:
            self.send_error(404, "Page non trouvée")
    
    def serve_status(self):
        status = {
            "service": "OSM Cameroun",
            "port": PORT,
            "status": "running",
            "tiles": "http://localhost:8080",
            "access": f"http://165.211.32.25:{PORT}"
        }
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(status, indent=2).encode())

def start_ngrok():
    """Démarre ngrok en arrière-plan"""
    try:
        print("🚀 Démarrage ngrok...")
        subprocess.Popen(['./ngrok', 'http', str(PORT)], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL)
        time.sleep(3)
        print("✅ ngrok démarré - vérifiez http://localhost:4040 pour l'URL publique")
    except:
        print("⚠️  ngrok non disponible")

if __name__ == "__main__":
    print(f"🗺️ Serveur OSM Cameroun FINAL")
    print(f"🌐 Local: http://localhost:{PORT}")
    print(f"🌍 Public: http://165.211.32.25:{PORT}")
    print(f"📊 Status: http://localhost:{PORT}/status")
    
    # Démarrer ngrok si disponible
    threading.Thread(target=start_ngrok, daemon=True).start()
    
    with socketserver.TCPServer(("0.0.0.0", PORT), FinalHandler) as httpd:
        httpd.serve_forever()