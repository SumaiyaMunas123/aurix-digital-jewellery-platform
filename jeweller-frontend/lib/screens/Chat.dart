import 'package:flutter/material.dart';

void main() {
  runApp(const AurixApp());
}

class AurixApp extends StatelessWidget {
  const AurixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurix',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
        fontFamily: 'Manrope',
        primaryColor: const Color(0xFFD4AF35),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF201D12),
        fontFamily: 'Manrope',
        primaryColor: const Color(0xFFD4AF35),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatsScreen(), // Home replaced with Chats screen
    SearchScreen(),
    GoldRateScreen(),
    AIDesignScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? const Color(0xFF2A271A) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF35),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Gold Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI Design',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

//// -------------------- SCREENS --------------------

// Chats Screen (original UI)
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              color: isDark ? const Color(0xFF2A271A) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : const Color(0xFF171612)),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_square,
                        color: isDark ? Colors.white : const Color(0xFF171612)),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            // Search Bar
            _SearchBar(isDark: isDark),
            // Chat List
            Expanded(
              child: ListView(
                children: const [
                  ChatTile(
                    name: 'Cartier',
                    message: 'Can you confirm the carat size?',
                    time: '10:45 AM',
                    unreadCount: 2,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBegMwNBH7t1kiFT0kFTFw6r9vENStZn8hSEXZVi3N7u_JpnMcbftTTtcdDBbowCT1MVdH4L_x7t6oGoxmwHTXXXktSX6T5uXuze6mElwbOTBLFkkklHwjucHmkszNIbHGyCrBg707mVzRK8oKlaHw5k7RRGKhPwvel8gWcDQ_W_lIfENF93js9r_6bXlvkKekgZ8h3kGP5NOyau3xkyDYo69Vhhzmv1inbbzNZBcVVWWEqoSusfLCfLpORUlsPCkKoaLryM8ryH7W_',
                  ),
                  ChatTile(
                    name: 'Tiffany & Co.',
                    message: 'Yes, we have that ring in stock.',
                    time: '9:30 AM',
                    showUnreadDot: true,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAmVhPBZUMMStxQxyIruqQeeucyhUvDxyL3xpwlz9bEpZgutC16BLrkAF8InwWi_ZOr1wW--zpXR5PWiNt3ddem8x6k4D0Cn4RqY7j1VpsJQwkwa7Uf6Kul1tdU2toOcyXC7m9WCe9YGwko7_OlGOqixv_WzQgYuexuR6Oohjfmpa6yxYJ3z0PNNH4oxkh6w-ll4LeQg64fXlEKKfG9OjoRYawYjt4i1bb-HmKzDePHZPb4JYuO7S-eixLZuWBmO_A2Zy07ywaqOZcZ',
                  ),
                  ChatTile(
                    name: 'Bvlgari',
                    message: 'Thank you for your purchase!',
                    time: 'Yesterday',
                    read: true,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCGAi0Ep5eUTAMT2_OeO46VotUQUqY-zyEysnz-0rEFlCtY1uafVEe--hbH4ZIcy9wXxU4DaOXM-bUQ1O5A_CyfG69_lNZRWkbKaPwRgQBfXREx-pY6AmSi3dN269iEAbaveauqlTBaZWORTDcjKgqsOc8MDArWqeZCCfIRp-zg6yeO6EC0ioQNByVDraTQgG3-pUVsnM-3J8UEM49JK59MqQ17A73d3sJh4m2KI0NHwCXo99oCyhgepknxQfKBaVZ_Bl_Nhi-lzF9M',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final bool isDark;
  const _SearchBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for jewellers or messages',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: isDark
              ? const Color(0xFF201D12)
              : const Color(0xFFF1F1F1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// Chat Tile Widget
class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final int unreadCount;
  final bool showUnreadDot;
  final bool read;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    this.unreadCount = 0,
    this.showUnreadDot = false,
    this.read = false,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          read ? FontWeight.w500 : FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: read ? Colors.grey : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: primaryColor,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (showUnreadDot)
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: primaryColor,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//// -------------------- OTHER SCREENS --------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(
        child: Text(
          '🔍 Search Jewellery',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GoldRateScreen extends StatelessWidget {
  const GoldRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gold Rate')),
      body: const Center(
        child: Text(
          '📈 Today’s Gold Rate',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AIDesignScreen extends StatelessWidget {
  const AIDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Design')),
      body: const Center(
        child: Text(
          '✨ AI Jewellery Design',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: const Center(
        child: Text(
          '👤 My Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}