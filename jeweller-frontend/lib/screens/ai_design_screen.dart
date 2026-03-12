import 'package:flutter/material.dart';

class AIDesignScreen extends StatelessWidget {
  const AIDesignScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);
  static const Color aiPurple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF8F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              color: isDark ? const Color(0xFF2A271A) : Colors.white,
              child: Text(
                'AI Studio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF171612),
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Chat Card — main CTA
                    _buildFeatureCard(
                      context,
                      isDark: isDark,
                      icon: Icons.auto_awesome,
                      iconColor: aiPurple,
                      gradient: const [Color(0xFF7C3AED), Color(0xFF9F67FF)],
                      title: 'Ask Aurix AI',
                      subtitle: 'Chat with our AI jewelry consultant for personalized advice, recommendations & care tips',
                      buttonLabel: 'Start Chat',
                      onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                    ),
                    const SizedBox(height: 16),
                    // Text-to-Design Card
                    _buildFeatureCard(
                      context,
                      isDark: isDark,
                      icon: Icons.edit_note,
                      iconColor: primaryColor,
                      gradient: const [Color(0xFFD4AF35), Color(0xFFF5D670)],
                      title: 'Text to Design',
                      subtitle: 'Describe your dream jewelry and let AI generate a visual design for you',
                      buttonLabel: 'Create Design',
                      onTap: () => Navigator.pushNamed(context, '/ai-text-prompt'),
                    ),
                    const SizedBox(height: 16),
                    // Sketch Upload Card
                    _buildFeatureCard(
                      context,
                      isDark: isDark,
                      icon: Icons.brush,
                      iconColor: const Color(0xFFE67E22),
                      gradient: const [Color(0xFFE67E22), Color(0xFFF39C12)],
                      title: 'Sketch to Design',
                      subtitle: 'Upload a hand-drawn sketch and let AI refine it into a professional jewelry design',
                      buttonLabel: 'Upload Sketch',
                      onTap: () => Navigator.pushNamed(context, '/ai-sketch-upload'),
                    ),
                    const SizedBox(height: 16),
                    // My Designs Card
                    _buildFeatureCard(
                      context,
                      isDark: isDark,
                      icon: Icons.collections,
                      iconColor: const Color(0xFF2ECC71),
                      gradient: const [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      title: 'My AI Designs',
                      subtitle: 'View all your previously generated AI jewelry designs',
                      buttonLabel: 'View Designs',
                      onTap: () => Navigator.pushNamed(context, '/ai-my-designs'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradient,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A271A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
