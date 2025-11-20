# EchoNav

EchoNav est une application mobile innovante destinée à aider les personnes malvoyantes à se déplacer en milieu urbain en exploitant le LiDAR des appareils iPhone et iPad. L'application utilise des signaux sonores 3D, des alertes haptiques et des instructions vocales pour guider l'utilisateur à travers son environnement en temps réel.

## Fonctionnalités principales

- **Détection d'obstacles en temps réel** grâce au LiDAR.
- **Audio 3D spatial** pour localiser les obstacles (proche, éloigné, à gauche, à droite).
- **Alertes sonores et haptiques** pour les obstacles détectés (voitures, vélos, piétons, feux de signalisation, etc.).
- **Mode assisté** avec instructions vocales pour guider l'utilisateur dans la ville.
- **Prise en charge des préférences utilisateur** (sensibilité des alertes, types de sons, etc.).

## Technologies utilisées

### 1. **Langages**
- **Swift** : Principal langage pour développer l'application iOS.
- **SwiftUI** : NavigationStack

### 2. **Frameworks iOS**
- **ARKit** : Pour accéder aux données LiDAR et aux informations de profondeur en temps réel.
- **CoreML** : Pour les modèles de machine learning (reconnaissance des objets, classification des obstacles).
- **Vision** : Pour la détection d’objets via la caméra (si nécessaire en complément du LiDAR).
- **MapKit** : Pour l’intégration du GPS et la gestion de la cartographie.
- **CoreLocation** : Pour la géolocalisation.

### 3. **Machine Learning / IA**
- **TensorFlow Lite** : Version mobile de TensorFlow pour le traitement sur les appareils iOS (si nécessaire pour le deep learning).
- **PyTorch Mobile** : Alternatif à TensorFlow Lite, utilisé pour le machine learning sur mobile.
- **CreateML** : Outil d’Apple pour créer et entraîner des modèles ML directement sur macOS.

### 4. **Audio**
- **CoreAudio / AVFoundation** : Pour gérer le son et l'audio 3D.
- **PHASE** : Pour la spatialisation de l’audio 3D.

### 5. **Base de données et Backend (si nécessaire)**
- **CloudKit** : Si vous préférez utiliser les services d’Apple pour la gestion des données et la synchronisation.

### 6. **Outils de développement**
- **Xcode** : IDE principal pour le développement iOS.
- **Simulator iOS** : Pour tester l’application sur différents appareils.
- **TestFlight** : Pour tester les versions bêta de l’application auprès des utilisateurs.
- **Swift Package Manager** : Pour la gestion des dépendances.
