import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      "Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
                      "User Profile",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text("Profile details and editing will be connected later."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}