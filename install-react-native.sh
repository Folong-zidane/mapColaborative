#!/bin/bash
# Script d'installation automatique pour React Native

echo "📱 Installation React Native Maps - OSM Cameroun"
echo "================================================"

# Vérifier si on est dans un projet React Native
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté dans un projet React Native"
    echo "💡 Créez d'abord votre projet: npx react-native init MonProjet"
    exit 1
fi

echo "📦 Installation des dépendances..."
npm install react-native-maps

# Configuration Android
echo "🤖 Configuration Android..."
mkdir -p android/app/src/main/res/xml

# Créer network_security_config.xml
cat > android/app/src/main/res/xml/network_security_config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">165.211.32.25</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
EOF

# Modifier AndroidManifest.xml
echo "📝 Modification AndroidManifest.xml..."
if ! grep -q "networkSecurityConfig" android/app/src/main/AndroidManifest.xml; then
    sed -i 's/android:theme="@style\/AppTheme"/android:theme="@style\/AppTheme"\n        android:usesCleartextTraffic="true"\n        android:networkSecurityConfig="@xml\/network_security_config"/' android/app/src/main/AndroidManifest.xml
fi

# Copier le composant OSM
echo "🗺️ Installation du composant OSM..."
mkdir -p components
cp OSMMapFinal.tsx components/ 2>/dev/null || echo "⚠️  Copiez manuellement OSMMapFinal.tsx dans components/"

# Configuration iOS
if [ -d "ios" ]; then
    echo "🍎 Configuration iOS..."
    cd ios && pod install && cd ..
fi

echo ""
echo "✅ Installation terminée !"
echo ""
echo "🚀 Utilisation :"
echo "import OSMMapFinal from './components/OSMMapFinal';"
echo ""
echo "<OSMMapFinal />"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Démarrez votre serveur OSM : python3 hybrid-server.py"
echo "2. Lancez votre app : npx react-native run-android"
echo "3. Testez la carte du Cameroun !"
echo ""
echo "📖 Documentation complète : INTEGRATION-REACT-NATIVE-FINAL.md"