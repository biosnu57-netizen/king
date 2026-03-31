import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PincNetworkApp());
}

class PincNetworkApp extends StatelessWidget {
  const PincNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINC Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00D4AA),
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4AA),
          secondary: Color(0xFF00FF94),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = const [
    VpnTab(),
    WalletTab(),
    CommunityTab(),
    JobsTab(),
    GamesTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00D4AA),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF121820),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'VPN'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class VpnTab extends StatelessWidget {
  const VpnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC VPN'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.shield, size: 60, color: Color(0xFF0A0E14)),
            ),
            const SizedBox(height: 24),
            const Text('P2P Mesh Network', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('8-thread parallel processing', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: const Text('Connect', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC Wallet'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Balance', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('0.00 PINC', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.upload, 'Send'),
                _buildActionButton(Icons.download, 'Receive'),
                _buildActionButton(Icons.swap_horiz, 'Swap'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2028),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00D4AA)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: const Center(child: Text('Community features', style: TextStyle(color: Colors.grey))),
    );
  }
}

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Jobs'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: const Center(child: Text('Jobs marketplace', style: TextStyle(color: Colors.grey))),
    );
  }
}

class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'Chess', 'icon': '♔'},
      {'name': 'Checkers', 'icon': '⭕'},
      {'name': 'Tetris', 'icon': '🧱'},
      {'name': 'Snake', 'icon': '🐍'},
      {'name': 'Pong', 'icon': '🏓'},
      {'name': 'Wordle', 'icon': '📝'},
    ];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Games'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A2028),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(games[index]['icon']!, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(games[index]['name']!, style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 50, color: Color(0xFF0A0E14)),
            ),
            const SizedBox(height: 16),
            const Text('User', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('6-Phase Security Active', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}