#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "❌ Usage: $0 <fichier.osm.pbf>"
    echo "📥 Téléchargez d'abord les données :"
    echo "   wget -P /data/osm/ http://download.geofabrik.de/africa/cameroon-latest.osm.pbf"
    exit 1
fi

PBF_FILE=$1

if [ ! -f "$PBF_FILE" ]; then
    echo "❌ Fichier non trouvé: $PBF_FILE"
    exit 1
fi

echo "📥 Import de $PBF_FILE dans la base de données..."

# Calculer la taille du cache (50% de la RAM)
TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
CACHE_SIZE=$((TOTAL_MEM / 2048))

echo "💾 Mémoire détectée: $TOTAL_MEM KB"
echo "📊 Taille du cache: $CACHE_SIZE MB"

# Importer avec osm2pgsql
sudo -u www-data osm2pgsql \
    --slim \
    -C $CACHE_SIZE \
    --number-processes $(nproc) \
    -H $PGHOST \
    -d $PGDATABASE \
    -U $PGUSER \
    --password \
    $PBF_FILE

# Marquer l'import comme terminé
sudo -u www-data touch /var/lib/mod_tile/planet-import-complete

echo "✅ Import terminé!"
echo "🗺️  Accédez à votre carte sur : http://localhost/map"