#!/bin/bash
"""
Configuration Cloudflare Tunnel pour exposition sécurisée
Alternative gratuite à la redirection de ports
"""

echo "🌐 Configuration Cloudflare Tunnel"
echo "=================================="
#cloudflared tunnel --url http://localhost:8080

# Vérifier si cloudflared est installé
if ! command -v cloudflared &> /dev/null; then
    echo "📦 Installation de cloudflared..."
    
    # Télécharger cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
    
    echo "✅ cloudflared installé"
fi

echo ""
echo "🔧 Configuration du tunnel:"
echo "1. Créez un compte sur https://dash.cloudflare.com"
echo "2. Allez dans Zero Trust > Access > Tunnels"
echo "3. Créez un nouveau tunnel"
echo "4. Copiez le token de connexion"
echo ""
echo "🚀 Commandes pour démarrer le tunnel:"
echo ""
echo "# Pour le port 8080 (serveur principal):"
echo "cloudflared tunnel --url http://localhost:8080"
echo ""
echo "# Pour le port 9999 (proxy):"
echo "cloudflared tunnel --url http://localhost:9999"
echo ""
echo "📱 Avantages Cloudflare Tunnel:"
echo "- ✅ Gratuit"
echo "- ✅ HTTPS automatique"
echo "- ✅ Pas de configuration routeur"
echo "- ✅ Protection DDoS"
echo "- ✅ URL personnalisée possible"
echo ""
echo "🔗 Votre service sera accessible via une URL comme:"
echo "https://random-name.trycloudflare.com"