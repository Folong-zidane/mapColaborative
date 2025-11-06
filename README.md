# 🗺️ Serveur de Tuiles OSM - Cameroun

## 🎯 Solutions de Déploiement

### Option 1: Oracle Cloud Always Free (RECOMMANDÉ) ⭐
- ✅ **24 Go RAM + 4 cœurs ARM GRATUITS À VIE**
- ✅ **200 Go de stockage**
- ✅ IP fixe gratuite

### Option 2: Local + Cloudflare Tunnel
- ✅ Totalement gratuit
- ✅ HTTPS automatique
- ✅ Votre propre PC suffit

## 🚀 Démarrage Rapide

### 1. Installation Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 2. Télécharger les données OSM
```bash
# Créer le dossier data
mkdir -p data

# Télécharger le Cameroun (100 Mo)
wget -P data/ http://download.geofabrik.de/africa/cameroon-latest.osm.pbf

# OU pour test rapide - Alsace (20 Mo)
wget -P data/ http://download.geofabrik.de/europe/france/alsace-latest.osm.pbf
```

### 3. Télécharger le style de carte
```bash
git clone https://github.com/gravitystorm/openstreetmap-carto.git
```

### 4. Lancer les services
```bash
docker-compose up -d
```

### 5. Importer les données
```bash
# Attendre que PostgreSQL soit prêt (30 secondes)
docker-compose logs -f postgres

# Importer (30-60 minutes pour le Cameroun)
docker-compose exec tileserver import-osm.sh /data/osm/cameroon-latest.osm.pbf
```

### 6. Accéder à votre carte
```
http://localhost/map
```

## 📊 Ressources Nécessaires

| Zone | Fichier | Taille | RAM | Temps Import |
|------|---------|--------|-----|--------------|
| Alsace | 20 Mo | 2 Go | 4 Go | 5 min |
| Cameroun | 100 Mo | 10 Go | 8 Go | 30 min |
| France | 4 Go | 100 Go | 16 Go | 4h |

## 🔧 Commandes Utiles

```bash
# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down

# Reset complet (supprime les données)
docker-compose down -v

# Accéder au shell
docker-compose exec tileserver bash
docker-compose exec postgres psql -U osmuser -d gis

# Surveiller les ressources
docker stats
```

## ☁️ Déploiement Oracle Cloud

### 1. Créer un compte
- Aller sur https://www.oracle.com/cloud/free/
- S'inscrire (carte bancaire requise mais jamais facturée)

### 2. Créer une VM
- Shape: VM.Standard.A1.Flex (ARM)
- CPU: 4 OCPUs
- RAM: 24 GB
- Stockage: 200 GB
- OS: Ubuntu 22.04

### 3. Configurer le pare-feu
```bash
# Sur la VM
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# Dans Oracle Cloud Console
# Networking → Security Lists → Ajouter règle Ingress
# Source: 0.0.0.0/0, Port: 80
```
# openStream-Map-for-Locality
