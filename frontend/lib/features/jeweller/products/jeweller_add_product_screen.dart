import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import 'data/jeweller_product_store.dart';

class JewellerAddProductScreen extends StatefulWidget {
  final JewellerProduct? product;

  const JewellerAddProductScreen({
    super.key,
    this.product,
  });

  @override
  State<JewellerAddProductScreen> createState() =>
      _JewellerAddProductScreenState();
}

class _JewellerAddProductScreenState extends State<JewellerAddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _image;

  String _category = 'Ring';
  String _material = 'Gold';
  String _karat = '22K';
  String _weight = '2g - 5g';
  String _status = 'Active';

  bool _saving = false;

  final List<String> _categories = const [
    'Ring',
    'Necklace',
    'Pendant',
    'Bangle',
    'Bracelet',
    'Earrings',
    'Chain',
    'Anklet',
  ];

  final List<String> _materials = const [
    'Gold',
    'White Gold',
    'Rose Gold',
    'Silver',
    'Platinum',
  ];

  final List<String> _karats = const [
    '18K',
    '20K',
    '22K',
    '24K',
  ];

  final List<String> _weights = const [
    'Below 2g',
    '2g - 5g',
    '5g - 10g',
    '10g - 20g',
    '20g+',
  ];

  final List<String> _statuses = const [
    'Active',
    'Draft',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) return;

    _nameController.text = product.name;
    _priceController.text = product.price;
    _descriptionController.text = product.description;
    _category = product.category;
    _material = product.material;
    _karat = product.karat;
    _weight = product.weight;
    _status = product.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();

    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() => _image = file);
    } catch (_) {
      _showSnack('Failed to pick image.');
    }
  }

  Future<void> _saveProduct() async {
    HapticFeedback.mediumImpact();

    if (_image == null && widget.product == null) {
      _showSnack('Please upload a product image.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showSnack('Enter product name.');
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      _showSnack('Enter price.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showSnack('Enter description.');
      return;
    }

    setState(() => _saving = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _saving = false);

    final store = context.read<JewellerProductStore>();
    final editing = widget.product != null;
    final model = JewellerProduct(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      price: _priceController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      material: _material,
      karat: _karat,
      weight: _weight,
      status: _status,
      imagePath: _image?.path ?? widget.product?.imagePath ?? '',
    );

    if (editing) {
      store.updateProduct(model);
    } else {
      store.addProduct(model);
    }

    _showSnack(editing
        ? 'Product updated successfully.'
        : 'Product added successfully.');
    Navigator.pop(context);
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      widget.product == null ? 'Add Product' : 'Edit Product',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              _imagePickerCard(),
              const SizedBox(height: 16),
              _fieldCard(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Product Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _fieldCard(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Price (LKR)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _dropdownCard(
                label: 'Category',
                value: _category,
                items: _categories,
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropdownCard(
                      label: 'Material',
                      value: _material,
                      items: _materials,
                      onChanged: (v) => setState(() => _material = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdownCard(
                      label: 'Karat',
                      value: _karat,
                      items: _karats,
                      onChanged: (v) => setState(() => _karat = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropdownCard(
                      label: 'Weight',
                      value: _weight,
                      items: _weights,
                      onChanged: (v) => setState(() => _weight = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdownCard(
                      label: 'Status',
                      value: _status,
                      items: _statuses,
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _fieldCard(
                child: TextField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Product Description',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _saving ? null : _saveProduct,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.gold,
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Save Product',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerCard() {
    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
              child: _image == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 40,
                          color: AppColors.gold,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to upload product image',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return AurixGlassCard(
      child: child,
    );
  }

  Widget _dropdownCard({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
