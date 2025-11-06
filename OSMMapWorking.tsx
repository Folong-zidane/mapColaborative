import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Text, Platform } from 'react-native';
import MapView, { UrlTile, Marker } from 'react-native-maps';

const OSMMapWorking: React.FC = () => {
  const [serverStatus, setServerStatus] = useState<'testing' | 'online' | 'offline'>('testing');

  // Configuration URL selon la plateforme
  const getServerUrl = () => {
    if (Platform.OS === 'android') {
      return 'http://10.0.2.2:8080';  // Émulateur Android
    } else if (Platform.OS === 'ios') {
      return 'http://localhost:8080';  // Simulateur iOS
    } else {
      return 'http://10.47.147.41:8080';  // Appareil physique
    }
  };

  const serverUrl = getServerUrl();
  const tileUrl = `${serverUrl}/tile/{z}/{x}/{y}.png`;

  useEffect(() => {
    // Test de connectivité
    const testServer = async () => {
      try {
        const response = await fetch(`${serverUrl}/tile/0/0/0.png`);
        setServerStatus(response.ok ? 'online' : 'offline');
      } catch {
        setServerStatus('offline');
      }
    };
    
    testServer();
  }, []);

  // Région du Cameroun
  const camerounRegion = {
    latitude: 7.3697,
    longitude: 12.3547,
    latitudeDelta: 8.0,
    longitudeDelta: 8.0,
  };

  // Villes du Cameroun
  const cities = [
    { id: 1, latitude: 3.8667, longitude: 11.5167, title: 'Yaoundé' },
    { id: 2, latitude: 4.0511, longitude: 9.7679, title: 'Douala' },
    { id: 3, latitude: 9.3265, longitude: 13.3958, title: 'Garoua' },
    { id: 4, latitude: 5.9597, longitude: 10.1453, title: 'Bamenda' },
  ];

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
            serverStatus === 'offline' ? '❌ Hors ligne' : '⏳ Test...'
          }
        </Text>
      </View>

      {/* Carte */}
      <MapView
        style={styles.map}
        initialRegion={camerounRegion}
        mapType="none" // Désactiver les tuiles par défaut
      >
        {/* TES tuiles personnalisées */}
        <UrlTile
          urlTemplate={tileUrl}
          maximumZ={18}
          minimumZ={1}
          shouldReplaceMapContent={true}
        />
        
        {/* Marqueurs des villes */}
        {cities.map((city) => (
          <Marker
            key={city.id}
            coordinate={{ latitude: city.latitude, longitude: city.longitude }}
            title={city.title}
            description="Ville du Cameroun"
          />
        ))}
      </MapView>

      {/* Info panel */}
      <View style={styles.infoPanel}>
        <Text style={styles.infoText}>
          📡 Serveur: {serverUrl}
        </Text>
        <Text style={styles.infoText}>
          🔗 Tuiles: {tileUrl}
        </Text>
        <Text style={styles.infoText}>
          📱 Platform: {Platform.OS}
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
  map: {
    flex: 1,
  },
  infoPanel: {
    backgroundColor: '#f0f0f0',
    padding: 10,
  },
  infoText: {
    fontSize: 12,
    color: '#666',
    marginBottom: 2,
  },
});

export default OSMMapWorking;