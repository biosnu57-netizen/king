import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  bool _securityEnabled = true;
  bool _biometricEnabled = false;
  String _deviceId = '';

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
              const Text('Decentralized Privacy Platform', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // Phone Login
              _buildSection(
                title: 'Phone Verification',
                subtitle: '1 account = 1 phone number',
                child: Column(children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+254...',
                      filled: true,
                      fillColor: const Color(0xFF0A0E14),
                      prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF00D4AA)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    const SizedBox(height: 8),
                    Text(_verificationStatus, style: TextStyle(color: _verificationStatus.contains('✅') ? Colors.green : Colors.red)),
                  ],
                ]),
              ),
              const SizedBox(height: 20),

              // Anti-Theft Settings
              _buildSection(
                title: 'Anti-Theft Protection',
                subtitle: 'Secure your device',
                child: Column(children: [
                  _toggleTile('Enable Anti-Theft', _securityEnabled, (v) => setState(() => _securityEnabled = v)),
                  _toggleTile('Biometric Lock', _biometricEnabled, (v) => setState(() => _biometricEnabled = v)),
                  _infoTile(Icons.lock, 'Shutdown Protection', 'Device cannot shut down without PIN'),
                  _infoTile(Icons.visibility_off, 'Stealth Mode', 'App hidden from launcher'),
                  _infoTile(Icons.location_on, 'Location Tracking', 'Track when stolen'),
                ]),
              ),
              const SizedBox(height: 20),

              // Device ID
              _buildSection(
                title: 'Device Security',
                subtitle: 'Your unique device identifier',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.fingerprint, color: Color(0xFF00D4AA)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_deviceId.isEmpty ? 'Device ID: Generating...' : _deviceId, style: const TextStyle(color: Colors.white, fontSize: 12))),
                    IconButton(icon: const Icon(Icons.copy, size: 18, color: Colors.grey), onPressed: () {}),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _toggleTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF00D4AA)),
      ]),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00D4AA), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
      ]),
    );
  }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _verificationStatus = 'Enter phone number');
      return;
    }
    setState(() {
      _isVerifying = true;
      _verificationStatus = '';
      _deviceId = 'PINC-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isVerifying = false;
      _verificationStatus = '✅ Account created with anti-theft!';
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
    GameMonitorTab(),
    JobsTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== GAME MONITOR TAB (NEW) ====================
class GameMonitorTab extends StatefulWidget {
  const GameMonitorTab({super.key});

  @override
  State<GameMonitorTab> createState() => _GameMonitorTabState();
}

class _GameMonitorTabState extends State<GameMonitorTab> {
  bool _monitoring = true;
  List<FriendGameStatus> _friends = [];
  List<PlatformLink> _platforms = [];
  List<PendingChallenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    // Simulate friends playing
    _friends = [
      FriendGameStatus(name: 'Alice', game: 'FIFA 24', platform: 'PS5', isPlaying: true, matchId: 'MATCH-123'),
      FriendGameStatus(name: 'Bob', game: 'COD MW3', platform: 'Xbox', isPlaying: true, matchId: 'RANKED-456'),
      FriendGameStatus(name: 'Charlie', game: 'PES 2024', platform: 'Mobile', isPlaying: true, matchId: 'LOBBY-789'),
    ];
    _platforms = [
      PlatformLink(platform: 'PlayStation', icon: '🎮', isConnected: true, psnId: 'PINC_Player1'),
      PlatformLink(platform: 'Xbox', icon: '❎', isConnected: true, xboxId: 'PINC_Gamer'),
      PlatformLink(platform: 'PC', icon: '💻', isConnected: true, pcId: 'PC-Master'),
      PlatformLink(platform: 'Mobile', icon: '📱', isConnected: true, deviceId: 'Android-01'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Monitor'),
        backgroundColor: const Color(0xFF0A0E14),
        actions: [
          Switch(value: _monitoring, onChanged: (v) => setState(() => _monitoring = v), activeColor: const Color(0xFF00D4AA)),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.notifications_active), onPressed: () => _showNotificationSettings()),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Real-time Monitoring Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _monitoring ? const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]) : const LinearGradient(colors: [Colors.grey, Colors.grey]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Icon(_monitoring ? Icons.visibility : Icons.visibility_off, color: _monitoring ? const Color(0xFF0A0E14) : Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_monitoring ? 'Monitoring Active' : 'Monitoring Paused', style: TextStyle(color: _monitoring ? const Color(0xFF0A0E14) : Colors.white, fontWeight: FontWeight.bold)),
                Text(_monitoring ? 'Friends will be notified when you play' : 'Enable to find challenge opponents', style: TextStyle(color: _monitoring ? const Color(0xFF0A0E14) : Colors.grey, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // Friends Currently Playing
          const Text('Friends Playing Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...(_friends.map((f) => _buildFriendCard(f)).toList()),
          const SizedBox(height: 24),

          // Platform Links
          const Text('Connected Platforms', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _platforms.length,
              itemBuilder: (context, index) {
                final p = _platforms[index];
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(p.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(p.platform, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    Text(p.isConnected ? '✓' : '○', style: TextStyle(color: p.isConnected ? Colors.green : Colors.grey, fontSize: 10)),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Pending Challenges
          if (_challenges.isNotEmpty) ...[
            const Text('Pending Challenges', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...(_challenges.map((c) => _buildChallengeCard(c)).toList()),
          ],
          const SizedBox(height: 24),

          // External Games Integration
          _buildExternalGamesSection(),
        ]),
      ),
    );
  }

  Widget _buildFriendCard(FriendGameStatus friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(25)),
          child: Center(child: Text(friend.name[0], style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold, fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(friend.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10))),
          ]),
          Text('${friend.game} on ${friend.platform}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text('Match: ${friend.matchId}', style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 11)),
        ])),
        ElevatedButton(
          onPressed: () => _sendChallenge(friend),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          child: const Text('Challenge', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _buildChallengeCard(PendingChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00D4AA))),
      child: Row(children: [
        const Icon(Icons.sports_score, color: Color(0xFF00D4AA)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('vs ${challenge.from}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('${challenge.game} - ${challenge.wager} PINC', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        Row(children: [
          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _acceptChallenge(challenge)),
          IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _rejectChallenge(challenge)),
        ]),
      ]),
    );
  }

  Widget _buildExternalGamesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.link, color: Color(0xFF00D4AA)),
          SizedBox(width: 8),
          Text('Link External Games', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        const Text('Connect your accounts to automatically detect when friends are playing and receive challenge notifications:', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _gameChip('🎮 PlayStation', 'Connect PSN'),
          _gameChip('❎ Xbox', 'Connect Xbox'),
          _gameChip('💻 Steam', 'Connect Steam'),
          _gameChip('📱 Mobile', 'Connect ID'),
          _gameChip('🍎 Apple', 'Connect Game Center'),
        ]),
      ]),
    );
  }

  Widget _gameChip(String label, String action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 8),
        Text(action, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 10)),
      ]),
    );
  }

  void _sendChallenge(FriendGameStatus friend) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A2028),
      title: Text('Challenge ${friend.name}', style: const TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Game: ${friend.game}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: 'Wager (PINC)', filled: true, fillColor: Color(0xFF0A0E14)), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge sent!'), backgroundColor: Color(0xFF00D4AA)));
        }, child: const Text('Send')),
      ],
    ));
  }

  void _acceptChallenge(PendingChallenge c) {
    setState(() => _challenges.remove(c));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge accepted!'), backgroundColor: Color(0xFF00D4AA)));
  }

  void _rejectChallenge(PendingChallenge c) {
    setState(() => _challenges.remove(c));
  }

  void _showNotificationSettings() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1A2028), builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notification Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _toggleSetting('Friend Online', true),
        _toggleSetting('Challenge Request', true),
        _toggleSetting('Same Game Match', true),
        _toggleSetting('Tournament Alert', false),
        _toggleSetting('Wager Updates', true),
      ]),
    ));
  }

  Widget _toggleSetting(String title, bool value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Text(title, style: const TextStyle(color: Colors.white)),
      const Spacer(),
      Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFF00D4AA)),
    ]));
  }
}

// ==================== DATA MODELS ====================
class FriendGameStatus {
  final String name;
  final String game;
  final String platform;
  final bool isPlaying;
  final String matchId;
  FriendGameStatus({required this.name, required this.game, required this.platform, required this.isPlaying, required this.matchId});
}

class PlatformLink {
  final String platform;
  final String icon;
  final bool isConnected;
  final String? psnId;
  final String? xboxId;
  final String? pcId;
  final String? deviceId;
  PlatformLink({required this.platform, required this.icon, this.isConnected = false, this.psnId, this.xboxId, this.pcId, this.deviceId});
}

class PendingChallenge {
  final String from;
  final String game;
  final String wager;
  PendingChallenge({required this.from, required this.game, required this.wager});
}

// ==================== VPN TAB ====================
class VpnTab extends StatelessWidget {
  const VpnTab({super.key});

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
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.all(16)),
            child: const Text('Connect', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold, fontSize: 18)),
          )),
        ]),
      ),
    );
  }
}

// ==================== WALLET TAB ====================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC Wallet'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), borderRadius: BorderRadius.circular(20)),
          child: const Column(children: [
            Text('Total Balance', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
            Text('0.00 PINC', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 32, fontWeight: FontWeight.bold)),
          ])),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _action(Icons.upload, 'Send'), _action(Icons.download, 'Receive'), _action(Icons.swap_horiz, 'Swap'), _action(Icons.analytics, 'Trade'),
        ]),
      ])),
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
}

// ==================== JOBS TAB ====================
class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 4, child: Scaffold(
      appBar: AppBar(title: const Text('Jobs'), backgroundColor: const Color(0xFF0A0E14),
        bottom: const TabBar(labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
          tabs: [Tab(text: 'Find'), Tab(text: 'My Jobs'), Tab(text: 'Post'), Tab(text: 'PapaBiz')])),
      backgroundColor: const Color(0xFF0A0E14),
      body: const TabBarView(children: [
        Center(child: Text('Find Jobs', style: TextStyle(color: Colors.grey))),
        Center(child: Text('My Jobs', style: TextStyle(color: Colors.grey))),
        Center(child: Text('Post Job', style: TextStyle(color: Colors.grey))),
        Center(child: Text('Papa Business', style: TextStyle(color: Colors.grey))),
      ]),
    ));
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
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), shape: BoxShape.circle),
          child: const Icon(Icons.person, size: 50, color: Color(0xFF0A0E14))),
        const SizedBox(height: 16),
        const Text('User', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _item(Icons.shield, 'Security', 'PIN, Biometric, Anti-theft'),
        _item(Icons.sports_esports, 'Linked Games', 'PSN, Xbox, Steam, Mobile'),
        _item(Icons.settings, 'Settings', 'App preferences'),
      ])),
    );
  }

  Widget _item(IconData icon, String title, String sub) {
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
      ]),
    );
  }
}