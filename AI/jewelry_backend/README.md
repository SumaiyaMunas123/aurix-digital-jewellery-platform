# 📂 Complete Project Structure

## Your Backend Folder
```
jewelry_backend/
├── 🔴 BACKEND CORE FILES
│   ├── app.py                          (1.9 KB) - Flask server
│   ├── requirements.txt                (49 B) - Python dependencies
│
├── 🎨 FLUTTER FILES (Copy to lib/)
│   ├── jewelry_ai_service.dart         (1.7 KB) - Service/API layer
│   └── ai_text_prompt_screen.dart      (6.2 KB) - UI Screen
│
├── 📚 DOCUMENTATION
│   ├── COMPLETE_SETUP.md               ← START HERE
│   ├── QUICKSTART.md                   ← Fast setup (5 min)
│   ├── SETUP_GUIDE.md                  ← Detailed guide
│   ├── API_DOCS.md                     ← API reference
│   └── main.dart.example               ← Example main.dart
│
└── 📋 PROJECT ROOT
    └── README.md                       ← This file
```

---

## 🎯 What Each File Does

### Backend (Already Set Up)
| File | Purpose | Size |
|------|---------|------|
| **app.py** | Flask server that connects to Hugging Face | 1.9 KB |
| **requirements.txt** | Python dependencies | 49 B |

### Flutter (Copy to your Flutter lib/ folder)
| File | Purpose | Size |
|------|---------|------|
| **jewelry_ai_service.dart** | Handles HTTP requests to backend API | 1.7 KB |
| **ai_text_prompt_screen.dart** | Beautiful UI for generating designs | 6.2 KB |

### Documentation (Read These!)
| File | Best For | Read Time |
|------|----------|-----------|
| **COMPLETE_SETUP.md** | Overview of everything | 5 min |
| **QUICKSTART.md** | Getting running ASAP | 3 min |
| **SETUP_GUIDE.md** | Detailed explanations | 10 min |
| **API_DOCS.md** | Technical reference | 8 min |

---

## 📥 Installation Steps

### 1️⃣ Backend is Ready
✅ Already configured in this folder
✅ Run: `python3 app.py`

### 2️⃣ Copy Dart Files
```
From: /Users/sanathsajeevakumara/Desktop/jewelry_backend/
Copy: jewelry_ai_service.dart
      ai_text_prompt_screen.dart
To:   YOUR_FLUTTER_PROJECT/lib/
```

### 3️⃣ Update Flutter Configuration
- [ ] Add `http: ^1.2.0` to `pubspec.yaml`
- [ ] Update URL in `jewelry_ai_service.dart`
- [ ] Add internet permission to `AndroidManifest.xml`
- [ ] Update `main.dart` (see main.dart.example)

### 4️⃣ Run
```bash
flutter run
```

---

## 🚀 Quick Command Reference

```bash
# Start Backend
cd /Users/sanathsajeevakumara/Desktop/jewelry_backend
python3 app.py

# Test Backend (from another terminal)
curl http://localhost:5000/health

# Flutter Setup
flutter pub get
flutter run
```

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR FLUTTER APP                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         AITextPromptScreen (UI)                  │  │
│  │  - Input field for design description            │  │
│  │  - Generate button                               │  │
│  │  - Image display                                 │  │
│  └───────────┬──────────────────────────────────────┘  │
│              │                                          │
│  ┌───────────▼──────────────────────────────────────┐  │
│  │   JewelryAIService (jewelry_ai_service.dart)     │  │
│  │  - HTTP client                                   │  │
│  │  - Base64 encoding/decoding                      │  │
│  │  - Error handling                                │  │
│  └───────────┬──────────────────────────────────────┘  │
│              │                                          │
│              │ HTTP POST /generate                      │
│              │ {"prompt": "..."}                        │
│              │                                          │
│              ▼                                          │
│              ════════════════════════════════════════   │
│              ║  YOUR MAC (BACKEND)                   ║  │
│              ║  http://192.168.34.234:5000           ║  │
│              ║  ════════════════════════════════════ ║  │
│              ║  ┌──────────────────────────────────┐ ║  │
│              ║  │   Flask App (app.py)             │ ║  │
│              ║  │  - Receives prompt               │ ║  │
│              ║  │  - Enhances with jewelry context │ ║  │
│              ║  │  - Connects to Hugging Face      │ ║  │
│              ║  └──────────────┬───────────────────┘ ║  │
│              ║                 │                     ║  │
│              ║                 │ HTTP POST           ║  │
│              ║                 │                     ║  │
│              ║                 ▼                     ║  │
│              ║         ┌──────────────────┐         ║  │
│              ║         │ Hugging Face API │         ║  │
│              ║         │ SDXL Model       │         ║  │
│              ║         │ (generates image)│         ║  │
│              ║         └────────┬─────────┘         ║  │
│              ║                  │                   ║  │
│              ║    (30-60 sec)   │                   ║  │
│              ║                  ▼                   ║  │
│              ║          Image bytes                 ║  │
│              ║             → Base64                 ║  │
│              ║                  │                   ║  │
│              ║    HTTP Response │                   ║  │
│              ║    with base64   │                   ║  │
│              └──────────────────┼──────────────────┘   │
│                                 │                      │
│                    ┌────────────▼─────────────┐         │
│                    │ Decode Base64            │         │
│                    │ Image.memory()           │         │
│                    │ Display on Screen        │         │
│                    └──────────────────────────┘         │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Dependencies

### Python (Backend)
```
Flask==2.3.3
flask-cors==4.0.0
requests==2.31.0
```

### Flutter (Frontend)
```dart
http: ^1.2.0
```

---

## 🎨 Features Included

✅ **Backend**
- Flask REST API
- Hugging Face Stable Diffusion XL integration
- CORS enabled for Flutter
- Error handling with proper HTTP codes
- Health check endpoint

✅ **Frontend**
- Beautiful Material Design UI
- Real-time backend connection indicator
- Image generation with loading state
- Error display
- Responsive design
- Base64 image decoding and display

---

## ⚙️ Configuration Details

### Backend URL
Update in `jewelry_ai_service.dart`:
```dart
// For different platforms:
"http://192.168.34.234:5000"     // Real device
"http://10.0.2.2:5000"            // Android emulator
"http://localhost:5000"           // iOS simulator
```

### Image Generation
Customizable in `app.py`:
```python
"width": 512,              # Change size
"height": 512,
"num_inference_steps": 30, # Quality (higher = slower)
"guidance_scale": 7.5,     # Prompt adherence
```

---

## 📊 Performance Expectations

| Scenario | Time | Notes |
|----------|------|-------|
| Health check | <1 sec | Instant |
| First image | 30-60 sec | Model loading |
| Next images | 10-20 sec | Model cached |
| App load | <2 sec | Check connection |

---

## 🔒 Security Notes

Current setup is **development only**. For production:

- [ ] Move token to environment variable
- [ ] Disable Flask debug mode
- [ ] Restrict CORS origins
- [ ] Add API authentication
- [ ] Use HTTPS
- [ ] Add rate limiting
- [ ] Don't commit secrets to Git

---

## 📱 Supported Platforms

| Platform | Support | URL |
|----------|---------|-----|
| iOS Simulator | ✅ | http://localhost:5000 |
| iOS Real Device | ✅ | http://192.168.34.234:5000 |
| Android Emulator | ✅ | http://10.0.2.2:5000 |
| Android Real Device | ✅ | http://192.168.34.234:5000 |
| Web | ✅ | http://localhost:5000 |

---

## 📞 Support & Troubleshooting

### Read These Files
1. **QUICKSTART.md** - For fast setup
2. **SETUP_GUIDE.md** - For detailed help
3. **API_DOCS.md** - For technical details

### Common Issues
- **"Backend Offline"** → Check `python3 app.py` is running
- **"Model loading"** → Wait 30 seconds, it's normal
- **"Connection refused"** → Check URL in jewelry_ai_service.dart
- **"Image not showing"** → Check internet permission in AndroidManifest.xml

---

## ✅ Final Checklist

Before running the app:
- [ ] Backend running: `python3 app.py`
- [ ] Dart files copied to Flutter `lib/`
- [ ] `pubspec.yaml` updated with `http: ^1.2.0`
- [ ] `jewelry_ai_service.dart` URL configured
- [ ] Internet permission added (Android)
- [ ] `main.dart` imports `AITextPromptScreen`
- [ ] `flutter pub get` completed

---

## 🎉 You're Ready!

Everything is set up. Just follow the steps in **QUICKSTART.md** and you'll be generating AI jewelry designs in 5 minutes! 💎

**Start with:** `QUICKSTART.md` or `COMPLETE_SETUP.md`

