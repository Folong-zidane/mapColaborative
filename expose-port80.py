#!/usr/bin/env python3
"""
Exposition sur port 80 (standard HTTP) pour éviter les blocages FAI
"""
import http.server
import socketserver
import urllib.request
import urllib.parse
from urllib.error import URLError
import sys

PORT = 80  # Port standard HTTP
TARGET_URL = "http://localhost:8080"

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # Construire l'URL cible
            target = f"{TARGET_URL}{self.path}"
            
            # Faire la requête vers le serveur local
            req = urllib.request.Request(target)
            
            # Copier les headers importants
            for header in ['User-Agent', 'Accept', 'Accept-Language']:
                if header in self.headers:
                    req.add_header(header, self.headers[header])
            
            # Faire la requête
            with urllib.request.urlopen(req) as response:
                # Copier le status code
                self.send_response(response.getcode())
                
                # Copier les headers de réponse
                for header, value in response.headers.items():
                    if header.lower() not in ['connection', 'transfer-encoding']:
                        self.send_header(header, value)
                
                # Headers CORS
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                
                self.end_headers()
                
                # Copier le contenu
                self.wfile.write(response.read())
                
        except URLError as e:
            self.send_error(502, f"Serveur local non accessible: {e}")
        except Exception as e:
            self.send_error(500, f"Erreur proxy: {e}")
    
    def do_OPTIONS(self):
        # Gérer les requêtes CORS preflight
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

if __name__ == "__main__":
    print(f"🌐 Proxy OSM sur port {PORT} (HTTP standard)")
    print(f"🎯 Cible: {TARGET_URL}")
    print(f"📱 Accès externe: http://165.211.32.25")
    print("⚠️  ATTENTION: Nécessite les droits root pour le port 80")
    print("🔄 Ctrl+C pour arrêter")
    
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), ProxyHandler) as httpd:
            httpd.serve_forever()
    except PermissionError:
        print("❌ Erreur: Port 80 nécessite les droits root")
        print("💡 Lancez avec: sudo python3 expose-port80.py")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n🛑 Proxy arrêté")
    except Exception as e:
        print(f"❌ Erreur: {e}")
        sys.exit(1)