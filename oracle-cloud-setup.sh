#!/bin/bash
# Script d'installation automatique pour Oracle Cloud

set -e

echo "🚀 Configuration automatique Oracle Cloud pour serveur OSM"

# Mise à jour du système
echo "📦 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

# Installation Docker
echo "🐳 Installation de Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installation Docker Compose
echo "📦 Installation de Docker Compose..."
sudo apt install -y docker-compose

# Configuration du pare-feu
echo "🔥 Configuration du pare-feu..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

# Création des dossiers
echo "📁 Création des dossiers..."
mkdir -p ~/osm-server/data
cd ~/osm-server

# Téléchargement du style de carte
echo "🎨 Téléchargement du style OpenStreetMap..."
git clone https://github.com/gravitystorm/openstreetmap-carto.git

# Téléchargement des données du Cameroun
echo "📥 Téléchargement des données OSM du Cameroun..."
wget -P data/ http://download.geofabrik.de/africa/cameroon-latest.osm.pbf

echo "✅ Configuration terminée!"
echo ""
echo "🎯 Prochaines étapes :"
echo "1. Copiez vos fichiers Docker dans ~/osm-server/"
echo "2. Lancez : docker-compose up -d"
echo "3. Importez : docker-compose exec tileserver import-osm.sh /data/osm/cameroon-latest.osm.pbf"
echo "4. Accédez à : http://$(curl -s ifconfig.me)/map"