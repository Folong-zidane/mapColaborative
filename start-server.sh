#!/bin/bash
# Script de lancement robuste du serveur OSM

echo "🚀 Démarrage serveur OSM Cameroun"
echo "================================="

# Vérifier les dépendances Python
echo "📦 Vérification des dépendances..."
python3 -c "import PIL" 2>/dev/null || {
    echo "❌ PIL manquant. Installation..."
    pip3 install Pillow
}

# Arrêter les processus existants sur le port 8080
echo "🔄 Nettoyage des processus existants..."
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

# Vérifier que le dossier web existe
if [ ! -f "web/index.html" ]; then
    echo "❌ Fichier web/index.html manquant"
    exit 1
fi

echo "✅ Prêt à démarrer"
echo ""
echo "🌐 URLs d'accès :"
echo "  - Local: http://localhost:8080"
echo "  - Réseau: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "🎯 Endpoints :"
echo "  - Interface: http://localhost:8080/"
echo "  - Tuiles: http://localhost:8080/tile/{z}/{x}/{y}.png"
echo ""
echo "🔄 Ctrl+C pour arrêter"
echo ""

# Démarrer le serveur
python3 hybrid-server.py

#cloudflared tunnel --url http://localhost:8080