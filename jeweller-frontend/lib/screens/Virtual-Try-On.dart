import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/* ================= APP ROOT ================= */
class MyApp extends StatelessWidget {
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    );
  }
}

/* ================= MAIN NAVIGATION ================= */
class MainNavigation extends StatefulWidget {
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    GoldRatePage(),
    AIDesignPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: MyApp.gold,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Gold"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/* ================= HOME PAGE ================= */
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50, // light background
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Virtual Try-On",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      uploadCard(),
                      SizedBox(height: 24),
                      actionButtons(),
                      SizedBox(height: 28),
                      guidelinesCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- BEAUTIFUL UPLOAD CARD ----------
  Widget uploadCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 42, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 60), // space for icon overlap
              Text(
                "Upload a clear photo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Tap here to start virtual try-on",
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // glowing camera icon
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [MyApp.gold.withOpacity(0.4), Colors.transparent],
                radius: 0.6,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: MyApp.gold,
              child: Icon(Icons.camera_alt, color: Colors.white, size: 36),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- MODERN BUTTONS ----------
  Widget actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.camera_alt, size: 20),
            label: Text("Take a Photo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyApp.gold,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.photo_library, size: 20, color: MyApp.gold),
            label: Text("Choose from Gallery",
                style: TextStyle(color: MyApp.gold)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: MyApp.gold, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- CLEAN GUIDELINES ----------
  Widget guidelinesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Photo Guidelines",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          guidelineRow(
              "For best results, upload a clear hand or neck image depending on the jewellery category."),
          guidelineRow("Ensure good lighting and a simple background."),
        ],
      ),
    );
  }

  Widget guidelineRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= OTHER PAGES ================= */
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => centerPage("Search Jewellery");
}

class GoldRatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => centerPage("Today Gold Rate");
}

class AIDesignPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => centerPage("AI Jewellery Design");
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => centerPage("My Profile");
}

Widget centerPage(String title) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
