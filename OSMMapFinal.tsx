import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Text, Platform, Alert } from 'react-native';
import MapView, { UrlTile, Marker, Region } from 'react-native-maps';

interface MarkerData {
  id: number;
  latitude: number;
  longitude: number;
  title: string;
  description?: string;
}

interface OSMMapFinalProps {
  markers?: MarkerData[];
  userLocation?: { latitude: number; longitude: number };
  onRegionChange?: (region: Region) => void;
}

const OSMMapFinal: React.FC<OSMMapFinalProps> = ({ 
  markers = [], 
  userLocation,
  onRegionChange 
}) => {
  const [serverStatus, setServerStatus] = useState<'testing' | 'online' | 'offline'>('testing');
  const [currentUrl, setCurrentUrl] = useState<string>('');

  // URLs selon la configuration du projet
  const getServerUrls = () => {
    const urls = [
      // URL publique (ngrok ou IP publique)
      'https://abc123.ngrok.io',
      'http://165.211.32.25:8000',
      
      // URLs locales selon plateforme
      Platform.OS === 'android' ? 'http://10.0.2.2:8080' : 'http://localhost:8080',
      Platform.OS === 'android' ? 'http://10.0.2.2:8000' : 'http://localhost:8000',
      
      // Fallback OpenStreetMap
      'https://tile.openstreetmap.org'
    ];
    
    return urls;
  };

  // Test de connectivité avec fallback automatique
  useEffect(() => {
    const testServers = async () => {
      const urls = getServerUrls();
      
      for (const url of urls) {
        try {
          const testUrl = url.includes('openstreetmap.org') 
            ? `${url}/0/0/0.png` 
            : `${url}/tile/0/0/0.png`;
            
          const response = await fetch(testUrl, { 
            method: 'HEAD',
            timeout: 5000 
          });
          
          if (response.ok) {
            setCurrentUrl(url);
            setServerStatus('online');
            console.log(`✅ Serveur connecté: ${url}`);
            return;
          }
        } catch (error) {
          console.log(`❌ Échec: ${url}`);
        }
      }
      
      // Aucun serveur disponible
      setServerStatus('offline');
      Alert.alert(
        'Connexion impossible',
        'Impossible de se connecter au serveur de cartes. Vérifiez votre connexion.'
      );
    };

    testServers();
  }, []);

  // Configuration des tuiles selon le serveur
  const getTileConfig = () => {
    if (currentUrl.includes('openstreetmap.org')) {
      return {
        urlTemplate: `${currentUrl}/{z}/{x}/{y}.png`,
        attribution: '© OpenStreetMap contributors'
      };
    } else {
      return {
        urlTemplate: `${currentUrl}/tile/{z}/{x}/{y}.png`,
        attribution: '© OSM Cameroun Personnalisé'
      };
    }
  };

  // Région du Cameroun par défaut
  const camerounRegion: Region = {
    latitude: userLocation?.latitude || 7.3697,
    longitude: userLocation?.longitude || 12.3547,
    latitudeDelta: 8.0,
    longitudeDelta: 8.0,
  };

  // Marqueurs par défaut des villes du Cameroun
  const defaultMarkers: MarkerData[] = [
    { id: 1, latitude: 3.8667, longitude: 11.5167, title: 'Yaoundé', description: 'Capitale politique' },
    { id: 2, latitude: 4.0511, longitude: 9.7679, title: 'Douala', description: 'Capitale économique' },
    { id: 3, latitude: 9.3265, longitude: 13.3958, title: 'Garoua', description: 'Nord Cameroun' },
    { id: 4, latitude: 5.9597, longitude: 10.1453, title: 'Bamenda', description: 'Nord-Ouest' },
    { id: 5, latitude: 10.5906, longitude: 14.3197, title: 'Maroua', description: 'Extrême-Nord' },
    { id: 6, latitude: 5.4737, longitude: 10.4158, title: 'Bafoussam', description: 'Ouest' },
  ];

  const allMarkers = markers.length > 0 ? markers : defaultMarkers;
  const tileConfig = getTileConfig();

  return (
    <View style={styles.container}>
      {/* Header de status */}
      <View style={[styles.header, { 
        backgroundColor: serverStatus === 'online' ? '#4CAF50' : 
                        serverStatus === 'offline' ? '#FF5722' : '#FF9800' 
      }]}>
        <Text style={styles.headerText}>
          🗺️ OSM Cameroun - {
            serverStatus === 'online' ? '✅ Connecté' : 
            serverStatus === 'offline' ? '❌ Hors ligne' : '⏳ Connexion...'
          }
        </Text>
        {serverStatus === 'online' && (
          <Text style={styles.subHeaderText}>
            {currentUrl.includes('openstreetmap.org') ? '🌐 OpenStreetMap' : '🇨🇲 Serveur personnalisé'}
          </Text>
        )}
      </View>

      {/* Carte */}
      <MapView
        style={styles.map}
        initialRegion={camerounRegion}
        mapType="none"
        onRegionChangeComplete={onRegionChange}
        showsUserLocation={!!userLocation}
        showsMyLocationButton={!!userLocation}
      >
        {/* Tuiles personnalisées ou fallback */}
        {serverStatus === 'online' && currentUrl && (
          <UrlTile
            urlTemplate={tileConfig.urlTemplate}
            maximumZ={18}
            minimumZ={1}
            shouldReplaceMapContent={true}
            tileSize={256}
          />
        )}
        
        {/* Marqueurs */}
        {allMarkers.map((marker) => (
          <Marker
            key={marker.id}
            coordinate={{ 
              latitude: marker.latitude, 
              longitude: marker.longitude 
            }}
            title={marker.title}
            description={marker.description}
            pinColor={markers.length > 0 ? '#FF5722' : '#4CAF50'}
          />
        ))}

        {/* Position utilisateur */}
        {userLocation && (
          <Marker
            coordinate={userLocation}
            title="Ma position"
            pinColor="#2196F3"
          />
        )}
      </MapView>

      {/* Panel d'informations */}
      <View style={styles.infoPanel}>
        <Text style={styles.infoText}>
          📡 Serveur: {currentUrl || 'Aucun'}
        </Text>
        <Text style={styles.infoText}>
          🔗 Tuiles: {tileConfig.urlTemplate}
        </Text>
        <Text style={styles.infoText}>
          📱 Plateforme: {Platform.OS}
        </Text>
        <Text style={styles.infoText}>
          📍 Marqueurs: {allMarkers.length}
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    padding: 12,
    alignItems: 'center',
  },
  headerText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 16,
  },
  subHeaderText: {
    color: 'white',
    fontSize: 12,
    marginTop: 2,
  },
  map: {
    flex: 1,
  },
  infoPanel: {
    backgroundColor: 'rgba(255,255,255,0.95)',
    padding: 10,
    position: 'absolute',
    bottom: 20,
    left: 10,
    right: 10,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  infoText: {
    fontSize: 11,
    color: '#666',
    marginBottom: 2,
  },
});

export default OSMMapFinal;