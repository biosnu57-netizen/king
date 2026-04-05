// PINC Network - Core App
// AI #1: Core App Engineer
// Main entry point with 6 tabs: PINC Net, Wallet, Chat, Jobs, Games, Profile

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const PincNetworkApp());

// ==================== THEME ====================
class AppTheme {
  static const primaryDark = Color(0xFF0A0E14);
  static const surfaceColor = Color(0xFF1A2028);
  static const accentCyan = Color(0xFF00D4AA);
  static const accentGreen = Color(0xFF00FF94);
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.grey;
  static const error = Color(0xFFFF4444);
  
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: primaryDark,
    primaryColor: accentCyan,
    appBarTheme: const AppBarTheme(backgroundColor: primaryDark),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF121820),
      selectedItemColor: accentCyan,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

// ==================== MAIN APP ====================
class PincNetworkApp extends StatelessWidget {
  const PincNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINC Network',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthenticationWrapper(),
    );
  }
}

// Generate unique PINC ID
String generatePincId() {
  const uuid = Uuid();
  final bytes = uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
  return 'PINC-$bytes';
}

// ==================== AUTHENTICATION ====================
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;
  String _myPincId = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _myPincId = generatePincId();
      _isLoading = false;
    });
  }

  void _login() {
    setState(() => _isLoggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.accentCyan, AppTheme.accentGreen]),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Icon(Icons.shield, size: 60, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 20),
            const Text('PINC Network', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: AppTheme.accentCyan),
          ]),
        ),
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(
        initialPincId: _myPincId,
        onLogin: _login,
      );
    }

    return HomeScreen(myPincId: _myPincId);
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  final String initialPincId;
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.initialPincId, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _securityEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 60),
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accentCyan, AppTheme.accentGreen]),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: const Icon(Icons.shield, size: 80, color: AppTheme.primaryDark),
          ),
          const SizedBox(height: 24),
          const Text('PINC Network', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your PINC ID: ${widget.initialPincId}', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 16)),
          const SizedBox(height: 40),

          // Security toggles
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
            child: const Column(children: [
              Text('Security Options', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Enable Security', style: TextStyle(color: Colors.white)),
                subtitle: Text('6-phase authentication', style: TextStyle(color: Colors.grey, fontSize: 12)),
                value: true,
                activeColor: AppTheme.accentCyan,
                onChanged: null,
              ),
              SwitchListTile(
                title: Text('Biometric Login', style: TextStyle(color: Colors.white)),
                subtitle: Text('Fingerprint/Face unlock', style: TextStyle(color: Colors.grey, fontSize: 12)),
                value: false,
                activeColor: AppTheme.accentCyan,
                onChanged: null,
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surfaceColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Row(children: [Icon(Icons.info_outline, color: AppTheme.accentCyan, size: 20), SizedBox(width: 8), Text('No Phone Required', style: TextStyle(color: Colors.white))]),
              SizedBox(height: 8),
              Row(children: [Icon(Icons.lock, color: AppTheme.accentCyan, size: 20), SizedBox(width: 8), Text('Hardware-Bound Device', style: TextStyle(color: Colors.white))]),
              SizedBox(height: 8),
              Row(children: [Icon(Icons.privacy_tip, color: AppTheme.accentCyan, size: 20), SizedBox(width: 8), Text('Privacy-First Design', style: TextStyle(color: Colors.white))]),
            ]),
          ),
          const SizedBox(height: 40),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Enter PINC Network', style: TextStyle(color: AppTheme.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatefulWidget {
  final String myPincId;
  const HomeScreen({super.key, required this.myPincId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const PincNetTab(),
          const WalletTab(),
          ChatTab(myPincId: widget.myPincId),
          const JobsTab(),
          const GamesTab(),
          ProfileTab(myPincId: widget.myPincId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentCyan,
        backgroundColor: const Color(0xFF121820),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'PINC Net'),
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

// ==================== TAB 1: PINC NET (VPN) ====================
class PincNetTab extends StatefulWidget {
  const PincNetTab({super.key});

  @override
  State<PincNetTab> createState() => _PincNetTabState();
}

class _PincNetTabState extends State<PincNetTab> {
  bool _isConnected = false;
  String _selectedNode = 'Kenya';
  final List<Map<String, dynamic>> _nodes = [
    {'name': 'Kenya', 'flag': '🇰🇪', 'signal': 95},
    {'name': 'Germany', 'flag': '🇩🇪', 'signal': 88},
    {'name': 'USA', 'flag': '🇺🇸', 'signal': 82},
    {'name': 'Japan', 'flag': '🇯🇵', 'signal': 90},
    {'name': 'UK', 'flag': '🇬🇧', 'signal': 85},
    {'name': 'Nigeria', 'flag': '🇳🇬', 'signal': 78},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('PINC Net', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Connection Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: _isConnected 
                ? const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)])
                : LinearGradient(colors: [AppTheme.surfaceColor, AppTheme.surfaceColor.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isConnected ? [
                BoxShadow(color: AppTheme.accentCyan.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
              ] : null,
            ),
            child: Column(children: [
              Icon(
                _isConnected ? Icons.shield : Icons.shield_outlined,
                size: 60,
                color: _isConnected ? AppTheme.primaryDark : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                _isConnected ? 'Connected' : 'Not Protected',
                style: TextStyle(
                  color: _isConnected ? AppTheme.primaryDark : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _isConnected 
                  ? 'Your IP is protected'
                  : 'Tap to connect to PINC Net',
                style: TextStyle(
                  color: _isConnected ? AppTheme.primaryDark.withOpacity(0.8) : Colors.grey,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Connect Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => setState(() => _isConnected = !_isConnected),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.red : AppTheme.accentCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _isConnected ? 'Disconnect' : 'Connect to PINC Net',
                style: TextStyle(
                  color: _isConnected ? Colors.white : AppTheme.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Connect
          if (!_isConnected) ...[
            const Text('Quick Connect', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            Row(children: _nodes.take(4).map((node) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedNode = node['name'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedNode == node['name'] 
                      ? AppTheme.accentCyan.withOpacity(0.2)
                      : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedNode == node['name'] 
                      ? Border.all(color: AppTheme.accentCyan, width: 2)
                      : null,
                  ),
                  child: Column(children: [
                    Text(node['flag'] as String, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(node['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ]),
                ),
              ),
            )).toList()),
            const SizedBox(height: 24),
          ],

          // Status Cards
          _statusCard('Network Status', _isConnected ? 'Connected to 12,453 nodes' : 'Disconnected', Icons.hub),
          _statusCard('Your IP', _isConnected ? 'Protected • Hidden' : 'Exposed', Icons.visibility_off),
          _statusCard('Encryption', _isConnected ? 'AES-256 + Triple Layer' : 'Not Active', Icons.lock),
          _statusCard('Speed Ranking', _isConnected ? '#47 in your region' : '--', Icons.speed),
        ]),
      ),
    );
  }

  Widget _statusCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.accentCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.accentCyan),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}

// ==================== TAB 2: WALLET ====================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: const Column(children: [
              Text('PINC Balance', style: TextStyle(color: AppTheme.primaryDark, fontSize: 14)),
              SizedBox(height: 8),
              Text('0.00', style: TextStyle(color: AppTheme.primaryDark, fontSize: 48, fontWeight: FontWeight.bold)),
              Text('≈ \$0.00 USD', style: TextStyle(color: AppTheme.primaryDark)),
            ]),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(children: [
            _walletAction(Icons.arrow_upward, 'Send', () {}),
            _walletAction(Icons.arrow_downward, 'Receive', () {}),
            _walletAction(Icons.swap_horiz, 'Swap', () {}),
            _walletAction(Icons.add_circle, 'Buy', () {}),
          ]),
          const SizedBox(height: 24),

          // Info section
          const Align(alignment: Alignment.centerLeft, child: Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Text('No transactions yet', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),
              Text('Your transactions will appear here', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _walletAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Icon(icon, color: AppTheme.accentCyan),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

// ==================== TAB 3: CHAT ====================
class ChatTab extends StatefulWidget {
  final String myPincId;
  const ChatTab({super.key, required this.myPincId});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final List<Map<String, dynamic>> _conversations = [
    {'name': 'Alice', 'id': 'PINC-ABCD1234', 'msg': 'Encrypted message...', 'time': '2:34 PM', 'unread': 2},
    {'name': 'Papa Business', 'id': 'PINC-EFGH5678', 'msg': 'Payment verified ✓', 'time': '1:20 PM', 'unread': 0},
    {'name': 'Bob (Work)', 'id': 'PINC-IJKL9012', 'msg': 'Project ready', 'time': '11:45 AM', 'unread': 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentCyan,
        onPressed: () => _showNewChat(context),
        child: const Icon(Icons.edit, color: AppTheme.primaryDark),
      ),
      body: Column(children: [
        // Call Buttons
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF121820),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _callButton(Icons.call, 'Voice', () => _startCall(context, 'voice')),
            _callButton(Icons.videocam, 'Video', () => _startCall(context, 'video')),
            _callButton(Icons.screen_share, 'Screen', () => _startCall(context, 'screen')),
          ]),
        ),
        // Chat List
        Expanded(child: ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final c = _conversations[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accentCyan,
                child: Text(c['name'][0], style: const TextStyle(color: AppTheme.primaryDark)),
              ),
              title: Text(c['name'] as String, style: const TextStyle(color: Colors.white)),
              subtitle: Text(c['msg'] as String, style: const TextStyle(color: Colors.grey)),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (c['unread'] > 0) Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.accentCyan, borderRadius: BorderRadius.circular(10)),
                  child: Text('${c['unread']}', style: const TextStyle(color: AppTheme.primaryDark, fontSize: 10)),
                ),
              ]),
              onTap: () {},
            );
          },
        )),
      ]),
    );
  }

  Widget _callButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }

  void _startCall(BuildContext context, String type) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: Text('${type.toUpperCase()} Call', style: const TextStyle(color: Colors.white)),
      content: Text('Starting $type call via PINC Net...', style: const TextStyle(color: Colors.grey)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
    ));
  }

  void _showNewChat(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('New Chat', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Enter PINC ID to start secure chat', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'PINC ID',
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppTheme.primaryDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Start Chat')),
      ],
    ));
  }
}

// ==================== TAB 4: JOBS ====================
class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCyan,
          labelColor: AppTheme.accentCyan,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Find'),
            Tab(text: 'My Jobs'),
            Tab(text: 'Post'),
            Tab(text: 'Fundraise'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindJobs(),
          _buildMyJobs(),
          _buildPostJob(),
          _buildFundraiser(),
        ],
      ),
    );
  }

  Widget _buildFindJobs() {
    final jobs = [
      {'title': 'Mobile App Developer', 'budget': '500-1000 PINC', 'bids': 12, 'deadline': '3 days'},
      {'title': 'UI/UX Designer', 'budget': '300-500 PINC', 'bids': 8, 'deadline': '5 days'},
      {'title': 'Content Writer', 'budget': '100-200 PINC', 'bids': 15, 'deadline': '2 days'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.monetization_on, color: AppTheme.accentCyan, size: 16),
              const SizedBox(width: 4),
              Text(job['budget'] as String, style: const TextStyle(color: AppTheme.accentCyan)),
              const SizedBox(width: 16),
              const Icon(Icons.people, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text('${job['bids']} bids', style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.schedule, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(job['deadline'] as String, style: const TextStyle(color: Colors.grey)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan),
                child: const Text('Bid Now', style: TextStyle(color: AppTheme.primaryDark)),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildMyJobs() {
    return const Center(child: Text('No active jobs', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildPostJob() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          decoration: _inputDecoration('Job Title'),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          decoration: _inputDecoration('Description'),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: _inputDecoration('Budget (PINC)'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: _inputDecoration('Deadline'),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, padding: const EdgeInsets.all(16)),
            child: const Text('Post Job (3% fee)', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildFundraiser() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          decoration: _inputDecoration('Campaign Title'),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          decoration: _inputDecoration('Description'),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: _inputDecoration('Goal Amount (PINC)'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, padding: const EdgeInsets.all(16)),
            child: const Text('Create Fundraiser (9% fee)', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentCyan)),
    );
  }
}

// ==================== TAB 5: GAMES ====================
class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'Connect 4', 'icon': Icons.grid_4x4, 'players': '2 Players'},
      {'name': 'Tic Tac Toe', 'icon': Icons.apps, 'players': '2 Players'},
      {'name': 'Snake', 'icon': Icons.pest_control, 'players': '1 Player'},
      {'name': 'Tetris', 'icon': Icons.view_column, 'players': '1 Player'},
      {'name': 'Chess', 'icon': Icons.psychology, 'players': '2 Players'},
      {'name': 'Wordle', 'icon': Icons.spellcheck, 'players': '1 Player'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(title: const Text('Games', style: TextStyle(fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentCyan,
        onPressed: () => _showCreateChallenge(context),
        child: const Icon(Icons.add, color: AppTheme.primaryDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Challenge Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Row(children: [
              Icon(Icons.emoji_events, color: AppTheme.primaryDark, size: 40),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create Challenge', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                Text('Challenge friends to games with PINC wagers', style: TextStyle(color: AppTheme.primaryDark, fontSize: 12)),
              ])),
              Icon(Icons.arrow_forward_ios, color: AppTheme.primaryDark, size: 20),
            ]),
          ),
          const SizedBox(height: 24),

          // Games Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GestureDetector(
                onTap: () => _openGame(context, game['name'] as String),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(game['icon'] as IconData, color: AppTheme.accentCyan, size: 40),
                    const SizedBox(height: 8),
                    Text(game['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(game['players'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _openGame(BuildContext context, String gameName) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: Text(gameName, style: const TextStyle(color: Colors.white)),
      content: const Text('Game starting... (AI #3 will implement this)', style: TextStyle(color: Colors.grey)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }

  void _showCreateChallenge(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('Create Challenge', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Min wager: 20 PINC', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(
          decoration: _inputDeco('Wager Amount (PINC)'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create')),
      ],
    ));
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppTheme.primaryDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ==================== TAB 6: PROFILE ====================
class ProfileTab extends StatefulWidget {
  final String myPincId;
  const ProfileTab({super.key, required this.myPincId});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _selectedLanguage = 'English';
  final List<String> _languages = [
    'English', 'Swahili', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Arabic', 'Portuguese', 'Hindi',
    'Russian', 'Korean', 'Italian', 'Dutch', 'Swedish', 'Polish', 'Turkish', 'Vietnamese', 'Thai', 'Indonesian',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar & ID
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.accentCyan,
                child: Icon(Icons.person, size: 50, color: AppTheme.primaryDark),
              ),
              const SizedBox(height: 16),
              const Text('PINC User', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.myPincId.isNotEmpty ? widget.myPincId : 'PINC-XXXXXXXX', style: const TextStyle(color: AppTheme.accentCyan)),
            ]),
          ),
          const SizedBox(height: 24),

          // Language
          _sectionTitle('Language'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: DropdownButton(
              value: _selectedLanguage,
              isExpanded: true,
              dropdownColor: AppTheme.surfaceColor,
              underline: const SizedBox(),
              items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v as String),
            ),
          ),
          const SizedBox(height: 24),

          // Security
          _sectionTitle('Security'),
          const SizedBox(height: 12),
          _profileItem(Icons.shield, 'Security Settings', 'PIN, Biometric, Anti-theft'),
          _profileItem(Icons.lock, 'App Lock', 'Require password to open'),
          _profileItem(Icons.restore, 'Recovery', 'Backup keys'),
          _profileItem(Icons.admin_panel_settings, 'Admin Panel', 'Network controls (key required)'),
          const SizedBox(height: 24),

          // Community
          _sectionTitle('Community'),
          const SizedBox(height: 12),
          _profileItem(Icons.forum, 'Forums', 'Discuss with users'),
          _profileItem(Icons.campaign, 'Market Fundraiser', 'Share campaigns'),
          _profileItem(Icons.event, 'Host Event', 'Rap, Coding, Hacking'),
          const SizedBox(height: 24),

          // Settings
          _sectionTitle('Settings'),
          const SizedBox(height: 12),
          _profileItem(Icons.notifications, 'Notifications', 'Manage alerts'),
          _profileItem(Icons.cloud_upload, 'Upload/Download', 'Server settings'),
          _profileItem(Icons.compress, 'Compression', 'Data optimization'),
          _profileItem(Icons.info, 'About PINC', 'Network info'),
          _profileItem(Icons.help, 'Help & Support', 'Get help'),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)));
  }

  Widget _profileItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.accentCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.accentCyan),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }
}