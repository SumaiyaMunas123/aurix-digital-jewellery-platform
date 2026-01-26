import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LuxeJewellersPage(),
    );
  }
}

class LuxeJewellersPage extends StatefulWidget {
  const LuxeJewellersPage({super.key});

  @override
  State<LuxeJewellersPage> createState() => _LuxeJewellersPageState();
}

class _LuxeJewellersPageState extends State<LuxeJewellersPage> {
  int selectedTab = 0;
  int bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- AppBar ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "LUXE Jewellers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ---------------- Body ----------------
      body: IndexedStack(
        index: selectedTab,
        children: [
          buildTabContent(featuredTab()),
          buildTabContent(videosTab()),
          buildTabContent(reviewsTab()),
          buildTabContent(productsTab()),
        ],
      ),

      // ---------------- Bottom Navigation ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            bottomIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Price Check",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: "AI Design",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: "My Contact",
          ),
        ],
      ),
    );
  }

  // ---------------- Helper to build tab with scrolling ----------------
  Widget buildTabContent(Widget content) {
    return ListView(
      children: [
        bannerWidget(),
        shopCardWidget(),
        tabRowWidget(),
        content,
      ],
    );
  }

  // ---------------- Banner ----------------
  Widget bannerWidget() => Image.network(
        "https://images.unsplash.com/photo-1601121141461-9d6647bca1ed",
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );

  // ---------------- Shop Card ----------------
  Widget shopCardWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "LUXE Jewellers",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: Colors.amber),
                  ],
                ),
                const Text("Verified Seller",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                      ),
                      onPressed: () {},
                      child: const Text("Chat Now"),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Follow Shop",
                        style: TextStyle(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  // ---------------- Tabs Row ----------------
  Widget tabRowWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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

  Widget tabButton(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedTab == index ? const Color(0xFFD4AF37) : Colors.grey,
        ),
      ),
    );
  }

  // ---------------- Tab Contents ----------------
  Widget featuredTab() => productGrid(4);

  Widget videosTab() => Column(
        children: List.generate(
          3,
          (index) => ListTile(
            leading: const Icon(Icons.play_circle_fill,
                color: Color(0xFFD4AF37), size: 40),
            title: Text("Jewellery Video ${index + 1}"),
            subtitle: const Text("Watch our latest collection"),
          ),
        ),
      );

  Widget reviewsTab() => Column(
        children: List.generate(
          3,
          (index) => ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFD4AF37),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text("Customer ${index + 1}"),
            subtitle: const Text("Excellent quality and great service!"),
            trailing: const Icon(Icons.star, color: Colors.amber),
          ),
        ),
      );

  Widget productsTab() => productGrid(6);

  // ---------------- Product Grid ----------------
  Widget productGrid(int count) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: count,
      itemBuilder: (context, index) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            const Text(
              "Rs. 350,000",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}