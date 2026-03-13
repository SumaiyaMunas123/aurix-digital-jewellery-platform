# jeweller_frontend

A new Flutter project.

## Fast Local Run (Web + Backend)

1. Start backend first (from project root):
	 `cd backend && npm install && npm run dev`
2. Start Flutter web with HTML renderer (faster startup, avoids CanvasKit CDN dependency):
	 `cd jeweller-frontend && flutter run -d chrome --web-renderer html`

## API Base URL

- Default behavior is platform-aware:
	- Web/desktop: `http://localhost:5000`
	- Android emulator: `http://10.0.2.2:5000`
- To override manually:
	`flutter run -d chrome --web-renderer html --dart-define=API_BASE_URL=http://localhost:5000`

If you run backend on another machine/IP, pass that IP in `API_BASE_URL`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
