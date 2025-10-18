#!/bin/bash
# Script de configuration Cloudflare Tunnel

set -e

echo "🌐 Configuration Cloudflare Tunnel pour serveur OSM local"

# Vérifier si cloudflared est installé
if ! command -v cloudflared &> /dev/null; then
    echo "📥 Installation de cloudflared..."
    
    # Détecter l'architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
    else
        echo "❌ Architecture non supportée: $ARCH"
        exit 1
    fi
    
    wget $CLOUDFLARED_URL -O cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
fi

echo "✅ cloudflared installé"

# Authentification
echo "🔐 Authentification avec Cloudflare..."
echo "Une page web va s'ouvrir pour vous connecter à Cloudflare"
cloudflared tunnel login

# Demander le nom du tunnel
read -p "📝 Nom de votre tunnel (ex: osm-cameroun): " TUNNEL_NAME
read -p "🌐 Votre domaine (ex: osm.monsite.com): " DOMAIN_NAME

# Créer le tunnel
echo "🚇 Création du tunnel..."
TUNNEL_ID=$(cloudflared tunnel create $TUNNEL_NAME | grep -o '[a-f0-9-]\{36\}')

echo "✅ Tunnel créé avec l'ID: $TUNNEL_ID"

# Créer la configuration
echo "⚙️ Création de la configuration..."
mkdir -p ~/.cloudflared

cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN_NAME
    service: http://localhost:80
  - service: http_status:404
EOF

# Créer l'enregistrement DNS
echo "🌐 Création de l'enregistrement DNS..."
cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN_NAME

# Créer le service systemd
echo "🔧 Configuration du service..."
sudo cloudflared service install
sudo systemctl enable cloudflared

# Créer un script de démarrage
cat > start-tunnel.sh << EOF
#!/bin/bash
echo "🚇 Démarrage du tunnel Cloudflare..."
cloudflared tunnel run $TUNNEL_NAME
EOF

chmod +x start-tunnel.sh

echo "✅ Configuration terminée!"
echo ""
echo "🎯 Votre serveur OSM sera accessible sur : https://$DOMAIN_NAME"
echo ""
echo "📋 Commandes utiles :"
echo "  Démarrer le tunnel : ./start-tunnel.sh"
echo "  Démarrer comme service : sudo systemctl start cloudflared"
echo "  Voir les logs : sudo journalctl -u cloudflared -f"
echo "  Arrêter le service : sudo systemctl stop cloudflared"