# 🚀 Quick Start Checklist

## Backend (macOS)

```bash
# Terminal 1 - Keep running while testing
cd /Users/sanathsajeevakumara/Desktop/jewelry_backend
python3 app.py

# You should see:
# 💎 Jewelry AI Backend Starting...
# 📡 Running on http://0.0.0.0:5000
```

## Flutter Setup

### 1. Copy Files to Flutter Project
```
Copy to lib/ folder:
- jewelry_ai_service.dart
- ai_text_prompt_screen.dart
```

### 2. Update pubspec.yaml
```yaml
dependencies:
  http: ^1.2.0
```

Then run:
```bash
flutter pub get
```

### 3. Update Backend URL (jewelry_ai_service.dart)
Choose based on your testing platform:

- **Android Emulator**: `http://10.0.2.2:5000`
- **iOS Simulator**: `http://localhost:5000`  
- **Real Phone**: `http://192.168.34.234:5000`

### 4. Add Internet Permission (Android)
File: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 5. Update main.dart
Replace your screen with AITextPromptScreen:
```dart
import 'ai_text_prompt_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AITextPromptScreen(),
      theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
```

### 6. Run Flutter App
```bash
flutter run
```

## ✅ Testing

1. **Backend Health**: App shows green ✅ if connected
2. **Generate Image**: Type prompt → Tap Generate → Wait 30-60 sec → Image appears

## ⏱️ Timing
- First request: 30-60 seconds (model loading)
- Subsequent requests: 10-20 seconds

## 📍 Your Mac IP
```
192.168.34.234
```

## 🆘 Debug
```bash
# Test backend directly
curl http://localhost:5000/health

# Should return: {"status": "ok"}
```

---

**Everything is ready! Just copy the Flutter files and run.** 🎨

