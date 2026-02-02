import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Manrope',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: const Color(0xFF201D12),
        fontFamily: 'Manrope',
      ),
      home: const MainNavigation(),
    );
  }
}

// ================= MAIN NAVIGATION =================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    LuxeJewellersPage(),
    SearchScreen(),
    GoldRateScreen(),
    AIDesignScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: "Gold Rate"),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: "AI Design"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Account"),
        ],
      ),
    );
  }
}

// ================= LUXE HOME =================
class LuxeJewellersPage extends StatefulWidget {
  const LuxeJewellersPage({super.key});

  @override
  State<LuxeJewellersPage> createState() => _LuxeJewellersPageState();
}

class _LuxeJewellersPageState extends State<LuxeJewellersPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "LUXE Jewellers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          bannerWidget(),
          shopCardWidget(),
          tabRowWidget(),
          const SizedBox(height: 10),
          if (selectedTab == 0) productGrid(4),
          if (selectedTab == 1) videosTab(),
          if (selectedTab == 2) reviewsTab(),
          if (selectedTab == 3) productGrid(6),
        ],
      ),
    );
  }

  Widget bannerWidget() => Image.network(
        "https://images.unsplash.com/photo-1601121141461-9d6647bca1ed",
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );

  Widget shopCardWidget() => Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("LUXE Jewellers",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: Colors.amber),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("Verified Seller",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37)),
                      onPressed: () {},
                      child: const Text("Chat Now"),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFD4AF37))),
                      onPressed: () {},
                      child: const Text("Follow Shop",
                          style:
                              TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

  Widget tabRowWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            tabButton("Featured", 0),
            tabButton("Videos", 1),
            tabButton("Reviews", 2),
            tabButton("Products", 3),
          ],
        ),
      );

  Widget tabButton(String title, int index) => GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selectedTab == index
                ? const Color(0xFFD4AF37)
                : Colors.grey,
          ),
        ),
      );

  Widget videosTab() => Column(
        children: List.generate(
          3,
          (i) => const ListTile(
            leading: Icon(Icons.play_circle_fill,
                color: Color(0xFFD4AF37), size: 40),
            title: Text("Jewellery Video"),
            subtitle: Text("Watch our latest collection"),
          ),
        ),
      );

  Widget reviewsTab() => Column(
        children: List.generate(
          3,
          (i) => const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFD4AF37),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text("Customer"),
            subtitle: Text("Excellent quality and great service!"),
            trailing: Icon(Icons.star, color: Colors.amber),
          ),
        ),
      );

  Widget productGrid(int count) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: count,
        itemBuilder: (_, __) => Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  "https://images.unsplash.com/photo-1617038220319-276d3cfab638",
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              const Text("Gold Necklace"),
              const Text("Rs. 350,000",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
            ],
          ),
        ),
      );
}

// ================= OTHER SCREENS =================
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("🔍 Search Jewellery")));
}

class GoldRateScreen extends StatelessWidget {
  const GoldRateScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("📈 Gold Rate")));
}

class AIDesignScreen extends StatelessWidget {
  const AIDesignScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("✨ AI Design")));
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("👤 Account")));
}
