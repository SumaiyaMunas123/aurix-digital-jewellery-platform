import 'package:flutter/foundation.dart';

class Environment {
  // Android emulator cannot reach host services via localhost.
  static String get _host {
    if (kIsWeb) return 'localhost';
    return defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
  }

  // Main backend (auth, products, chat, etc.)
  static String get baseUrl => 'http://$_host:5000/api';

  // Dedicated AI backend (separate service in /ai-backend)
  static String get aiBaseUrl => 'http://$_host:7000/api';

  // Gold rate microservice
  static String get goldRateUrl => 'http://$_host:6000/api';
}
