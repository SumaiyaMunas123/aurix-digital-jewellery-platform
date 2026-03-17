import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'jewelry_ai_service.dart';

class AITextPromptScreen extends StatefulWidget {
  const AITextPromptScreen({super.key});

  @override
  State<AITextPromptScreen> createState() => _AITextPromptScreenState();
}

class _AITextPromptScreenState extends State<AITextPromptScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedImageBase64;
  String? _errorMessage;
  bool _backendHealthy = false;
  String _connectionStatus = "Checking backend...";

  final List<String> _examplePrompts = [
    'A 22K gold necklace with lotus motifs and small ruby stones',
    'Modern diamond ring with geometric patterns',
    'Traditional Sri Lankan bangle with intricate carvings',
    'Elegant pearl earrings with gold filigree work',
    'Contemporary gold bracelet with minimalist design',
  ];

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    final healthy = await JewelryAIService.isBackendHealthy();
    setState(() {
      _backendHealthy = healthy;
    });
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showSnackbar("Please enter a design description", isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedImageBase64 = null;
    });

    try {
      final imageBase64 = await JewelryAIService.generateImage(prompt);
      setState(() {
        _generatedImageBase64 = imageBase64;
        _isGenerating = false;
      });
      _showSnackbar("Design generated successfully!");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isGenerating = false;
      });
      _showSnackbar(_errorMessage!, isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💎 AI Jewelry Designer"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Backend Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _backendHealthy ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _backendHealthy ? Icons.check_circle : Icons.error,
                      color: _backendHealthy ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _backendHealthy ? "Backend Connected ✅" : "Backend Offline ❌",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _backendHealthy ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Describe Your Dream Jewelry Design",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g., A gold ring with emerald stone and diamond accents...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateImage,
                  icon: _isGenerating ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? "Generating..." : "Generate Design"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_generatedImageBase64 != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Design", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(_generatedImageBase64!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      ),
                    ),
                  ],
                ),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

