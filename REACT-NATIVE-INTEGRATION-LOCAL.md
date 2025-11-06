# 📱 Intégration React Native - Serveur OSM Local

## 🎯 Configuration pour serveur local (http://localhost:8080)

### 1. Installation des dépendances

```bash
# Créer le projet React Native
npx react-native init OSMCamerounApp
cd OSMCamerounApp

# Installer react-native-maps
npm install react-native-maps

# iOS uniquement
cd ios && pod install && cd ..

# Android - Ajouter dans android/app/build.gradle
implementation 'com.google.android.gms:play-services-maps:18.1.0'
```

### 2. Configuration Android (android/app/src/main/AndroidManifest.xml)

```xml
<application>
  <!-- Permissions réseau -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  
  <!-- Configuration pour HTTP local -->
  <application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
  </application>
</application>
```

### 3. Configuration réseau Android (android/app/src/main/res/xml/network_security_config.xml)

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">192.168.1.100</domain>
    </domain-config>
</network-security-config>
```

### 4. Composant Map principal (src/components/OSMMap.js)

```javascript
import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Alert, Platform } from 'react-native';
import MapView, { UrlTile, Marker } from 'react-native-maps';

const OSMMap = () => {
  const [tileUrl, setTileUrl] = useState('');
  
  useEffect(() => {
    // Configuration URL selon la plateforme
    const baseUrl = Platform.OS === 'android' 
      ? 'http://10.0.2.2:8080'  // Émulateur Android
      : 'http://localhost:8080'; // iOS Simulator
    
    setTileUrl(`${baseUrl}/tile/{z}/{x}/{y}.png`);
    
    // Test de connectivité
    testConnection(baseUrl);
  }, []);

  const testConnection = async (baseUrl) => {
    try {
      const response = await fetch(`${baseUrl}/tile/0/0/0.png`);
      if (!response.ok) {
        Alert.alert('Erreur', 'Serveur OSM non accessible');
      }
    } catch (error) {
      Alert.alert('Erreur réseau', 'Vérifiez que le serveur OSM est démarré');
    }
  };

  // Région du Cameroun
  const camerounRegion = {
    latitude: 7.3697,
    longitude: 12.3547,
    latitudeDelta: 8.0,
    longitudeDelta: 8.0,
  };

  // Villes principales
  const cities = [
    { name: 'Yaoundé', lat: 3.8667, lng: 11.5167, pop: '2.8M' },
    { name: 'Douala', lat: 4.0511, lng: 9.7679, pop: '3.7M' },
    { name: 'Garoua', lat: 9.3265, lng: 13.3958, pop: '436K' },
    { name: 'Bamenda', lat: 5.9597, lng: 10.1453, pop: '2M' },
  ];

  return (
    <View style={styles.container}>
      <MapView
        style={styles.map}
        initialRegion={camerounRegion}
        mapType="none" // Important: désactiver les tuiles par défaut
      >
        {/* Vos tuiles OSM locales */}
        <UrlTile
          urlTemplate={tileUrl}
          maximumZ={18}
          minimumZ={1}
          shouldReplaceMapContent={true}
        />
        
        {/* Marqueurs des villes */}
        {cities.map((city, index) => (
          <Marker
            key={index}
            coordinate={{ latitude: city.lat, longitude: city.lng }}
            title={city.name}
            description={`Population: ${city.pop}`}
          />
        ))}
      </MapView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
});

export default OSMMap;
```

### 5. Application principale (App.js)

```javascript
import React from 'react';
import { SafeAreaView, StatusBar, StyleSheet } from 'react-native';
import OSMMap from './src/components/OSMMap';

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <OSMMap />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
```

### 6. Service API local (src/services/LocalOSMService.js)

```javascript
import { Platform } from 'react-native';

class LocalOSMService {
  constructor() {
    this.baseUrl = Platform.OS === 'android' 
      ? 'http://10.0.2.2:8080'
      : 'http://localhost:8080';
  }

  // Tester la connectivité
  async testConnection() {
    try {
      const response = await fetch(`${this.baseUrl}/tile/0/0/0.png`);
      return response.ok;
    } catch (error) {
      return false;
    }
  }

  // Obtenir l'URL des tuiles
  getTileUrl() {
    return `${this.baseUrl}/tile/{z}/{x}/{y}.png`;
  }

  // Recherche de lieux (si API disponible)
  async searchPlace(query) {
    try {
      const response = await fetch(`${this.baseUrl}/api/search?q=${encodeURIComponent(query)}`);
      return await response.json();
    } catch (error) {
      console.log('API de recherche non disponible');
      return [];
    }
  }
}

export default new LocalOSMService();
```

### 7. Hook personnalisé (src/hooks/useLocalOSM.js)

```javascript
import { useState, useEffect } from 'react';
import LocalOSMService from '../services/LocalOSMService';

export const useLocalOSM = () => {
  const [isConnected, setIsConnected] = useState(false);
  const [tileUrl, setTileUrl] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkConnection();
  }, []);

  const checkConnection = async () => {
    setLoading(true);
    const connected = await LocalOSMService.testConnection();
    setIsConnected(connected);
    
    if (connected) {
      setTileUrl(LocalOSMService.getTileUrl());
    }
    
    setLoading(false);
  };

  return {
    isConnected,
    tileUrl,
    loading,
    checkConnection
  };
};
```

### 8. Composant avec gestion d'erreur (src/components/OSMMapWithFallback.js)

```javascript
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import MapView, { UrlTile, Marker } from 'react-native-maps';
import { useLocalOSM } from '../hooks/useLocalOSM';

const OSMMapWithFallback = () => {
  const { isConnected, tileUrl, loading, checkConnection } = useLocalOSM();

  const camerounRegion = {
    latitude: 7.3697,
    longitude: 12.3547,
    latitudeDelta: 8.0,
    longitudeDelta: 8.0,
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <Text>Connexion au serveur OSM...</Text>
      </View>
    );
  }

  if (!isConnected) {
    return (
      <View style={styles.centerContainer}>
        <Text style={styles.errorText}>❌ Serveur OSM non accessible</Text>
        <Text style={styles.helpText}>
          Vérifiez que le serveur est démarré sur http://localhost:8080
        </Text>
        <TouchableOpacity style={styles.retryButton} onPress={checkConnection}>
          <Text style={styles.retryText}>Réessayer</Text>
        </TouchableOpacity>
        
        {/* Carte de fallback avec OpenStreetMap */}
        <MapView
          style={styles.map}
          initialRegion={camerounRegion}
        >
          <UrlTile
            urlTemplate="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
            maximumZ={18}
            shouldReplaceMapContent={true}
          />
        </MapView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.statusBar}>
        <Text style={styles.statusText}>✅ Serveur OSM local connecté</Text>
      </View>
      
      <MapView
        style={styles.map}
        initialRegion={camerounRegion}
        mapType="none"
      >
        <UrlTile
          urlTemplate={tileUrl}
          maximumZ={18}
          minimumZ={1}
          shouldReplaceMapContent={true}
        />
      </MapView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  map: {
    flex: 1,
  },
  statusBar: {
    backgroundColor: '#4CAF50',
    padding: 10,
    alignItems: 'center',
  },
  statusText: {
    color: 'white',
    fontWeight: 'bold',
  },
  errorText: {
    fontSize: 18,
    color: 'red',
    marginBottom: 10,
  },
  helpText: {
    textAlign: 'center',
    color: 'gray',
    marginBottom: 20,
  },
  retryButton: {
    backgroundColor: '#2196F3',
    padding: 10,
    borderRadius: 5,
    marginBottom: 20,
  },
  retryText: {
    color: 'white',
    fontWeight: 'bold',
  },
});

export default OSMMapWithFallback;
```

## 🚀 Démarrage

### 1. Démarrer le serveur OSM
```bash
# Dans le dossier mapproject
docker compose -p osm-new up -d
```

### 2. Lancer l'app React Native
```bash
# Android
npx react-native run-android

# iOS
npx react-native run-ios
```

## 🔧 Résolution des problèmes

### Émulateur Android ne voit pas localhost
```javascript
// Utiliser 10.0.2.2 au lieu de localhost
const baseUrl = 'http://10.0.2.2:8080';
```

### Appareil physique Android
```javascript
// Utiliser l'IP de votre machine
const baseUrl = 'http://192.168.1.100:8080'; // Remplacer par votre IP
```

### Tester la connectivité
```bash
# Depuis l'émulateur Android
adb shell
curl http://10.0.2.2:8080/tile/0/0/0.png
```

## 📱 URLs importantes

- **Serveur local** : http://localhost:8080
- **Android émulateur** : http://10.0.2.2:8080
- **Tuiles** : `/tile/{z}/{x}/{y}.png`
- **Interface web** : http://localhost:8080

Ton serveur OSM local est maintenant intégré dans React Native ! 🎉