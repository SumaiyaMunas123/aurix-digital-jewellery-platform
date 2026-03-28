import 'package:flutter/foundation.dart';

// Only import on non-web platforms - will fail gracefully on web
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount;

class GoogleAuthService {
  GoogleAuthService._();

  static GoogleSignIn? _googleSignIn;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return; // Skip on web
    if (_initialized) return;

    _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn?.initialize();
    _initialized = true;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Google Sign-In is not available on web platform.',
      );
    }

    await initialize();

    if (_googleSignIn?.supportsAuthenticate() ?? false) {
      return await _googleSignIn?.authenticate();
    }

    throw UnsupportedError(
      'Google authenticate() is not supported on this platform.',
    );
  }

  static Future<void> signOut() async {
    if (kIsWeb) return; // No-op on web
    await initialize();
    await _googleSignIn?.signOut();
  }
}