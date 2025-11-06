#!/usr/bin/env python3
"""
Serveur hybride : Interface web + Tuiles personnalisées
"""
import http.server
import socketserver
import urllib.parse
import io
from PIL import Image, ImageDraw
import os

PORT = 8080

class HybridHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path.strip('/')
        parts = path.split('/')
        
        # Route pour les tuiles personnalisées
        if len(parts) == 4 and parts[0] == 'tile' and parts[3].endswith('.png'):
            try:
                z = int(parts[1])
                x = int(parts[2])  
                y = int(parts[3].replace('.png', ''))
                self.serve_custom_tile(z, x, y)
                print(f"🎨 Tuile personnalisée générée: {z}/{x}/{y}")
            except:
                self.send_error(400, "Invalid tile")
        
        # Interface web
        elif path == '' or path == 'index.html':
            self.serve_html_from_file()
        
        else:
            self.send_error(404)
    
    def serve_custom_tile(self, z, x, y):
        """Génère une tuile personnalisée pour le Cameroun"""
        # Créer une tuile 256x256
        img = Image.new('RGB', (256, 256), color='#e8f5e8')
        draw = ImageDraw.Draw(img)
        
        # Vérifier si c'est dans la région du Cameroun
        if self.is_cameroon_region(z, x, y):
            # Tuile du Cameroun - style personnalisé
            draw.rectangle([0, 0, 255, 255], fill='#e8f5e8', outline='#4CAF50', width=2)
            draw.text((10, 10), f"🇨🇲 Cameroun", fill='#2e7d32')
            draw.text((10, 30), f"Zoom: {z}", fill='#666')
            draw.text((10, 50), f"Tuile: {x},{y}", fill='#666')
            
            # Ajouter des détails selon le zoom
            if z >= 7:
                draw.text((10, 70), "Région détaillée", fill='#4CAF50')
            if z >= 10:
                draw.text((10, 90), "Niveau ville", fill='#2196F3')
        else:
            # Hors Cameroun - océan
            draw.rectangle([0, 0, 255, 255], fill='#87ceeb', outline='#1976d2', width=1)
            draw.text((10, 10), "Océan", fill='white')
        
        # Convertir en PNG
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        data = buffer.getvalue()
        
        # Envoyer
        self.send_response(200)
        self.send_header('Content-Type', 'image/png')
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'max-age=3600')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(data)
    
    def is_cameroon_region(self, z, x, y):
        """Vérifie si la tuile couvre le Cameroun"""
        # Conversion approximative des coordonnées de tuile
        n = 2.0 ** z
        lon_deg = x / n * 360.0 - 180.0
        lat_rad = 3.14159 * (1 - 2 * y / n)
        lat_deg = 180.0 / 3.14159 * (2 * (3.14159/4 + lat_rad/2) - 3.14159/2)
        
        # Limites approximatives du Cameroun
        return (8.0 <= lon_deg <= 16.5 and 1.5 <= lat_deg <= 13.0)
    
    def serve_html_from_file(self):
        """Sert l'interface web"""
        try:
            with open('web/index.html', 'r', encoding='utf-8') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(content.encode('utf-8'))
            
        except FileNotFoundError:
            self.send_error(404, "HTML file not found")

if __name__ == "__main__":
    print(f"🗺️ Serveur hybride OSM Cameroun")
    print(f"🌐 Interface: http://localhost:{PORT}")
    print(f"🎨 Tuiles personnalisées: http://localhost:{PORT}/tile/{{z}}/{{x}}/{{y}}.png")
    print(f"📊 Logs des tuiles activés")
    print(f"🔄 Ctrl+C pour arrêter")
    
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), HybridHandler) as httpd:
            print(f"✅ Serveur démarré avec succès !")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Serveur arrêté")
    except Exception as e:
        print(f"❌ Erreur: {e}")