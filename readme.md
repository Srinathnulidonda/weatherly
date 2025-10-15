## README.md

<div align="center">
  
# 🌤️ Weatherly

### Beautiful Weather Forecasts Everywhere

*A modern, cross-platform weather application delivering stunning visuals and accurate forecasts*

[![Website](https://img.shields.io/badge/🌐_Website-Live-brightgreen?style=for-the-badge)](https://weatherly-appnow.vercel.app/)
[![Download APK](https://img.shields.io/badge/📱_Download-APK-blue?style=for-the-badge)](https://drive.google.com/uc?export=download&id=10lPOkrf2HACA6ht-cirq_ubcW6adB_W2
)
[![Backend](https://img.shields.io/badge/🚀_API-Live-success?style=for-the-badge)](https://weatherly-app-bp4c.onrender.com/)

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Web%20%7C%20Android%20%7C%20iOS-lightgrey)

<br>


</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎨 **Beautiful Design**
- **Glassmorphism UI** with stunning visual effects
- **Dynamic themes** that adapt to weather and time
- **Immersive animations** for weather conditions
- **Responsive design** across all devices

### 📊 **Comprehensive Data**
- **Real-time weather** with automatic updates
- **7-day forecasts** with detailed information
- **Hourly predictions** for precise planning
- **Multiple metrics** (humidity, pressure, wind, UV)

</td>
<td width="50%">

### 🚀 **Advanced Features**
- **Location services** with GPS support
- **Search functionality** for worldwide cities
- **Saved locations** for quick access
- **Offline support** with cached data

### 🔧 **Developer Ready**
- **RESTful API** for easy integration
- **Modern tech stack** with best practices
- **Comprehensive documentation**
- **Error handling** and fallback systems

</td>
</tr>
</table>

---

## 🏗️ Architecture

<div align="center">

```mermaid
graph TB
    A[🌐 Frontend - Web App] --> D[🔗 API Gateway]
    B[📱 Mobile App - Flutter] --> D
    C[🤖 Future: Desktop App] --> D
    D --> E[🐍 Flask Backend]
    E --> F[🌤️ OpenWeatherMap API]
    E --> G[📦 Redis Cache]
    E --> H[📊 Rate Limiting]
    
    style A fill:#3b82f6,stroke:#1e40af,color:#fff
    style B fill:#06b6d4,stroke:#0891b2,color:#fff
    style C fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style E fill:#ef4444,stroke:#dc2626,color:#fff
    style F fill:#f59e0b,stroke:#d97706,color:#fff
```

</div>

### 🏛️ **Project Structure**

```
/weatherly
├── 🔧 Backend/           # Flask API Server
│   ├── app.py           # Main application
│   ├── requirements.txt # Dependencies
│   └── config/          # Configuration files
├── 🌐 Frontend/         # Web Application
│   ├── index.html       # Main page
│   ├── about.html       # About page
│   ├── css/            # Stylesheets
│   └── js/             # JavaScript modules
└── 📱 APP/             # Flutter Mobile App
    ├── lib/            # Dart source code
    ├── assets/         # Images and resources
    └── pubspec.yaml    # Dependencies
```

---

## 🚀 Quick Start

### 🌐 **Try It Now**

<div align="center">

| Platform | Access Method | Status |
|----------|---------------|--------|
| **🌐 Web** | [weatherly-appnow.vercel.app](https://weatherly-appnow.vercel.app/) | ✅ Live |
| **📱 Android** | [Download APK](https://drive.google.com/uc?export=download&id=10lPOkrf2HACA6ht-cirq_ubcW6adB_W2
) | ✅ Available |
| **🍎 iOS** | Coming Soon | 🔄 In Development |
| **🖥️ Desktop** | Coming Soon | 🔄 Planned |

</div>

### 🔧 **Local Development**

<details>
<summary><b>🐍 Backend Setup</b></summary>

```bash
# Navigate to backend directory
cd Backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export WEATHER_API_KEY="your_openweathermap_api_key"
export FLASK_ENV="development"

# Run the server
python app.py
```

**Environment Variables Required:**
```env
WEATHER_API_KEY=your_openweathermap_api_key
FLASK_ENV=development
REDIS_URL=redis://localhost:6379
SECRET_KEY=your_secret_key
```

</details>

<details>
<summary><b>🌐 Frontend Setup</b></summary>

```bash
# Navigate to frontend directory
cd Frontend

# Serve with any HTTP server
# Option 1: Python
python -m http.server 8000

# Option 2: Node.js
npx serve .

# Option 3: Live Server (VS Code Extension)
# Right-click index.html -> "Open with Live Server"
```

**Features:**
- 🎨 Glassmorphism design with backdrop filters
- 🌈 Dynamic theming based on weather conditions
- 📱 Fully responsive across all devices
- ⚡ Progressive Web App (PWA) support

</details>

<details>
<summary><b>📱 Mobile App Setup</b></summary>

```bash
# Navigate to app directory
cd APP

# Install Flutter dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk --release

# Build for iOS (macOS only)
flutter build ios --release
```

**Requirements:**
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode
- Connected device or emulator

</details>

---

## 🛠️ Tech Stack

<div align="center">

### **Backend**
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

### **Frontend** 
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![Bootstrap](https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)
![Tailwind](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)

### **Mobile**
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### **Deployment**
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)

</div>

---

## 📸 Screenshots

<div align="center">

### 🌐 **Web Application**

<table>
<tr>
<td align="center" width="33%">
<img src="https://i.postimg.cc/2yQBLdtp/Web-Home.png" alt="Web Home" style="border-radius: 8px;">
<br><sub><b>Home Screen</b></sub>
</td>
<td align="center" width="33%">
<img src="https://i.postimg.cc/sf7WLygJ/Web-Search.png" alt="Web Search" style="border-radius: 8px;">
<br><sub><b>Search Interface</b></sub>
</td>
<td align="center" width="33%">
<img src="https://i.postimg.cc/XYV9Fh31/Web-About.png" alt="Web About" style="border-radius: 8px;">
<br><sub><b>About Page</b></sub>
</td>
</tr>
</table>

### 📱 **Mobile Application**

<table>
<tr>
<td align="center" width="25%">
<img src="https://i.postimg.cc/SR6zYLvT/Splash-Screen.jpg" alt="Mobile Splash" style="border-radius: 8px;">
<br><sub><b>Splash Screen</b></sub>
</td>
<td align="center" width="25%">
<img src="https://i.postimg.cc/FzyJkbBq/Mobile-Home.jpg" alt="Mobile Home" style="border-radius: 8px;">
<br><sub><b>Weather Dashboard</b></sub>
</td>
<td align="center" width="25%">
<img src="https://i.postimg.cc/xCbmnVyX/Mobile-Search.jpg" alt="Mobile Search" style="border-radius: 8px;">
<br><sub><b>Location Search</b></sub>
</td>
<td align="center" width="25%">
<img src="https://i.postimg.cc/przKYMmH/Mobile-Settings.jpg" alt="Mobile Settings" style="border-radius: 8px;">
<br><sub><b>Settings Panel</b></sub>
</td>
</tr>
</table>

</div>

---

## 🔗 API Documentation

<details>
<summary><b>📋 Available Endpoints</b></summary>

### **Weather Endpoints**

#### Get Current Weather by City
```http
GET /api/v1/weather/{city}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "city": "London",
    "country": "GB",
    "temperature": {
      "current": 22,
      "feels_like": 24,
      "min": 18,
      "max": 26
    },
    "weather": {
      "main": "Clear",
      "description": "Clear sky",
      "icon": "01d"
    },
    "details": {
      "humidity": 65,
      "pressure": 1013,
      "wind_speed": 3.5,
      "visibility": 10
    }
  }
}
```

#### Get Weather by Coordinates
```http
GET /api/v1/weather/coordinates?lat={lat}&lon={lon}
```

#### Get 5-Day Forecast
```http
GET /api/v1/forecast/{city}
```

#### Bulk Weather Data
```http
POST /api/v1/weather/bulk
Content-Type: application/json

{
  "cities": ["London", "Paris", "Tokyo"]
}
```

### **Rate Limits**
- Weather endpoints: 30 requests/minute
- Forecast endpoints: 20 requests/minute  
- Bulk endpoints: 10 requests/minute

</details>

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

<div align="center">

[![Contributors](https://img.shields.io/badge/👥_Contributors-Welcome-brightgreen?style=for-the-badge)](#)
[![Issues](https://img.shields.io/badge/🐛_Issues-Open-blue?style=for-the-badge)](#)
[![Pull Requests](https://img.shields.io/badge/🔄_Pull_Requests-Open-orange?style=for-the-badge)](#)

</div>

### **Development Workflow**

1. **🍴 Fork** the repository
2. **🔀 Create** a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **💻 Make** your changes
4. **✅ Test** your implementation
5. **📝 Commit** your changes
   ```bash
   git commit -m "Add amazing feature"
   ```
6. **🚀 Push** to your branch
   ```bash
   git push origin feature/amazing-feature
   ```
7. **📥 Open** a Pull Request

### **Contribution Areas**

- 🐛 **Bug fixes** and issue resolution
- ✨ **New features** and enhancements
- 📚 **Documentation** improvements
- 🎨 **UI/UX** design improvements
- 🧪 **Testing** and quality assurance
- 🌍 **Internationalization** and localization

---

## 📄 License

<div align="center">

**MIT License** © 2025 Srinath Nulidonda

*Permission is hereby granted, free of charge, to any person obtaining a copy of this software...*

[![License](https://img.shields.io/badge/📄_License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 👨‍💻 Author

<div align="center">

### **Srinath Nulidonda**
*Full-Stack Developer & Mobile App Developer*

[![Portfolio](https://img.shields.io/badge/🌐_Portfolio-Visit-blue?style=for-the-badge)](https://srinathnulidonda.vercel.app/)
[![GitHub](https://img.shields.io/badge/📂_GitHub-Follow-black?style=for-the-badge&logo=github)](https://github.com/Srinathnulidonda)
[![Email](https://img.shields.io/badge/📧_Email-Contact-red?style=for-the-badge&logo=gmail)](mailto:srinathnulidonda.dev@gmail.com)

*Passionate about creating beautiful, functional applications that solve real-world problems.*

</div>

---

## 🙏 Acknowledgments

<div align="center">

**Special Thanks To:**

[![OpenWeatherMap](https://img.shields.io/badge/🌤️_OpenWeatherMap-Weather_Data-orange?style=for-the-badge)](https://openweathermap.org/)
[![Font Awesome](https://img.shields.io/badge/🎨_Font_Awesome-Icons-blue?style=for-the-badge)](https://fontawesome.com/)
[![Vercel](https://img.shields.io/badge/🚀_Vercel-Hosting-black?style=for-the-badge)](https://vercel.com/)
[![Render](https://img.shields.io/badge/☁️_Render-Backend_Hosting-green?style=for-the-badge)](https://render.com/)

</div>

---

<div align="center">

### 🌟 **Star this project if you found it helpful!**

[![Stars](https://img.shields.io/github/stars/srinathnulidonda/weatherly?style=social)](https://github.com/srinathnulidonda/weatherly/stargazers)
[![Forks](https://img.shields.io/github/forks/srinathnulidonda/weatherly?style=social)](https://github.com/srinathnulidonda/weatherly/network/members)
[![Watchers](https://img.shields.io/github/watchers/srinathnulidonda/weatherly?style=social)](https://github.com/srinathnulidonda/weatherly/watchers)

---

*Built with ❤️ and ☕ by SN*

**[⬆ Back to Top](#-weatherly)**

</div>