# ParkSense 🚗📱  
**Smart Parking System with Real-Time Vehicle Detection**  
*Final Year Diploma Project*  

---

## Table of Contents  
1. [Description](#description)  
2. [Key Features](#key-features)  
3. [Installation & Setup](#installation--setup)  
4. [Usage Guide](#usage-guide)  
5. [Project Structure](#project-structure)  
6. [Tech Stack](#tech-stack)  
7. [Contributing](#contributing)  
8. [License](#license)  
9. [Contact](#contact)  

---

## Description  
ParkSense is an automated parking management system that uses **computer vision** to detect vehicles in real-time via surveillance feeds and displays available parking slots on a mobile/web app. It aims to reduce parking search time and improve urban mobility efficiency.  

---

## Key Features  
- **Real-Time Car Detection**: Python-based OpenCV/YOLO model for vehicle detection.  
- **Dynamic Slot Counter**: Live updates of available/filled parking slots.  
- **Cross-Platform App**: Mobile (Flutter) and web (React) interfaces.  
- **Scalable Backend**: Flask API for handling detection data.  
- **Future Scope**: Notifications, historical data analytics, and multi-camera support.  

---

## Installation & Setup  

### Prerequisites  
- Python 3.8+  
- OpenCV, TensorFlow/PyTorch (for ML model)  
- Flask (backend API)  
- Flutter/React Native (mobile app) or React.js (web app)  

### Steps  
1. **Clone the Repository**  
   ```bash  
   git clone https://github.com/yourusername/parksense.git  
   cd parksense  
   pip install -r requirements.txt  
Configure Detection System

Update camera/IP feed settings in config/camera_settings.yaml.

Place pre-trained model weights (e.g., YOLOv5) in models/.

Start Backend Server

bash
Copy
cd backend  
python app.py  # Starts Flask API at http://localhost:5000  
Run the App

Mobile (Flutter):

bash
Copy
cd app/flutter_app  
flutter pub get  
flutter run  
Web (React):

bash
Copy
cd app/web  
npm install  
npm start  # Launches at http://localhost:3000  
Usage Guide
Detection System

Run car_detection.py to start vehicle detection from the camera feed.

Detected slots are sent to the backend API.

App Interface

Open the mobile/web app to view:

Total slots vs. available slots.

Real-time occupancy map (if supported).

API Endpoints

GET /slots: Fetch current parking availability.

POST /update: Update slot data (used internally by detection system).

Project Structure
Copy
parksense/  
├── backend/  
│   ├── app.py               # Flask API routes  
│   ├── car_detection.py     # CV logic for vehicle detection  
│   └── database.py          # SQLite slot management  
├── app/  
│   ├── flutter_app/         # Mobile app (cross-platform)  
│   └── web/                 # Web dashboard (React.js)  
├── config/  
│   ├── camera_settings.yaml # Camera/IP configurations  
│   └── model_config.json    # ML model parameters  
├── models/                  # Pre-trained ML models  
├── docs/                    # Project reports & diagrams  
└── requirements.txt         # Python dependencies  
Tech Stack
Backend: Python, Flask, OpenCV, SQLite

Machine Learning: YOLOv5 (or TensorFlow/PyTorch for custom models)

Frontend:

Mobile: Flutter (Dart)

Web: React.js, Chart.js (for analytics)

Tools: Git, Docker (containerization), Postman (API testing)

Contributing
Fork the repository.

Create a feature branch: git checkout -b feature/new-feature.

Test changes thoroughly.

Submit a pull request with a clear description.

Follow the Gitflow workflow.

License
This project is licensed under the MIT License. See LICENSE for details.
