# 🔧 Configuration Android pour OSM Local

## 1. AndroidManifest.xml

Ajouter dans `android/app/src/main/AndroidManifest.xml` :

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

## 2. Network Security Config

Créer `android/app/src/main/res/xml/network_security_config.xml` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <!-- Localhost pour émulateur -->
        <domain includeSubdomains="true">10.0.2.2</domain>
        <!-- IP locale pour appareil physique -->
        <domain includeSubdomains="true">10.47.147.41</domain>
        <!-- Autres IPs si nécessaire -->
        <domain includeSubdomains="true">192.168.1.0</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

## 3. URLs selon la plateforme

```javascript
const getServerUrl = () => {
  if (Platform.OS === 'android') {
    // Émulateur Android
    return 'http://10.0.2.2:9999';
  } else if (Platform.OS === 'ios') {
    // Simulateur iOS
    return 'http://localhost:9999';
  } else {
    // Appareil physique
    return 'http://10.47.147.41:9999';
  }
};
```

## 4. Test de connectivité

```bash
# Depuis l'émulateur Android
adb shell
curl http://10.0.2.2:9999/tile/0/0/0.png

# Depuis l'appareil physique
curl http://10.47.147.41:9999/tile/0/0/0.png
```