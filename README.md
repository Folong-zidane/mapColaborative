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
/Documents/Projet/mapproject$ docker-compose -f docker-compose.ultra-light.yml up -d
[+] Running 46/46
 ✔ postgres Pulled                                                    639.1s 
 ✔ tileserver Pulled                                                  844.7s 
 ✔ nginx Pulled                                                       721.9s 
                                                                             
[+] Running 7/7
 ✔ Network mapproject_osm-network     Created                           1.4s 
 ✔ Volume "mapproject_tile-cache"     Created                           1.0s 
 ✔ Volume "mapproject_osm-data"       Created                           0.0s 
 ✔ Volume "mapproject_postgres-data"  Created                           0.0s 
 ✔ Container osm-postgres             Start...                         16.4s 
 ✔ Container osm-tileserver           Sta...                            0.6s 
 ✔ Container osm-nginx                Started                           1.4s 
folongzidane@folongzidane:~/Documents/Projet/mapproject$ 
docker-compose logs -f postgres
osm-postgres  | The files belonging to this database system will be owned by user "postgres".
osm-postgres  | This user must also own the server process.
osm-postgres  | 
osm-postgres  | The database cluster will be initialized with locale "en_US.utf8".
osm-postgres  | The default database encoding has accordingly been set to "UTF8".
osm-postgres  | The default text search configuration will be set to "english".
osm-postgres  | 
osm-postgres  | Data page checksums are disabled.
osm-postgres  | 
osm-postgres  | fixing permissions on existing directory /var/lib/postgresql/data ... ok
osm-postgres  | creating subdirectories ... ok
osm-postgres  | selecting dynamic shared memory implementation ... posix
osm-postgres  | selecting default max_connections ... 100
osm-postgres  | selecting default shared_buffers ... 128MB
osm-postgres  | selecting default time zone ... UTC
osm-postgres  | creating configuration files ... ok
osm-postgres  | running bootstrap script ... ok
osm-postgres  | sh: locale: not found
osm-postgres  | 2025-10-18 00:05:28.850 UTC [30] WARNING:  no usable system locales were found
osm-postgres  | performing post-bootstrap initialization ... ok
osm-postgres  | syncing data to disk ... ok
osm-postgres  | 
osm-postgres  | initdb: warning: enabling "trust" authentication for local connections
osm-postgres  | initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.
osm-postgres  | 
osm-postgres  | Success. You can now start the database server using:
osm-postgres  | 
osm-postgres  |     pg_ctl -D /var/lib/postgresql/data -l logfile start
osm-postgres  | 
osm-postgres  | waiting for server to start....2025-10-18 00:05:30.363 UTC [36] LOG:  starting PostgreSQL 15.4 on x86_64-pc-linux-musl, compiled by gcc (Alpine 12.2.1_git20220924-r10) 12.2.1 20220924, 64-bit
osm-postgres  | 2025-10-18 00:05:30.365 UTC [36] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
osm-postgres  | 2025-10-18 00:05:30.372 UTC [39] LOG:  database system was shut down at 2025-10-18 00:05:29 UTC
osm-postgres  | 2025-10-18 00:05:30.378 UTC [36] LOG:  database system is ready to accept connections
osm-postgres  |  done
osm-postgres  | server started
osm-postgres  | CREATE DATABASE
osm-postgres  | 
osm-postgres  | 
osm-postgres  | /usr/local/bin/docker-entrypoint.sh: sourcing /docker-entrypoint-initdb.d/10_postgis.sh
osm-postgres  | CREATE DATABASE
osm-postgres  | Loading PostGIS extensions into template_postgis
osm-postgres  | CREATE EXTENSION
osm-postgres  | CREATE EXTENSION
osm-postgres  | You are now connected to database "template_postgis" as user "osmuser".
osm-postgres  | CREATE EXTENSION
osm-postgres  | CREATE EXTENSION
osm-postgres  | Loading PostGIS extensions into gis
osm-postgres  | CREATE EXTENSION
osm-postgres  | CREATE EXTENSION
osm-postgres  | You are now connected to database "gis" as user "osmuser".
osm-postgres  | CREATE EXTENSION
osm-postgres  | CREATE EXTENSION
osm-postgres  | 
osm-postgres  | waiting for server to shut down...2025-10-18 00:05:35.451 UTC [36] LOG:  received fast shutdown request
osm-postgres  | .2025-10-18 00:05:35.452 UTC [36] LOG:  aborting any active transactions
osm-postgres  | 2025-10-18 00:05:35.455 UTC [36] LOG:  background worker "logical replication launcher" (PID 42) exited with exit code 1
osm-postgres  | 2025-10-18 00:05:35.457 UTC [37] LOG:  shutting down
osm-postgres  | 2025-10-18 00:05:35.458 UTC [37] LOG:  checkpoint starting: shutdown immediate
osm-postgres  | 2025-10-18 00:05:36.365 UTC [37] LOG:  checkpoint complete: wrote 4469 buffers (27.3%); 0 WAL file(s) added, 0 removed, 2 recycled; write=0.792 s, sync=0.110 s, total=0.908 s; sync files=963, longest=0.011 s, average=0.001 s; distance=34811 kB, estimate=34811 kB
osm-postgres  | 2025-10-18 00:05:36.378 UTC [36] LOG:  database system is shut down
osm-postgres  |  done
osm-postgres  | server stopped
osm-postgres  | 
osm-postgres  | PostgreSQL init process complete; ready for start up.
osm-postgres  | 
osm-postgres  | 2025-10-18 00:05:36.482 UTC [1] LOG:  starting PostgreSQL 15.4 on x86_64-pc-linux-musl, compiled by gcc (Alpine 12.2.1_git20220924-r10) 12.2.1 20220924, 64-bit
osm-postgres  | 2025-10-18 00:05:36.482 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
osm-postgres  | 2025-10-18 00:05:36.482 UTC [1] LOG:  listening on IPv6 address "::", port 5432
osm-postgres  | 2025-10-18 00:05:36.485 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
osm-postgres  | 2025-10-18 00:05:36.491 UTC [60] LOG:  database system was shut down at 2025-10-18 00:05:36 UTC
osm-postgres  | 2025-10-18 00:05:36.499 UTC [1] LOG:  database system is ready to accept connections
osm-postgres  | 2025-10-18 00:10:36.591 UTC [58] LOG:  checkpoint starting: time
osm-postgres  | 2025-10-18 00:11:00.248 UTC [58] LOG:  checkpoint complete: wrote 238 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=23.576 s, sync=0.060 s, total=23.658 s; sync files=98, longest=0.049 

### 4. Déployer
```bash
# Transférer le projet
scp -r . ubuntu@<IP_ORACLE>:~/osm-server/

# Se connecter et lancer
ssh ubuntu@<IP_ORACLE>
cd osm-server
docker-compose up -d
```

## 🌐 Cloudflare Tunnel (Local)

### 1. Installer cloudflared
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
```

### 2. Authentifier
```bash
cloudflared tunnel login
```

### 3. Créer le tunnel
```bash
cloudflared tunnel create osm-tiles
```

### 4. Configurer (~/.cloudflared/config.yml)
```yaml
tunnel: <TUNNEL_ID>
credentials-file: /home/user/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: osm.votre-domaine.com
    service: http://localhost:80
  - service: http_status:404
```

### 5. Lancer
```bash
cloudflared tunnel route dns osm-tiles osm.votre-domaine.com
cloudflared tunnel run osm-tiles
```

## 🔄 Mises à Jour Automatiques

Créer `update.sh`:
```bash
#!/bin/bash
cd ~/osm-server
wget -O data/cameroon-latest.osm.pbf http://download.geofabrik.de/africa/cameroon-latest.osm.pbf
docker-compose exec tileserver import-osm.sh /data/osm/cameroon-latest.osm.pbf
```

Cron (mise à jour hebdomadaire):
```bash
crontab -e
# Ajouter: 0 3 * * 0 /home/user/osm-server/update.sh
```

## 🎯 Prochaines Étapes

1. **Personnaliser le style** avec CartoCSS
2. **Ajouter la recherche** (Nominatim)
3. **Calcul d'itinéraires** (OSRM)
4. **API REST** pour votre application

## 📚 Ressources

- [OpenStreetMap Wiki](https://wiki.openstreetmap.org/)
- [Switch2OSM](https://switch2osm.org/)
- [Leaflet.js](https://leafletjs.com/)
- [Oracle Cloud Free Tier](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm)# mapColaborative
# mapColaborative
