import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize();
    _initialized = true;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    await initialize();

    if (_googleSignIn.supportsAuthenticate()) {
      return _googleSignIn.authenticate();
    }

    throw UnsupportedError(
      'Google authenticate() is not supported on this platform.',
    );
  }

  static Future<void> signOut() async {
    await initialize();
    await _googleSignIn.signOut();
  }
}