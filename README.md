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
- **ARKit** : Pour accéder aux données LiDAR et aux informations de profondeur
en temps réel afin de générer une description sémantique (texte) des
objets détectés. (ARMeshAnchor, ARObjectAnchor)
- **CoreML** : Pour les modèles de machine learning (reconnaissance des objets, classification des obstacles).
- **Vision** : Pour la détection d’objets via la caméra (si nécessaire en complément du LiDAR).
- **MapKit** : Pour l’intégration du GPS et la gestion de la cartographie.
- **CoreLocation** : Pour la géolocalisation.

### 3. **Machine Learning / IA**
- **CreateML + CoreML + Phi-3 Mini** : pour transformer les données brutes de détection (type, distance, direction) en phrases descriptives naturelles et adaptées à la situation. Exemple : “Poteau à 2 mètres sur la gauche” → “Obstacle à gauche,contournez-le.”
- **Apple Natural Language Framework** : pour un pré-traitement ou un post-traitement textuel rapide (lemmatisation, reformulation courte).
- **AVSpeechSynthesizer (Text-to-Speech)** : pour convertir les phrases générées en voix, intégrée à CoreAudio/PHASE.

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
