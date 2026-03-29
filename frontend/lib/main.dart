import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase for file uploads (like Jeweller registrations)
  await Supabase.initialize(
    url: 'https://mjzqcilffryycowlntcf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qenFjaWxmZnJ5eWNvd2xudGNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYyMjAwNjAsImV4cCI6MjA4MTc5NjA2MH0.xCm3AMS4v_bTLhhrZUsGmkMZtj2zvi3QvO1XRikG_Mk',
  );

  runApp(const AurixApp());
}