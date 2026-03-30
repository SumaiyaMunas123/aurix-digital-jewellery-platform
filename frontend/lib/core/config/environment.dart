import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Environment {
  // Automatically select the correct "localhost" depending on the platform you're testing on.
  static String get _localHost {
    if (kIsWeb) {
      return 'localhost';
    } else if (Platform.isAndroid) {
      return '10.0.2.2'; // Standard loopback for Android emulators
    } else {
      return 'localhost'; // Windows/desktop/iOS simulator
    }
  }

  static String get baseUrl => "http://$_localHost:5000/api";
  static String get aiBackendUrl => "http://$_localHost:7000/api";
  static String get goldRateUrl => "http://$_localHost:6001";
}