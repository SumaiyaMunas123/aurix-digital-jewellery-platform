import 'package:flutter/material.dart';

class AddJewelleryScreen extends StatefulWidget {
  const AddJewelleryScreen({super.key});

  @override
  State<AddJewelleryScreen> createState() => _AddJewelleryScreenState();
}

class _AddJewelleryScreenState extends State<AddJewelleryScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Ring';
  bool _showPrice = true;

  final List<String> _categories = [
    'Ring',
    'Necklace',
    'Bracelet',
    'Earrings',
    'Custom Design'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jewellery listing added (UI only)')),
      );
      Navigator.pop(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add Listing',
                    style: TextStyle(
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
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