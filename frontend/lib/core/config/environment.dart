class Environment {
  // Main backend (auth, products, chat, etc.)
  static const String baseUrl = "http://localhost:5000/api";

  // Dedicated AI backend (separate service in /AI BACKEND)
  static const String aiBaseUrl = "http://localhost:7000/api";
}