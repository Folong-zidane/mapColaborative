import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Text, Platform, SafeAreaView } from 'react-native';
import { WebView } from 'react-native-webview';

const OSMMapFixed: React.FC = () => {
  const [serverStatus, setServerStatus] = useState<'testing' | 'online' | 'offline'>('testing');

  // URL Cloudflare directe
  const serverUrl = 'https://specified-geological-wife-cedar.trycloudflare.com';

  useEffect(() => {
    // Test de connectivité sur l'interface web (pas les tuiles)
    const testServer = async () => {
      try {
        const response = await fetch(serverUrl);
        setServerStatus(response.ok ? 'online' : 'offline');
      } catch {
        setServerStatus('offline');
      }
    };
    
    testServer();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
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

      {/* WebView qui charge directement l'URL de base */}
      <WebView
        style={styles.map}
        source={{ uri: serverUrl }}
        javaScriptEnabled={true}
        domStorageEnabled={true}
        startInLoadingState={true}
        scalesPageToFit={true}
        onLoadStart={() => console.log('Chargement carte...')}
        onLoadEnd={() => console.log('Carte chargée')}
        onError={(error) => console.error('Erreur WebView:', error)}
      />

      {/* Info panel */}
      <View style={styles.infoPanel}>
        <Text style={styles.infoText}>📱 Platform: {Platform.OS}</Text>
        <Text style={styles.infoText}>🔗 URL: {serverUrl}</Text>
        <Text style={styles.infoText}>📊 Status: {serverStatus}</Text>
        <Text style={styles.infoText}>🎯 Mode: WebView directe (interface complète)</Text>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
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
    backgroundColor: '#e0e0e0',
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

export default OSMMapFixed;