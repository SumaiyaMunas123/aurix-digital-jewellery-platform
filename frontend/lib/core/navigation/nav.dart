import 'package:flutter/material.dart';

class Nav {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop(BuildContext context) => Navigator.of(context).pop();

  static Future<T?> replace<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}