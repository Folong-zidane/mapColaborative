# 📱 Installation React Native Maps - Guide Complet

## 🚀 1. Installation des dépendances

```bash
# Dans votre projet React Native
npm install react-native-maps

# Pour iOS uniquement
cd ios && pod install && cd ..
```

## 🤖 2. Configuration Android

### AndroidManifest.xml
Modifier `android/app/src/main/AndroidManifest.xml` :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions réseau -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:name=".MainApplication"
        android:allowBackup="false"
        android:theme="@style/AppTheme"
        android:usesCleartextTraffic="true"
        android:networkSecurityConfig="@xml/network_security_config">
        
        <!-- Vos activités... -->
        
    </application>
</manifest>
```

### Network Security Config
Créer `android/app/src/main/res/xml/network_security_config.xml` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <!-- Pour émulateur Android -->
        <domain includeSubdomains="true">10.0.2.2</domain>
        <!-- Pour appareil physique (remplacer par votre IP) -->
        <domain includeSubdomains="true">10.47.147.41</domain>
        <!-- Localhost pour iOS -->
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

### build.gradle
Ajouter dans `android/app/build.gradle` :

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-maps:18.1.0'
    // ... autres dépendances
}
```

## 🍎 3. Configuration iOS

### Podfile
Vérifier que dans `ios/Podfile` :

```ruby
platform :ios, '11.0'

target 'YourApp' do
  # ... autres pods
  
  # React Native Maps
  pod 'react-native-maps', path: '../node_modules/react-native-maps'
end
```

Puis :
```bash
cd ios && pod install
```

## 🗺️ 4. Utilisation du composant

```tsx
import OSMMapCorrect from './path/to/OSMMapCorrect';

// Dans votre composant
const markers = [
  {
    id: 1,
    latitude: 3.8667,
    longitude: 11.5167,
    title: 'Yaoundé',
    type: 'garage' as const
  }
];

<OSMMapCorrect 
  markers={markers}
  userLocation={{ latitude: 3.8667, longitude: 11.5167 }}
/>
```

## 🔧 5. URLs selon la plateforme

Le composant gère automatiquement :

- **Android Émulateur** : `http://10.0.2.2:8082`
- **iOS Simulateur** : `http://localhost:8082`
- **Appareil physique** : `http://VOTRE_IP:8082`

## 🚨 6. Dépannage

### Erreur "Network request failed"
1. Vérifier `android:usesCleartextTraffic="true"`
2. Vérifier `network_security_config.xml`
3. Vérifier que le serveur OSM tourne sur le bon port

### Erreur "Unable to resolve module"
```bash
# Nettoyer le cache
npx react-native start --reset-cache

# Réinstaller les dépendances
rm -rf node_modules && npm install
cd ios && pod install && cd ..
```

### Carte blanche
1. Vérifier l'URL des tuiles dans les logs
2. Tester l'URL manuellement : `curl http://10.0.2.2:8082/tile/0/0/0.png`
3. Vérifier les permissions réseau

## ✅ 7. Test de fonctionnement

1. **Démarrer le serveur OSM** :
```bash
./start-simple.sh
```

2. **Vérifier l'accès** :
```bash
# Depuis votre machine
curl http://localhost:8082/tile/0/0/0.png

# Depuis l'émulateur Android
adb shell
curl http://10.0.2.2:8082/tile/0/0/0.png
```

3. **Lancer l'app** :
```bash
npx react-native run-android
# ou
npx react-native run-ios
```

## 🎯 8. Fonctionnalités du composant

- ✅ **Auto-détection de plateforme** (Android/iOS)
- ✅ **Test de connectivité automatique**
- ✅ **Carte de fallback** (OpenStreetMap public)
- ✅ **Marqueurs personnalisés**
- ✅ **Position utilisateur**
- ✅ **Interface de debug**
- ✅ **Gestion d'erreurs complète**

Votre carte OSM est maintenant prête ! 🗺️