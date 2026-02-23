# 🚀 Complete Setup Guide - Jewelry AI Backend + Flutter Frontend

## Backend Setup (Already Done ✅)

Your Flask backend is fully configured at `/Users/sanathsajeevakumara/Desktop/jewelry_backend/`

### Files Created:
- ✅ **app.py** - Flask server with Hugging Face integration
- ✅ **requirements.txt** - Python dependencies (Flask, flask-cors, requests)

### Backend Running:
```bash
python3 app.py
```

**Server Details:**
- Local: `http://localhost:5000`
- Network: `http://192.168.34.234:5000`
- Health Check: `GET /generate` endpoint at `/health`
- Generate Image: `POST /generate` with `{"prompt": "your text"}`

---

## 📱 Flutter Setup

### Step 1: Add Files to Flutter Project

Copy these 2 Dart files to your Flutter `lib/` folder:

1. **jewelry_ai_service.dart** - API service layer
2. **ai_text_prompt_screen.dart** - UI screen

### Step 2: Update pubspec.yaml

Add the `http` dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0  # ← Add this line
```

Then run:
```bash
flutter pub get
```

### Step 3: Add Internet Permission

**For Android:**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**For iOS:**
No additional permissions needed.

### Step 4: Update Backend URL

In `jewelry_ai_service.dart`, find this line:
```dart
static const String _baseUrl = "http://192.168.34.234:5000";
```

Change it based on where you're testing:

| Platform | URL |
|----------|-----|
| **Android Emulator** | `http://10.0.2.2:5000` |
| **iOS Simulator** | `http://localhost:5000` |
| **Real Phone (same WiFi)** | `http://192.168.34.234:5000` |
| **Real Phone (different WiFi)** | `http://YOUR_PC_IP:5000` |

---

## 🧪 Testing the Full App

### 1. Start Backend
```bash
cd /Users/sanathsajeevakumara/Desktop/jewelry_backend
python3 app.py
```

**Expected Output:**
```
💎 Jewelry AI Backend Starting...
📡 Running on http://0.0.0.0:5000
✅ Test: http://localhost:5000/health
 * Running on http://192.168.34.234:5000
```

### 2. Run Flutter App
```bash
flutter run
```

### 3. Test in App

1. **Backend Health Check**: The app automatically checks if backend is running
   - Green ✅ = Connected
   - Red ❌ = Offline

2. **Generate Design**:
   - Enter a prompt: "gold ring with sapphire stone"
   - Tap "Generate Design"
   - Wait 30-60 seconds (first request)
   - Image appears in the app

---

## ⚠️ Important Notes

### First Request Takes ~30-60 Seconds
This is normal! The Hugging Face model is being loaded for the first time. Subsequent requests will be much faster (10-15 seconds).

### Keep Backend Running
- The Flask server must stay running while testing
- Don't close the terminal running `python3 app.py`

### Network Troubleshooting

**If app shows "Backend Offline ❌":**

1. Check Flask server is running (see terminal output)
2. Check you're using the correct IP:
   ```bash
   # Find your Mac's IP
   ifconfig | grep "inet "
   ```
3. Make sure phone is on same WiFi as Mac
4. Try `http://localhost:5000/health` in Safari first

**If image generation fails:**

1. Check error message in app (red box)
2. Common errors:
   - "Model is loading..." → Wait 30 sec and retry
   - "Network error" → Check backend is running
   - "Connection refused" → Wrong IP address

---

## 📂 File Structure

```
jewelry_backend/
├── app.py                          # Flask server
├── requirements.txt                # Python dependencies
├── jewelry_ai_service.dart        # Service layer (copy to Flutter lib/)
└── ai_text_prompt_screen.dart     # UI screen (copy to Flutter lib/)

Flutter Project/
├── lib/
│   ├── jewelry_ai_service.dart    # ← Paste here
│   ├── ai_text_prompt_screen.dart # ← Paste here
│   └── main.dart                  # Update to use AITextPromptScreen
├── android/
│   └── app/src/main/AndroidManifest.xml # Add internet permission
└── pubspec.yaml                    # Add http: ^1.2.0
```

---

## 🔧 How It Works End-to-End

```
Flutter App
    ↓
[jewelry_ai_service.dart sends POST request]
    ↓
Flask Backend (app.py)
    ↓
[Sends prompt to Hugging Face API]
    ↓
Hugging Face (stabilityai/stable-diffusion-xl)
    ↓
[Returns image bytes]
    ↓
Flask encodes as base64
    ↓
[Returns JSON with base64 image]
    ↓
Flutter decodes base64 → Image.memory()
    ↓
Display image on screen
```

---

## 🎨 Customization

### Change Model
In `app.py`, modify this line:
```python
HF_URL = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"
```

Other models available:
- `stabilityai/stable-diffusion-3-medium` (more realistic)
- `stabilityai/stable-diffusion-2-1` (faster)

### Change Image Size
In `app.py`, modify payload:
```python
"width": 512,    # Change to 256/768/1024
"height": 512,   # Change to 256/768/1024
```

### Change Styling
In `app.py`, modify the prompt enhancement:
```python
full_prompt = f"professional jewelry photography, {prompt}, studio lighting, white background, 8k, photorealistic"
```

---

## ✅ Checklist Before Running

- [ ] Backend running on Mac (`python3 app.py`)
- [ ] Flutter `pubspec.yaml` has `http: ^1.2.0`
- [ ] `jewelry_ai_service.dart` in Flutter `lib/` folder
- [ ] `ai_text_prompt_screen.dart` in Flutter `lib/` folder
- [ ] Android internet permission added
- [ ] Backend URL set correctly in `jewelry_ai_service.dart`
- [ ] Both on same WiFi (for real device testing)

---

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Backend shows "Address already in use" | Run `lsof -i :5000` then kill the process, or use port 8000 |
| Flask not found | Run `python3 -m pip install flask flask-cors requests` |
| Image not loading in app | Check backend URL in jewelry_ai_service.dart |
| "Model is loading" error | Wait 30 seconds and try again (first request only) |
| Network error in app | Check Mac IP matches URL in jewelry_ai_service.dart |

---

**You're all set! 🚀 The app is ready to generate beautiful jewelry designs!**

