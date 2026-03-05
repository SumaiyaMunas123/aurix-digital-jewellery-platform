import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class AddJewelleryScreen extends StatefulWidget {
  const AddJewelleryScreen({super.key});

  @override
  State<AddJewelleryScreen> createState() => _AddJewelleryScreenState();
}

class _AddJewelleryScreenState extends State<AddJewelleryScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _titleController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Ring';
  bool _showPrice = true;
  bool _isLoading = false;
  String? _jewellerId;

  final List<String> _categories = [
    'Ring',
    'Necklace',
    'Bracelet',
    'Earrings',
    'Bangle',
    'Custom Design'
  ];

  @override
  void initState() {
    super.initState();
    _loadJewellerId();
  }

  // Load jeweller ID from SharedPreferences (saved during login)
  Future<void> _loadJewellerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _jewellerId = prefs.getString('jeweller_id');
      });
      
      if (_jewellerId == null) {
        print('⚠️ No jeweller ID found. User might not be logged in.');
      } else {
        print('✅ Loaded jeweller ID: $_jewellerId');
      }
    } catch (e) {
      print('❌ Error loading jeweller ID: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if jeweller ID exists
    if (_jewellerId == null || _jewellerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please log in first'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading
    setState(() => _isLoading = true);

    try {
      print('📤 Submitting product...');
      
      // Call API to add product
      final result = await _apiService.addProduct(
        jewellerId: _jewellerId!,
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priceMode: _showPrice ? 'show_price' : 'ask_price',
        price: _showPrice && _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        weightGrams: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        metalType: 'Gold', // Default to Gold
      );

      setState(() => _isLoading = false);

      print('📥 Result: $result');

      // Check if successful
      if (result['success'] == true) {
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Product added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a bit for user to see message
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Go back to previous screen
        if (mounted) {
          Navigator.pop(context, true); // Pass true to indicate success
        }
      } else {
        if (!mounted) return;
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message'] ?? 'Failed to add product'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      print('❌ Exception: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Add Jewellery',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: gold),
                  SizedBox(height: 16),
                  Text(
                    'Adding product...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debug indicator (remove in production)
                    if (_jewellerId == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Not logged in. Please log in first.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '✅ Ready to add product',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Image upload placeholder
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_photo_alternate_outlined,
                            color: Colors.white54, size: 40),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _label('Title'),
                    _inputField(
                      controller: _titleController,
                      hint: 'e.g. 22K Gold Wedding Ring',
                    ),

                    const SizedBox(height: 16),

                    _label('Category'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: card,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _label('Weight (grams)'),
                    _inputField(
                      controller: _weightController,
                      hint: 'e.g. 8.5',
                      keyboard: TextInputType.number,
                      required: false,
                    ),

                    const SizedBox(height: 16),

                    _label('Price Visibility'),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Show Price'),
                            selected: _showPrice,
                            selectedColor: gold,
                            labelStyle: TextStyle(
                              color: _showPrice ? Colors.black : Colors.white,
                            ),
                            onSelected: (_) {
                              setState(() => _showPrice = true);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Ask Price'),
                            selected: !_showPrice,
                            selectedColor: gold,
                            labelStyle: TextStyle(
                              color: !_showPrice ? Colors.black : Colors.white,
                            ),
                            onSelected: (_) {
                              setState(() => _showPrice = false);
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_showPrice) ...[
                      const SizedBox(height: 16),
                      _label('Price (LKR)'),
                      _inputField(
                        controller: _priceController,
                        hint: 'e.g. 185000',
                        keyboard: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 16),

                    _label('Description'),
                    _inputField(
                      controller: _descriptionController,
                      hint: 'Add description...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading || _jewellerId == null ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: gold.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _jewellerId == null ? 'Please Log In' : 'Add Listing',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Required field';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}