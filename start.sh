#!/bin/bash
set -e

echo "🚀 Démarrage du serveur de tuiles OSM..."

# Attendre PostgreSQL
echo "⏳ Attente de PostgreSQL..."
until PGPASSWORD=$PGPASSWORD psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c '\q'; do
  echo "PostgreSQL pas encore prêt - attente..."
  sleep 2
done
echo "✅ PostgreSQL prêt!"

# Créer l'interface web
cat > /var/www/html/map.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Serveur OSM - Cameroun</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { margin: 0; padding: 0; }
        #map { height: 100vh; width: 100vw; }
        .info { position: absolute; top: 10px; right: 10px; background: white; padding: 10px; border-radius: 5px; z-index: 1000; }
    </style>
</head>
<body>
    <div class="info">
        <h3>🗺️ Serveur OSM Local</h3>
        <p>Données: Cameroun</p>
        <p>Status: <span id="status">Chargement...</span></p>
    </div>
    <div id="map"></div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Coordonnées du Cameroun
        var map = L.map('map').setView([7.3697, 12.3547], 6);
        
        // Votre serveur de tuiles local
        L.tileLayer('/osm/{z}/{x}/{y}.png', {
            maxZoom: 18,
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);
        
        // Test de connectivité
        fetch('/osm/0/0/0.png')
            .then(response => {
                if (response.ok) {
                    document.getElementById('status').textContent = '✅ Actif';
                    document.getElementById('status').style.color = 'green';
                } else {
                    document.getElementById('status').textContent = '⚠️ Tuiles en génération...';
                    document.getElementById('status').style.color = 'orange';
                }
            })
            .catch(() => {
                document.getElementById('status').textContent = '❌ Erreur';
                document.getElementById('status').style.color = 'red';
            });
    </script>
</body>
</html>
EOF

# Vérifier si les données sont importées
if [ ! -f /var/lib/mod_tile/planet-import-complete ]; then
    echo "⚠️  Aucune donnée OSM détectée."
    echo "📥 Pour importer des données, exécutez :"
    echo "   docker-compose exec tileserver import-osm.sh /data/osm/cameroon-latest.osm.pbf"
else
    echo "✅ Données OSM déjà importées"
fi

# Démarrer renderd
echo "🎨 Démarrage de renderd..."
sudo -u www-data renderd -c /etc/renderd.conf &

# Démarrer Apache
echo "🌐 Démarrage d'Apache..."
. /etc/apache2/envvars
exec apache2 -D FOREGROUND