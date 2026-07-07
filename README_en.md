# EchoNav

EchoNav is an innovative mobile application designed to help visually impaired people navigate urban environments by leveraging the LiDAR technology available on iPhone and iPad devices. The application uses 3D audio cues, haptic alerts, and voice instructions to guide users through their surroundings in real time.

## Key Features

- **Real-time obstacle detection** using LiDAR.
- **3D spatial audio** to locate obstacles around the user (near, far, left, right).
- **Audible and haptic alerts** for detected obstacles such as cars, bicycles, pedestrians, traffic lights, and other urban hazards.
- **Assisted mode** with voice instructions to guide the user through the city.
- **User preference support** including alert sensitivity, sound types, and other accessibility settings.

## Technologies Used

### 1. **Languages**

- **Swift**: Main language used to develop the iOS application.
- **SwiftUI**: Used to build the user interface and manage navigation with `NavigationStack`.

### 2. **iOS Frameworks**

- **ARKit**: Used to access LiDAR data and real-time depth information in order to generate a semantic description of detected objects.  
  Examples: `ARMeshAnchor`, `ARObjectAnchor`.

- **CoreML**: Used for machine learning models, including object recognition and obstacle classification.

- **Vision**: Used for object detection through the camera when needed, as a complement to LiDAR.

- **MapKit**: Used for GPS integration and map management.

- **CoreLocation**: Used for geolocation and real-time user positioning.

### 3. **Machine Learning / AI**

- **CreateML + CoreML + Phi-3 Mini**: Used to transform raw detection data such as object type, distance, and direction into natural, situation-aware descriptive sentences.

  Example:

  ```txt
  "Pole 2 meters on the left"
