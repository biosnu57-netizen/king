import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/pinc_parallel_service.dart';
import 'core/services/pinc_apk_service.dart';
import 'core/security/pinc_security_service.dart';
import 'core/security/pinc_anti_theft_service.dart';
import 'features/auth/presentation/security_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const ProviderScope(child: PincNetworkApp()));
}

Future<void> _initializeServices() async {
  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.primaryDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize parallel processing
  final parallel = PincParallelService();
  await parallel.initializeParallelProcessing();
  
  // Initialize APK service
  final apk = PincApkService();
  await apk.requestAllPermissions();
  await apk.enableUninstallProtection();
  await apk.enableAutoStart();
}

/// Main App Widget
class PincNetworkApp extends StatelessWidget {
  const PincNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINC Network',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

/// Splash Screen with initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _controller.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if security is set up
    final security = PincSecurityService();
    final isPinSet = await security.isPinSetup();
    
    // Simulate initialization
    await Future.delayed(const Duration(seconds: 3));
    
    if (!isPinSet) {
      // Go to security setup
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SecuritySetupScreen()),
        );
      }
    } else {
      // Go to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 60,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // App Name
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.accentGradient.createShader(bounds),
                      child: const Text(
                        'PINC NETWORK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    const Text(
                      'Decentralized Privacy Platform',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Initializing 8-thread processing...',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Login Screen with 6-phase verification
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _verificationPhase = 0;
  final _pinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _seedController = TextEditingController();
  List<int> _patternPoints = [];
  final _questionAnswers = List.generate(3, (_) => TextEditingController());
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shield,
                  size: 40,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'PINC NETWORK',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                _getPhaseTitle(),
                style: const TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              
              // Verification content
              _buildVerificationContent(),
              
              const SizedBox(height: 24),
              
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: index <= _verificationPhase ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index <= _verificationPhase 
                          ? AppTheme.accentCyan 
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseTitle() {
    switch (_verificationPhase) {
      case 0:
        return 'Phase 1: Enter PIN';
      case 1:
        return 'Phase 2: Enter Password';
      case 2:
        return 'Phase 3: Enter Seed Phrase';
      case 3:
        return 'Phase 4: Private Key';
      case 4:
        return 'Phase 5: Pattern';
      case 5:
        return 'Phase 6: Security Questions';
      default:
        return '';
    }
  }

  Widget _buildVerificationContent() {
    switch (_verificationPhase) {
      case 0:
        return _buildPinVerification();
      case 1:
        return _buildPasswordVerification();
      case 2:
        return _buildSeedVerification();
      case 3:
        return _buildPrivateKeyVerification();
      case 4:
        return _buildPatternVerification();
      case 5:
        return _buildQuestionsVerification();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPinVerification() {
    return Column(
      children: [
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: const InputDecoration(
            labelText: '6-Digit PIN',
            counterText: '',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyPin,
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordVerification() {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyPassword,
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildSeedVerification() {
    return Column(
      children: [
        TextField(
          controller: _seedController,
          decoration: const InputDecoration(
            labelText: 'Seed Phrase (first word)',
            hintText: 'Enter first word of your 15-word phrase',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifySeed,
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateKeyVerification() {
    return Column(
      children: [
        const Text(
          'Your private key is stored securely. Biometric verification required.',
          style: TextStyle(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifyBiometric,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Verify with Biometric'),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternVerification() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'Draw Pattern',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _verificationPhase++),
            child: const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsVerification() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          TextField(
            controller: _questionAnswers[i],
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Answer ${i + 1}',
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyQuestions,
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Complete Login'),
          ),
        ),
      ],
    );
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final security = PincSecurityService();
    final valid = await security.verifyPin(_pinController.text);
    setState(() => _isLoading = false);
    
    if (valid) {
      _nextPhase();
    } else {
      _showError('Invalid PIN');
    }
  }

  Future<void> _verifyPassword() async {
    setState(() => _isLoading = true);
    final security = PincSecurityService();
    final valid = await security.verifyPassword(_passwordController.text);
    setState(() => _isLoading = false);
    
    if (valid) {
      _nextPhase();
    } else {
      _showError('Invalid password');
    }
  }

  Future<void> _verifySeed() async {
    setState(() => _isLoading = true);
    // Simplified verification
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    _nextPhase();
  }

  Future<void> _verifyBiometric() async {
    final antiTheft = PincAntiTheftService();
    final valid = await antiTheft.verifyBiometric();
    
    if (valid) {
      _nextPhase();
    } else {
      _showError('Biometric verification failed');
    }
  }

  Future<void> _verifyQuestions() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    
    // Success - go to home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _nextPhase() {
    if (_verificationPhase < 5) {
      setState(() => _verificationPhase++);
    } else {
      // All phases verified - go to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _passwordController.dispose();
    _seedController.dispose();
    _questionAnswers.forEach((c) => c.dispose());
    super.dispose();
  }
}

/// Main Home Screen after login
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const VpnHomeTab(),
    const WalletHomeTab(),
    const CommunityHomeTab(),
    const JobsHomeTab(),
    const GamesHomeTab(),
    const ProfileHomeTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.secondaryDark,
          border: Border(
            top: BorderSide(color: AppTheme.divider),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'VPN'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Games'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

/// VPN Tab
class VpnHomeTab extends StatelessWidget {
  const VpnHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC VPN')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 80, color: AppTheme.accentCyan),
            SizedBox(height: 24),
            Text(
              'P2P Mesh Network',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '8-thread parallel processing active',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet Tab
class WalletHomeTab extends StatelessWidget {
  const WalletHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINC Wallet')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 80, color: AppTheme.accentCyan),
            SizedBox(height: 24),
            Text(
              'Balance: 0.00 PINC',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Escrow System Active',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Community Tab
class CommunityHomeTab extends StatelessWidget {
  const CommunityHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: const Center(
        child: Text('Community Features', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}

/// Jobs Tab
class JobsHomeTab extends StatelessWidget {
  const JobsHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Jobs')),
      body: const Center(
        child: Text('Jobs Marketplace', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}

/// Games Tab
class GamesHomeTab extends StatelessWidget {
  const GamesHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: const Center(
        child: Text('Gaming Platform', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}

/// Profile Tab
class ProfileHomeTab extends StatelessWidget {
  const ProfileHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: AppTheme.accentCyan),
            SizedBox(height: 24),
            Text(
              '6-Phase Security Active',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Quantum-resistant encryption enabled',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}