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
    try {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('📡 [FRONTEND] Checking backend health...');
      print('═══════════════════════════════════════════════════════');

      final healthy = await JewelryAIService.isBackendHealthy();

      setState(() {
        _backendHealthy = healthy;
        _connectionStatus = healthy
            ? "✅ Backend Connected"
            : "❌ Backend Offline";
      });

      if (_backendHealthy) {
        print('✅ [FRONTEND] Backend Status: CONNECTED');
        print('📍 [FRONTEND] Backend URL: http://192.168.34.234:5000');
      } else {
        print('❌ [FRONTEND] Backend Status: OFFLINE');
      }
      print('═══════════════════════════════════════════════════════');
      print('');
    } catch (e) {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('❌ [FRONTEND] Health check error: $e');
      print('═══════════════════════════════════════════════════════');
      print('');
      setState(() {
        _backendHealthy = false;
        _connectionStatus = "❌ Connection Error";
      });
    }
  }

  Future<void> _generateDesign() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      print('⚠️ [FRONTEND] Empty prompt - user must enter text');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a design description')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedImageBase64 = null;
    });

    try {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('🚀 [FRONTEND] STARTING IMAGE GENERATION');
      print('═══════════════════════════════════════════════════════');
      print('📤 [FRONTEND] Prompt: "$prompt"');
      print('⏱️ [FRONTEND] Timestamp: ${DateTime.now()}');
      print('─────────────────────────────────────────────────────');

      final imageBase64 = await JewelryAIService.generateImage(prompt);

      print('✅ [FRONTEND] Image received successfully');
      print('📊 [FRONTEND] Image size: ${(imageBase64.length / 1024).toStringAsFixed(2)} KB');
      print('─────────────────────────────────────────────────────');

      setState(() {
        _generatedImageBase64 = imageBase64;
        _isGenerating = false;
      });

      print('🎨 [FRONTEND] Image decoded and displayed');
      print('═══════════════════════════════════════════════════════');
      print('');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Design generated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      final errorMsg = e.toString();
      print('');
      print('═══════════════════════════════════════════════════════');
      print('❌ [FRONTEND] GENERATION FAILED');
      print('═══════════════════════════════════════════════════════');
      print('⚠️ [FRONTEND] Error Type: ${e.runtimeType}');
      print('📝 [FRONTEND] Error Message: $errorMsg');
      print('⏱️ [FRONTEND] Timestamp: ${DateTime.now()}');
      print('═══════════════════════════════════════════════════════');
      print('');

      setState(() {
        _errorMessage = errorMsg;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${errorMsg.replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backend Connection Status
                    _buildConnectionStatus(isDark),
                    const SizedBox(height: 20),

                    _buildHeader(isDark),
                    const SizedBox(height: 24),
                    _buildPromptInput(isDark),
                    const SizedBox(height: 24),
                    _buildExamplePrompts(isDark),
                    const SizedBox(height: 24),

                    // Error Message Display
                    if (_errorMessage != null) _buildErrorMessage(isDark),

                    // Generated Image Display
                    if (_generatedImageBase64 != null)
                      _buildGeneratedResult(isDark),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGenerateButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? const Color(0xFF2A271A) : Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Text Prompt Design',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backendHealthy ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _backendHealthy ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _backendHealthy ? Icons.check_circle : Icons.error_circle,
            color: _backendHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _backendHealthy ? Colors.green.shade800 : Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
                if (_backendHealthy)
                  Text(
                    'http://192.168.34.234:5000',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.text_fields, color: primaryColor, size: 32),
            const SizedBox(width: 12),
            Text(
              'Describe Your Design',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Be specific about materials, style, gemstones, and design elements for best results.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Design Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Example: A modern 22K gold ring with small emerald stones arranged in a flower pattern...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Include: metal type, gemstones, style, cultural elements',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Example Prompts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_examplePrompts.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                _promptController.text = _examplePrompts[index];
                print('📌 [FRONTEND] Selected example prompt: "${_examplePrompts[index]}"');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A271A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _examplePrompts[index],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Generation Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedResult(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Design',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(_generatedImageBase64!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('💾 [FRONTEND] Design saved to My Designs');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Design saved to My Designs')),
                    );
                  },
                  icon: const Icon(Icons.bookmark, size: 20),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    print('📤 [FRONTEND] Design shared with jeweller');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Design shared with jeweller')),
                    );
                  },
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateDesign,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isGenerating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Generate Design',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      );
    );
  }
}

