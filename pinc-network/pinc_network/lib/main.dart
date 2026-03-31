import 'package:flutter/material.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
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
    ChatTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
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
            const SizedBox(height: 8),
            const Text('IP stays hidden', style: TextStyle(color: Color(0xFF00D4AA), fontSize: 12)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('Total Balance', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
                  SizedBox(height: 8),
                  Text('0.00 PINC', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('≈ \$0.00 USD', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAction(Icons.upload, 'Send'),
                _buildAction(Icons.download, 'Receive'),
                _buildAction(Icons.swap_horiz, 'Swap'),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Deposit/Withdraw', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildTile(Icons.credit_card, 'Credit Card', 'Via agents'),
            _buildTile(Icons.paid, 'P2P Agents', 'Country-based'),
            _buildTile(Icons.account_balance, 'PayPal', 'Third-party'),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Transfer Types', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildTransferCard('1', 'Subscription', 'Recurring', const Color(0xFF667eea)),
            _buildTransferCard('2', 'Wagers', 'Gaming escrow', const Color(0xFFf093fb)),
            _buildTransferCard('3', 'Savings', 'Protected', const Color(0xFF11998e)),
            _buildTransferCard('4', 'Service Payment', 'Jobs/freelance', const Color(0xFF4facfe)),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF00D4AA)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF00D4AA)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTransferCard(String n, String t, String s, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2028),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(n, style: TextStyle(color: c, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(s, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF0A0E14),
        actions: const [
          IconButton(icon: Icon(Icons.call), onPressed: null),
          IconButton(icon: Icon(Icons.video_call), onPressed: null),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E14),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Color(0xFF0A0E14)),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('A', style: TextStyle(color: Color(0xFF0A0E14)))),
            title: Text('Alice', style: TextStyle(color: Colors.white)),
            subtitle: Text('Hey! How are you?', style: TextStyle(color: Colors.grey)),
            trailing: Text('2:34 PM', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('B', style: TextStyle(color: Color(0xFF0A0E14)))),
            title: Text('Bob (Work)', style: TextStyle(color: Colors.white)),
            subtitle: Text('Project update ready', style: TextStyle(color: Colors.grey)),
            trailing: Text('1:20 PM', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('P', style: TextStyle(color: Color(0xFF0A0E14)))),
            title: Text('PINC Group', style: TextStyle(color: Colors.white)),
            subtitle: Text('New members joined', style: TextStyle(color: Colors.grey)),
            trailing: Text('12:45 PM', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Remote Jobs'),
          backgroundColor: const Color(0xFF0A0E14),
          bottom: const TabBar(
            labelColor: Color(0xFF00D4AA),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF00D4AA),
            tabs: [Tab(text: 'Find Jobs'), Tab(text: 'My Jobs'), Tab(text: 'Post Job')],
          ),
        ),
        backgroundColor: const Color(0xFF0A0E14),
        body: const TabBarView(
          children: [_FindJobsView(), _MyJobsView(), _PostJobView()],
        ),
      ),
    );
  }
}

class _FindJobsView extends StatelessWidget {
  const _FindJobsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _jobCard('Full Stack Developer', '500-1000 PINC', '5 needed', 'Software'),
        _jobCard('UI/UX Designer', '300-500 PINC', '2 needed', 'Design'),
        _jobCard('Content Writer', '100-200 PINC', '1 needed', 'Writing'),
        _jobCard('Video Tutoring', '200-400 PINC/hr', '3 needed', 'Tutoring'),
      ],
    );
  }

  Widget _jobCard(String title, String budget, String workers, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(type, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12)),
              ),
              const Spacer(),
              Text(budget, style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(workers, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('View'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                  child: const Text('Bid', style: TextStyle(color: Color(0xFF0A0E14))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyJobsView extends StatelessWidget {
  const _MyJobsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No active jobs yet\nBid on jobs to start earning!', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
    );
  }
}

class _PostJobView extends StatelessWidget {
  const _PostJobView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Job Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Description'),
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Budget (PINC)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
            child: const Text('Post Job (Escrow)', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          const Text('Money held in escrow until work approved', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF1A2028),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}

class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () {},
        icon: const Icon(Icons.add, color: Color(0xFF0A0E14)),
        label: const Text('Challenge', style: TextStyle(color: Color(0xFF0A0E14))),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.all(16),
        children: const [
          _GameTile(name: 'Chess', icon: '♔', players: '1,234'),
          _GameTile(name: 'Checkers', icon: '⭕', players: '856'),
          _GameTile(name: 'Tetris', icon: '🧱', players: '2,456'),
          _GameTile(name: 'Snake', icon: '🐍', players: '1,789'),
          _GameTile(name: 'Pong', icon: '🏓', players: '543'),
          _GameTile(name: 'Wordle', icon: '📝', players: '3,210'),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String name;
  final String icon;
  final String players;

  const _GameTile({required this.name, required this.icon, required this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
          Text('$players players', style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12)),
        ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('6-Phase Security', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _profileItem(Icons.shield, 'Security'),
            _profileItem(Icons.forum, 'Forums'),
            _profileItem(Icons.settings, 'Settings'),
            _profileItem(Icons.help, 'Help & Support'),
            _profileItem(Icons.info, 'About PINC'),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF00D4AA)),
          ),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}