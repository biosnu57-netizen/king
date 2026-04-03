import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

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

// ==================== AUTHENTICATION ====================
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      // Change to true to test authenticated state
      _isLoggedIn = false;
    });
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
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isVerifying = false;
  String _verificationStatus = '';

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
              const SizedBox(height: 60),
              // Logo
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
              const Text('Decentralized Privacy Platform', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),

              // Phone Login
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phone Number Verification', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('1 account = 1 phone number\nAnonymous transactions enabled', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '+254...',
                        hintText: 'Enter phone number',
                        filled: true,
                        fillColor: const Color(0xFF0A0E14),
                        prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF00D4AA)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyPhone,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
                        child: _isVerifying
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0E14)))
                            : const Text('Verify & Create Account', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_verificationStatus.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_verificationStatus, style: TextStyle(color: _verificationStatus.contains('✅') ? Colors.green : Colors.red)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Geo-verification info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: Color(0xFF00D4AA), size: 20),
                      const SizedBox(width: 8),
                      const Text('Geo-Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('• Location verified for 1 account per phone\n• IP anonymized\n• Transactions untraceable', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Anti-fraud info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.security, color: Color(0xFF00D4AA), size: 20),
                      const SizedBox(width: 8),
                      const Text('Anti-Fraud & Anti-Hack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('• Device fingerprinting\n• SIM change detection\n• Anti-tampering protection\n• Secure enclave', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      setState(() => _verificationStatus = 'Please enter valid phone number');
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationStatus = '';
    });

    // Simulate verification
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
      _verificationStatus = '✅ Account created! One-time setup complete.';
    });

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }
}

// ==================== HOME SCREEN ====================
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
    GamesHubTab(),
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
  const VpnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PINC VPN'),
        backgroundColor: const Color(0xFF0A0E14),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VpnSettingsPage()))),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Connection Status
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Icon(Icons.shield, size: 50, color: Color(0xFF0A0E14)),
              const SizedBox(height: 8),
              const Text('P2P Mesh Network', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('8-thread parallel processing', style: TextStyle(color: Color(0xFF0A0E14))),
            ]),
          ),
          const SizedBox(height: 24),

          // Connection Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
              child: const Text('Connect', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 24),

          // Node Info
          _infoCard('Network Nodes', '12,453 active nodes'),
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

class VpnSettingsPage extends StatelessWidget {
  const VpnSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VPN Settings'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: ListView(padding: const EdgeInsets.all(16), children: const [
        Text('Node Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _SettingTile('Auto-connect', true),
        _SettingTile('Split Tunneling', false),
        _SettingTile('Kill Switch', true),
        _SettingTile('Multi-hop Routing', false),
        SizedBox(height: 24),
        Text('Upload/Download', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _SettingTile('Compression', true),
        _SettingTile('Encryption Level', true),
        _SettingTile('Data Saving Mode', false),
      ]),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final bool value;
  const _SettingTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFF00D4AA)),
      ]),
    );
  }
}

// ==================== WALLET TAB ====================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PINC Wallet'),
        backgroundColor: const Color(0xFF0A0E14),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('Total Balance', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
              const SizedBox(height: 8),
              const Text('0.00 PINC', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock, size: 14, color: Color(0xFF0A0E14)),
                const SizedBox(width: 4),
                const Text('Encrypted • Private', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 12)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _action(Icons.upload, 'Send'),
            _action(Icons.download, 'Receive'),
            _action(Icons.swap_horiz, 'Swap'),
            _action(Icons.analytics, 'Trade'),
          ]),
          const SizedBox(height: 24),

          // P2P Market Verification
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.verified_user, color: Color(0xFF00D4AA)),
                const SizedBox(width: 8),
                const Text('P2P Market Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              const Text('• Transaction verification system\n• Papa Business verification\n• Escrow automatic release\n• Dispute resolution AI', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Verify'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Create Escrow'))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Deposit Methods
          const Align(alignment: Alignment.centerLeft, child: Text('Deposit/Withdraw', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _tile(Icons.credit_card, 'Credit Card', 'Via agents'),
          _tile(Icons.paid, 'P2P Agents', 'Country-based'),
          _tile(Icons.account_balance, 'PayPal', 'Third-party'),
          _tile(Icons.storefront, 'Papa Business', 'Verified shops'),
          const SizedBox(height: 16),

          // Transfer Types
          const Align(alignment: Alignment.centerLeft, child: Text('Transfer Types', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _transferCard('1', 'Subscription', 'Recurring', const Color(0xFF667eea)),
          _transferCard('2', 'Wagers/Challenges', 'Gaming', const Color(0xFFf093fb)),
          _transferCard('3', 'Savings', 'Protected', const Color(0xFF11998e)),
          _transferCard('4', 'Service Payment', 'Jobs/Freelance', const Color(0xFF4facfe)),
          _transferCard('5', 'Papa Business', 'Verified', const Color(0xFF00D4AA)),
        ]),
      ),
    );
  }

  Widget _action(IconData icon, String label) {
    return Column(children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF00D4AA))),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ]);
  }

  Widget _tile(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00D4AA))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }

  Widget _transferCard(String n, String t, String s, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(n, style: TextStyle(color: c, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(s, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
      ]),
    );
  }
}

// ==================== CHAT TAB ====================
class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), backgroundColor: const Color(0xFF0A0E14),
        actions: const [IconButton(icon: Icon(Icons.call), onPressed: null), IconButton(icon: Icon(Icons.video_call), onPressed: null)]),
      backgroundColor: const Color(0xFF0A0E14),
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF00D4AA), onPressed: () {},
        child: const Icon(Icons.edit, color: Color(0xFF0A0E14))),
      body: ListView(children: const [
        ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('A', style: TextStyle(color: Color(0xFF0A0E14)))),
          title: Text('Alice', style: TextStyle(color: Colors.white)),
          subtitle: Text('Encrypted message...', style: TextStyle(color: Colors.grey)),
          trailing: Text('2:34 PM', style: TextStyle(color: Colors.grey))),
        ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('B', style: TextStyle(color: Color(0xFF0A0E14)))),
          title: Text('Papa Business', style: TextStyle(color: Colors.white)),
          subtitle: Text('Verified ✓', style: TextStyle(color: Color(0xFF00D4AA))),
          trailing: Text('1:20 PM', style: TextStyle(color: Colors.grey))),
      ]),
    );
  }
}

// ==================== JOBS TAB ====================
class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title: const Text('Remote Jobs'), backgroundColor: const Color(0xFF0A0E14),
          bottom: const TabBar(labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
            tabs: [Tab(text: 'Find'), Tab(text: 'My Jobs'), Tab(text: 'Post'), Tab(text: 'PapaBiz')])),
        backgroundColor: const Color(0xFF0A0E14),
        body: const TabBarView(children: [_FindJobsView(), _MyJobsView(), _PostJobView(), _PapaBizView()]),
      ),
    );
  }
}

class _FindJobsView extends StatelessWidget {
  const _FindJobsView();

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _jobCard('Full Stack Developer', '500-1000 PINC', '5 needed', 'Software'),
      _jobCard('UI/UX Designer', '300-500 PINC', '2 needed', 'Design'),
      _jobCard('Content Writer', '100-200 PINC', '1 needed', 'Writing'),
      _jobCard('Video Editor', '200-400 PINC', '3 needed', 'Media'),
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
        Text(workers, style: const TextStyle(color: Colors.grey)),
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
}

class _MyJobsView extends StatelessWidget {
  const _MyJobsView();
  @override
  Widget build(BuildContext context) => const Center(child: Text('No active jobs', style: TextStyle(color: Colors.grey)));
}

class _PostJobView extends StatelessWidget {
  const _PostJobView();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Job Title', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      TextField(maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: const Color(0xFF1A2028), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
        child: const Text('Post Job (Escrow)', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold))),
    ]));
  }
}

class _PapaBizView extends StatelessWidget {
  const _PapaBizView();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.store, color: Color(0xFF00D4AA)),
            const SizedBox(width: 8),
            const Text('Papa Business Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          const Text('Verified local businesses can receive payments directly', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
            child: const Text('Register Business', style: TextStyle(color: Color(0xFF0A0E14)))),
        ]),
      ),
    ]);
  }
}

// ==================== GAMES HUB TAB ====================
class GamesHubTab extends StatelessWidget {
  const GamesHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games & Challenges'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () {},
        icon: const Icon(Icons.add, color: Color(0xFF0A0E14)),
        label: const Text('Challenge', style: TextStyle(color: Color(0xFF0A0E14))),
      ),
      body: Column(children: [
        // External Games Section
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.videogame_asset, color: Color(0xFF00D4AA)),
              const SizedBox(width: 8),
              const Text('External Games', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            const Text('Connect FIFA, PES, Mobile games, Console games', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _externalGameChip('🎮 FIFA'),
              _externalGameChip('⚽ PES'),
              _externalGameChip('🎯 PUBG'),
              _externalGameChip('🎲 COD'),
              _externalGameChip('🎰 Slots'),
            ]),
          ]),
        ),
        // Built-in Games
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: const EdgeInsets.all(16),
            children: [
              _GameCard(name: 'Chess', icon: '♔', color: const Color(0xFF8B4513), onTap: () {}),
              _GameCard(name: 'Checkers', icon: '⭕', color: const Color(0xFFDC143C), onTap: () {}),
              _GameCard(name: 'Tetris', icon: '🧱', color: const Color(0xFF00CED1), onTap: () {}),
              _GameCard(name: 'Snake', icon: '🐍', color: const Color(0xFF32CD32), onTap: () {}),
              _GameCard(name: 'Pong', icon: '🏓', color: const Color(0xFFFF6347), onTap: () {}),
              _GameCard(name: 'Wordle', icon: '📝', color: const Color(0xFFFFD700), onTap: () {}),
            ],
          ),
        ),
      ]),
    );
  }
}

class _externalGameChip extends StatelessWidget {
  final String label;
  const _externalGameChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00D4AA))),
      child: Text(label, style: const TextStyle(color: Color(0xFF00D4AA))),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const _GameCard({required this.name, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
          Text('Tap to play', style: TextStyle(color: color, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ==================== PROFILE TAB ====================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 50, color: Color(0xFF0A0E14)),
          ),
          const SizedBox(height: 16),
          const Text('User', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text('6-Phase Security Active', style: TextStyle(color: Colors.green, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),

          // Security Features
          const Align(alignment: Alignment.centerLeft, child: Text('Security', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _profileItem(Icons.shield, 'Security', 'PIN, Password, Pattern, Biometric'),
          _profileItem(Icons.fingerprint, 'Anti-Hack', 'Device fingerprinting'),
          _profileItem(Icons.smartphone, 'Anti-Tamper', 'SIM change detection'),
          _profileItem(Icons.analytics, 'Storage Speed', 'Rankings • Optimization'),
          const SizedBox(height: 16),

          // Admin
          const Align(alignment: Alignment.centerLeft, child: Text('Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _profileItem(Icons.admin_panel_settings, 'Admin Mode', 'Node control'),
          _profileItem(Icons.cloud_upload, 'Upload/Download', 'Server settings'),
          _profileItem(Icons.compress, 'Compression', 'Data optimization'),
          _profileItem(Icons.restart_alt, 'Recovery', 'Data recovery'),
          const SizedBox(height: 16),

          // Settings
          const Align(alignment: Alignment.centerLeft, child: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _profileItem(Icons.forum, 'Forums', 'Community'),
          _profileItem(Icons.settings, 'App Settings', 'Preferences'),
          _profileItem(Icons.help, 'Help & Support', 'Get help'),
          _profileItem(Icons.info, 'About PINC', 'Network info'),
        ]),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      ]),
    );
  }
}