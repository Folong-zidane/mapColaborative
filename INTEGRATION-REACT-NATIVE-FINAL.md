# 📱 Intégration React Native - Script Final

## 🎯 Installation rapide

### 1. Dépendances
```bash
npm install react-native-maps
cd ios && pod install && cd ..  # iOS uniquement
```

### 2. Configuration Android
**android/app/src/main/AndroidManifest.xml** :
```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
</application>
```

**android/app/src/main/res/xml/network_security_config.xml** :
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">165.211.32.25</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

## 🗺️ Utilisation du composant

### Import et utilisation basique
```tsx
import OSMMapFinal from './OSMMapFinal';

// Utilisation simple
<OSMMapFinal />
```

### Avec marqueurs personnalisés
```tsx
const markers = [
  {
    id: 1,
    latitude: 3.8667,
    longitude: 11.5167,
    title: 'Mon garage',
    description: 'Réparation auto'
  },
  {
    id: 2,
    latitude: 4.0511,
    longitude: 9.7679,
    title: 'Station service',
    description: 'Essence et diesel'
  }
];

<OSMMapFinal 
  markers={markers}
  userLocation={{ latitude: 3.8667, longitude: 11.5167 }}
  onRegionChange={(region) => console.log('Région changée:', region)}
/>
```

## 🔧 Fonctionnalités automatiques

### ✅ Auto-détection serveur
Le composant teste automatiquement :
1. **URL publique** (ngrok, IP publique)
2. **Serveur local** selon plateforme
3. **Fallback OpenStreetMap** si échec

### ✅ Configuration automatique
- **Android émulateur** : `http://10.0.2.2:8080`
- **iOS simulateur** : `http://localhost:8080`
- **Appareil physique** : `http://165.211.32.25:8000`
- **Fallback** : OpenStreetMap public

### ✅ Interface utilisateur
- Status de connexion en temps réel
- Panel d'informations détaillé
- Marqueurs par défaut (villes du Cameroun)
- Position utilisateur optionnelle

## 🚀 Démarrage serveur

### Option 1 : Serveur local
```bash
# Dans le dossier mapproject
python3 hybrid-server.py
```

### Option 2 : Exposition publique
```bash
# Avec ngrok
./ngrok http 8080

# Ou serveur final
python3 expose-final.py
```

## 📱 Test complet

### 1. Démarrer le serveur
```bash
cd /home/folongzidane/Documents/Projet/mapproject
python3 hybrid-server.py
```

### 2. Intégrer dans votre app React Native
```tsx
// App.tsx ou votre composant principal
import React from 'react';
import { SafeAreaView } from 'react-native';
import OSMMapFinal from './components/OSMMapFinal';

const App = () => {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <OSMMapFinal />
    </SafeAreaView>
  );
};

export default App;
```

### 3. Lancer l'application
```bash
npx react-native run-android
# ou
npx react-native run-ios
```

## 🎯 Avantages de cette intégration

### ✅ Robustesse
- **Fallback automatique** vers OpenStreetMap
- **Test de connectivité** en temps réel
- **Gestion d'erreurs** complète

### ✅ Flexibilité
- **Marqueurs personnalisables**
- **Position utilisateur** optionnelle
- **Callbacks** pour interactions

### ✅ Performance
- **Cache automatique** des tuiles
- **Optimisation réseau**
- **Interface responsive**

## 🔍 Debug et dépannage

### Logs utiles
```tsx
// Le composant affiche automatiquement :
console.log('✅ Serveur connecté: URL');
console.log('❌ Échec: URL');
```

### Test manuel des URLs
```bash
# Tester depuis votre machine
curl http://localhost:8080/tile/0/0/0.png

# Tester depuis l'émulateur Android
adb shell
curl http://10.0.2.2:8080/tile/0/0/0.png
```

### Vérification réseau
```bash
# Vérifier que le serveur écoute
netstat -tlnp | grep 8080
```

## 📊 Configuration avancée

### Personnalisation des URLs
```tsx
// Modifier dans OSMMapFinal.tsx
const getServerUrls = () => {
  return [
    'https://votre-domaine.com',  // Votre URL personnalisée
    'http://165.211.32.25:8000',
    // ... autres URLs
  ];
};
```

### Styles personnalisés
```tsx
const customStyles = StyleSheet.create({
  header: {
    backgroundColor: '#YOUR_COLOR',
  },
  // ... autres styles
});
```

## 🎉 Résultat final

Votre application React Native aura :
- ✅ **Carte du Cameroun** avec vos tuiles personnalisées
- ✅ **Fallback automatique** vers OpenStreetMap
- ✅ **Interface utilisateur** complète
- ✅ **Marqueurs** des villes principales
- ✅ **Position utilisateur** (optionnelle)
- ✅ **Debug panel** intégré

**Le composant est prêt à l'emploi ! Copiez OSMMapFinal.tsx dans votre projet et utilisez-le directement.** 🚀