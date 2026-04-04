import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(const PincNetworkApp());

// ==================== MAIN APP ====================
class PincNetworkApp extends StatelessWidget {
  const PincNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINC Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        primaryColor: const Color(0xFF00D4AA),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

// ==================== AUTHENTICATION (NO PHONE - AUTO PINC ID) ====================
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _myPincId = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      // Auto-login for demo
      _myPincId = _generatePincId();
      _isLoggedIn = false;
    });
  }

  String _generatePincId() {
    final random = Random();
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String id = 'PINC-';
    for (int i = 0; i < 8; i++) {
      id += chars[random.nextInt(chars.length)];
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E14),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA))),
      );
    }
    if (!_isLoggedIn) {
      return LoginScreen(onLogin: () => setState(() => _isLoggedIn = true), initialPincId: _myPincId);
    }
    return HomeScreen(myPincId: _myPincId);
  }
}

// ==================== LOGIN SCREEN (NO PHONE VERIFICATION) ====================
class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final String initialPincId;

  const LoginScreen({super.key, required this.onLogin, required this.initialPincId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pincId = '';
  bool _isCreating = false;
  bool _securityEnabled = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _pincId = widget.initialPincId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield, size: 50, color: Color(0xFF0A0E14)),
              ),
              const SizedBox(height: 24),
              const Text('PINC Network', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Global Private Platform', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // Your PINC ID
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Text('Your Unique PINC ID', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_pincId, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    IconButton(icon: const Icon(Icons.copy, color: Colors.grey, size: 18), onPressed: () {}),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Use this ID to receive PINC, chat, call', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 20),

              // Anti-Theft Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Device Security', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _toggleTile('Enable Anti-Theft', _securityEnabled, (v) => setState(() => _securityEnabled = v)),
                  _toggleTile('Biometric Lock', _biometricEnabled, (v) => setState(() => _biometricEnabled = v)),
                  const SizedBox(height: 8),
                  const Text('• Shutdown protection\n• Device cannot be factory reset\n• Location tracking when stolen', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 24),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : () {
                    setState(() => _isCreating = true);
                    Future.delayed(const Duration(seconds: 1), () {
                      widget.onLogin();
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
                  child: _isCreating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0E14)))
                      : const Text('Create Account', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('No phone number required\nNo KYC - Fully Anonymous', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF00D4AA)),
      ]),
    );
  }
}

// ==================== HOME SCREEN (6 TABS) ====================
class HomeScreen extends StatefulWidget {
  final String myPincId;

  const HomeScreen({super.key, required this.myPincId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  List<Widget> _tabs(String myPincId) => [
    VpnTab(myPincId: myPincId),
    WalletTab(myPincId: myPincId),
    ChatTab(myPincId: myPincId),
    JobsTab(myPincId: myPincId),
    GamesTab(myPincId: myPincId),
    ProfileTab(myPincId: myPincId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs(widget.myPincId)[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00D4AA),
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

// ==================== VPN TAB ====================
class VpnTab extends StatelessWidget {
  final String myPincId;
  const VpnTab({super.key, required this.myPincId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC VPN'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), borderRadius: BorderRadius.circular(20)),
            child: const Column(children: [
              Icon(Icons.shield, size: 50, color: Color(0xFF0A0E14)),
              SizedBox(height: 8),
              Text('P2P Mesh Network', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 20, fontWeight: FontWeight.bold)),
              Text('IP Preserved • Encrypted', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
            child: const Text('Connect', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold, fontSize: 18)),
          )),
          const SizedBox(height: 24),
          _infoCard('Network Status', 'Connected to 12,453 nodes'),
          _infoCard('Your IP', 'Protected • Hidden'),
          _infoCard('Encryption', 'AES-256 + Triple Layer'),
          _infoCard('Speed Ranking', '#47 in your region'),
        ]),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.info_outline, color: Color(0xFF00D4AA)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}

// ==================== WALLET TAB (With Deposit/Withdraw Fees) ====================
class WalletTab extends StatefulWidget {
  final String myPincId;
  const WalletTab({super.key, required this.myPincId});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _balance = 0.0;
  String _currency = 'USD';
  double _rate = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC Wallet'), backgroundColor: const Color(0xFF0A0E14),
        bottom: TabBar(controller: _tabController, labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
          tabs: const [Tab(text: 'Balance'), Tab(text: 'Send'), Tab(text: 'Receive')])),
      backgroundColor: const Color(0xFF0A0E14),
      body: TabBarView(controller: _tabController, children: [
        _buildBalanceTab(),
        _buildSendTab(),
        _buildReceiveTab(),
      ]),
    );
  }

  Widget _buildBalanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            const Text('Total Balance', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
            const SizedBox(height: 8),
            Text('${_balance.toStringAsFixed(2)} PINC', style: const TextStyle(color: Color(0xFF0A0E14), fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('≈ \$${(_balance * _rate).toStringAsFixed(2)} $_currency', style: const TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
          ])),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: Text('Deposit Methods (Free)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        _depositTile(Icons.currency_bitcoin, 'Crypto (USDT/USDC)', 'BSC Network - No fees'),
        _depositTile(Icons.account_balance, 'PayPal Business', 'Instant - No fees'),
        _depositTile(Icons.people, 'P2P Agents', 'Local cash - No fees'),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: Text('Withdraw Fees', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        _withdrawFeeTile('100 - 1,000', '3 PINC'),
        _withdrawFeeTile('1,001 - 3,000', '10 PINC'),
        _withdrawFeeTile('3,001 - 10,000', '19 PINC'),
        _withdrawFeeTile('10,001 - 39,000', '35 PINC'),
        _withdrawFeeTile('39,001 - 60,000', '45 PINC'),
        _withdrawFeeTile('60,001 - 90,000', '60 PINC'),
        _withdrawFeeTile('90,001 - 500,000', '74 PINC'),
        _withdrawFeeTile('500,001+', '103 PINC'),
        const SizedBox(height: 16),
        const Text('Min withdrawal: 100 PINC\nP2P transfers: FREE (unlimited)', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(decoration: InputDecoration(labelText: 'Recipient PINC ID', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: 'Amount (PINC)', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(dropdownColor: const Color(0xFF1A2028), decoration: InputDecoration(labelText: 'Transfer Type', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: const [DropdownMenuItem(value: '1', child: Text('Subscription')), DropdownMenuItem(value: '2', child: Text('Wagers')), DropdownMenuItem(value: '3', child: Text('Savings')), DropdownMenuItem(value: '4', child: Text('Service Payment')), DropdownMenuItem(value: '5', child: Text('Papa Business'))],
          onChanged: (v) {}, value: '1'),
        const SizedBox(height: 16),
        const Text('P2P Transfer: FREE\nInternal transfers unlimited up to 1 Trillion PINC', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
          child: const Text('Send PINC', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold)))),
      ]),
    );
  }

  Widget _buildReceiveTab() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 40),
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          const Text('Your PINC ID', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(widget.myPincId, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          IconButton(icon: const Icon(Icons.qr_code, size: 80, color: Color(0xFF00D4AA)), onPressed: () {}),
          const Text('Scan to receive', style: TextStyle(color: Colors.grey)),
        ])),
    ]));
  }

  Widget _depositTile(IconData icon, String title, String sub) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00D4AA))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        const Text('FREE', style: TextStyle(color: Colors.green)),
      ]));
  }

  Widget _withdrawFeeTile(String range, String fee) {
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(child: Text(range, style: const TextStyle(color: Colors.white))),
        Text(fee, style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
      ]));
  }
}

// ==================== CHAT TAB (With Voice/Video/Screen Share) ====================
class ChatTab extends StatefulWidget {
  final String myPincId;
  const ChatTab({super.key, required this.myPincId});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final List<_ChatConversation> _conversations = [
    _ChatConversation(id: 'PINC-ABCD1234', name: 'Alice', lastMessage: 'Encrypted message...', time: '2:34 PM', unread: 2),
    _ChatConversation(id: 'PINC-EFGH5678', name: 'Papa Business', lastMessage: 'Payment verified ✓', time: '1:20 PM', unread: 0),
    _ChatConversation(id: 'PINC-IJKL9012', name: 'Bob (Work)', lastMessage: 'Project ready', time: '11:45 AM', unread: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), backgroundColor: const Color(0xFF0A0E14),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ]),
      backgroundColor: const Color(0xFF0A0E14),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () => _showNewChat(context),
        child: const Icon(Icons.edit, color: Color(0xFF0A0E14)),
      ),
      body: Column(children: [
        // Call Buttons
        Container(padding: const EdgeInsets.all(12), color: const Color(0xFF121820),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _callButton(Icons.call, 'Voice', () => _startCall(context, 'voice')),
            _callButton(Icons.videocam, 'Video', () => _startCall(context, 'video')),
            _callButton(Icons.screen_share, 'Screen', () => _startCall(context, 'screen')),
          ])),
        // Chat List
        Expanded(child: ListView.builder(itemCount: _conversations.length, itemBuilder: (context, index) {
          final c = _conversations[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFF00D4AA), child: Text(c.name[0], style: const TextStyle(color: Color(0xFF0A0E14)))),
            title: Text(c.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(c.lastMessage, style: const TextStyle(color: Colors.grey)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(c.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (c.unread > 0) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF00D4AA), borderRadius: BorderRadius.circular(10)),
                child: Text('${c.unread}', style: const TextStyle(color: Color(0xFF0A0E14), fontSize: 10))),
            ]),
            onTap: () {},
          );
        })),
      ]),
    );
  }

  Widget _callButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, color: const Color(0xFF00D4AA), size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white))])));
  }

  void _startCall(BuildContext context, String type) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: Text('${type.toUpperCase()} Call', style: const TextStyle(color: Colors.white)),
      content: Text('Starting $type call...', style: const TextStyle(color: Colors.grey)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
    ));
  }

  void _showNewChat(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: const Text('New Chat', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: 'Enter PINC ID', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
        const Text('Find users by their unique PINC ID\nNo phone number needed', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Start Chat')),
      ],
    ));
  }
}

class _ChatConversation {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  _ChatConversation({required this.id, required this.name, required this.lastMessage, required this.time, required this.unread});
}

// ==================== JOBS TAB ====================
class JobsTab extends StatefulWidget {
  final String myPincId;
  const JobsTab({super.key, required this.myPincId});

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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title: const Text('Jobs'), backgroundColor: const Color(0xFF0A0E14),
          bottom: TabBar(controller: _tabController, labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
            tabs: const [Tab(text: 'Find'), Tab(text: 'My Jobs'), Tab(text: 'Post'), Tab(text: 'Fundraise')])),
        backgroundColor: const Color(0xFF0A0E14),
        body: TabBarView(controller: _tabController, children: [
          _buildFindJobs(),
          const Center(child: Text('No active jobs', style: TextStyle(color: Colors.grey))),
          _buildPostJob(),
          _buildFundraise(),
        ]),
      ),
    );
  }

  Widget _buildFindJobs() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _jobCard('Full Stack Developer', '500-1000 PINC', '5 needed', 'Software'),
      _jobCard('UI/UX Designer', '300-500 PINC', '2 needed', 'Design'),
      _jobCard('Content Writer', '100-200 PINC', '1 needed', 'Writing'),
    ]);
  }

  Widget _jobCard(String title, String budget, String workers, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(type, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12))),
          const Spacer(),
          Text(budget, style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text('$workers • 3% fee to post', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('View'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
            child: const Text('Bid', style: TextStyle(color: Color(0xFF0A0E14))))),
        ]),
      ]),
    );
  }

  Widget _buildPostJob() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Job Title', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      TextField(maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Budget (PINC)', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fee: 3% of job value', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text('9% fee when worker receives payment', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
        child: const Text('Post Job (Escrow)', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold))),
    ]));
  }

  Widget _buildFundraise() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Campaign Title', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 16),
      TextField(maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 16),
      TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Goal Amount (PINC)', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text('Lock Period', style: TextStyle(color: Colors.white)), subtitle: const Text('Cannot withdraw until goal reached', style: TextStyle(color: Colors.grey, fontSize: 12)), value: true, onChanged: (v) {}, activeColor: const Color(0xFF00D4AA)),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: const Text('Platform Fee: 9% of total raised\nUnlimited fundraisers', style: TextStyle(color: Colors.grey, fontSize: 12))),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
        child: const Text('Create Fundraiser', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold))),
    ]));
  }
}

// ==================== GAMES TAB (Built-in + External + Challenges) ====================
class GamesTab extends StatefulWidget {
  final String myPincId;
  const GamesTab({super.key, required this.myPincId});

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Games'), backgroundColor: const Color(0xFF0A0E14),
          bottom: TabBar(controller: _tabController, labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
            tabs: const [Tab(text: 'Play'), Tab(text: 'Challenges'), Tab(text: 'Leagues')])),
        backgroundColor: const Color(0xFF0A0E14),
        body: TabBarView(controller: _tabController, children: [
          _buildBuiltInGames(),
          _buildChallenges(),
          _buildLeagues(),
        ]),
      ),
    );
  }

  Widget _buildBuiltInGames() {
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, padding: const EdgeInsets.all(16),
      children: [
        _gameTile('Chess', '♔', const Color(0xFF8B4513), () => _openGame('Chess')),
        _gameTile('Checkers', '⭕', const Color(0xFFDC143C), () => _openGame('Checkers')),
        _gameTile('Tetris', '🧱', const Color(0xFF00CED1), () => _openGame('Tetris')),
        _gameTile('Snake', '🐍', const Color(0xFF32CD32), () => _openGame('Snake')),
        _gameTile('Pong', '🏓', const Color(0xFFFF6347), () => _openGame('Pong')),
        _gameTile('Wordle', '📝', const Color(0xFFFFD700), () => _openGame('Wordle')),
      ],
    );
  }

  Widget _gameTile(String name, String icon, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white)),
        Text('Tap to play', style: TextStyle(color: color, fontSize: 12)),
      ])));
  }

  Widget _buildChallenges() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      // Create Challenge Button
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          const Row(children: [Icon(Icons.emoji_events, color: Color(0xFF00D4AA)), SizedBox(width: 8), Text('Create Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          const Text('Global: 1,560 PINC (30-min broadcast)\nP2P: 7% of winner + up to 5% creator fee', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => _createChallenge(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
            child: const Text('Create Challenge', style: TextStyle(color: Color(0xFF0A0E14)))),
        ])),
      const SizedBox(height: 24),
      // External Games Linking
      const Align(alignment: Alignment.centerLeft, child: Text('Link External Games', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _gameChip('🎮 PlayStation', 'Link PSN'),
        _gameChip('❎ Xbox', 'Link Xbox'),
        _gameChip('💻 Steam', 'Link Steam'),
        _gameChip('📱 Mobile', 'Link ID'),
      ]),
      const SizedBox(height: 24),
      // Active Challenges
      const Align(alignment: Alignment.centerLeft, child: Text('Active Challenges', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      const SizedBox(height: 12),
      _challengeCard('FIFA Tournament', '10 participants', 'Entry: 50 PINC', 'Prize: 500 PINC'),
      _challengeCard('Chess League', '5 participants', 'Entry: 100 PINC', 'Prize: 1,000 PINC'),
    ]));
  }

  Widget _challengeCard(String title, String participants, String entry, String prize) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10))),
        ]),
        const SizedBox(height: 8),
        Text(participants, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(children: [Text(entry, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12)), const SizedBox(width: 16), Text(prize, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12))]),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.symmetric(vertical: 8)),
          child: const Text('Join', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 12))),
      ]));
  }

  Widget _buildLeagues() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          const Text('League System', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Up to 50 players per league\n9% of total pool to platform\nPrizes for positions 1-10', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
            child: const Text('Create League', style: TextStyle(color: Color(0xFF0A0E14)))),
        ])),
    ]));
  }

  Widget _gameChip(String label, String action) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 8),
        Text(action, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 10)),
      ]));
  }

  void _openGame(String game) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: Text(game, style: const TextStyle(color: Colors.white)),
      content: Text('$game game starting...', style: const TextStyle(color: Colors.grey)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }

  void _createChallenge(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: const Text('Create Challenge', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: 'Challenge Name', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: 'Game/Topic', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: 'Entry Fee (PINC)', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: 'Prize Pool (PINC)', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(dropdownColor: const Color(0xFF0A0E14), decoration: const InputDecoration(labelText: 'Type', filled: true),
          items: const [DropdownMenuItem(value: 'p2p', child: Text('P2P (vs 1 person)')), DropdownMenuItem(value: 'global', child: Text('Global (everyone can join)')), DropdownMenuItem(value: 'developer', child: Text('Developer Funded'))],
          onChanged: (v) {}, value: 'p2p'),
        const SizedBox(height: 12),
        const Text('Min wager: 20 PINC\nP2P: 7% platform + up to 5% creator\nGlobal: 1,560 PINC + 9% collection', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create')),
      ],
    ));
  }
}

// ==================== PROFILE TAB (Language, Forums, SACCO, Settings) ====================
class ProfileTab extends StatefulWidget {
  final String myPincId;
  const ProfileTab({super.key, required this.myPincId});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Swahili', 'Spanish', 'French', 'German', 'Chinese', 'Arabic', 'Portuguese', 'Hindi', 'Japanese', 'Russian', 'Korean', 'Italian', 'Dutch', 'Turkish', 'Vietnamese', 'Thai', 'Indonesian', 'Malay', 'Greek', 'Polish', 'Ukrainian', 'Hebrew', 'Bengali', 'Tamil', 'Telugu', 'Marathi', 'Kannada', 'Gujarati', 'Punjabi', 'Urdu', 'Filipino', 'Egyptian Arabic', 'Nigerian Pidgin', 'East African English', 'West African French', 'Portuguese (Angola)', 'Spanish (LATAM)', 'French (West Africa)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Profile Header
          Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 50, color: Color(0xFF0A0E14))),
          const SizedBox(height: 16),
          Text(widget.myPincId, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('6-Phase Security Active', style: TextStyle(color: Colors.green, fontSize: 12))),
          const SizedBox(height: 24),

          // Language Settings
          _sectionTitle('Language & Display'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.language, color: Color(0xFF00D4AA)), SizedBox(width: 8), Text('Language', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              Text('Auto-detected from your location. Change anytime.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(dropdownColor: const Color(0xFF1A2028), value: _selectedLanguage,
                items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _selectedLanguage = v!)),
            ])),
          const SizedBox(height: 16),

          // SACCO/Chama System
          _sectionTitle('SACCO/Chama'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.savings, color: Color(0xFF00D4AA)), SizedBox(width: 8), Text('Group Savings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              const Text('Create a savings group with multi-signature withdrawal\nChairman, Secretary, and Treasurer must approve', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => _createSacco(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                child: const Text('Create SACCO/Chama', style: TextStyle(color: Color(0xFF0A0E14)))),
            ])),
          const SizedBox(height: 16),

          // Forums
          _sectionTitle('Community'),
          const SizedBox(height: 12),
          _profileItem(Icons.forum, 'Forums', 'Discuss with other users'),
          _profileItem(Icons.campaign, 'Market Fundraiser', 'Share your campaigns'),
          _profileItem(Icons.event, 'Host Event', 'Rap, Coding, Hacking bounty'),
          const SizedBox(height: 16),

          // Security
          _sectionTitle('Security'),
          const SizedBox(height: 12),
          _profileItem(Icons.shield, 'Security Settings', 'PIN, Biometric, Anti-theft'),
          _profileItem(Icons.lock, 'App Lock', 'Require password to open'),
          _profileItem(Icons.restore, 'Recovery', 'Backup keys'),
          const SizedBox(height: 16),

          // Settings
          _sectionTitle('Settings'),
          const SizedBox(height: 12),
          _profileItem(Icons.notifications, 'Notification Settings', 'Manage alerts'),
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
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00D4AA))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]));
  }

  void _createSacco(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: const Text('Create SACCO/Chama', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Group Savings with Multi-Sig', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: 'Group Name', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: 'Minimum Contribution', filled: true, fillColor: Color(0xFF0A0E14)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        const Text('Roles needed:\n• Chairman - Approves all withdrawals\n• Secretary - Manages records\n• Treasurer - Handles contributions', style: TextStyle(color: Colors.grey, fontSize: 11)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create')),
      ],
    ));
  }
}