import 'package:flutter/material.dart';

import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'User Profile');
  final _emailController = TextEditingController(text: 'user@aurix.com');
  final _phoneController = TextEditingController(text: '+94 77 000 0000');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              const AurixGlassCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      child: Icon(Icons.person_rounded, size: 34),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Basic Details',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _fieldCard(
                context,
                label: 'Name',
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 10),
              _fieldCard(
                context,
                label: 'Email',
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 10),
              _fieldCard(
                context,
                label: 'Phone',
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile details updated locally.')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFFD4AF37),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
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

  Widget _fieldCard(
    BuildContext context, {
    required String label,
    required Widget child,
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
          child,
        ],
      ),
    );
  }
}
