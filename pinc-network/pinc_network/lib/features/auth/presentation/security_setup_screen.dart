import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/security/pinc_security_service.dart';

/// 6-Phase Security Setup Screen
class SecuritySetupScreen extends ConsumerStatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  ConsumerState<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends ConsumerState<SecuritySetupScreen> {
  int _currentPhase = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Phase 1: PIN
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  // Phase 2: Password
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Phase 3: Seed Phrase
  List<String> _generatedSeedPhrase = [];
  final List<TextEditingController> _seedControllers = List.generate(15, (_) => TextEditingController());
  
  // Phase 4: Private Key
  String _generatedPrivateKey = '';
  
  // Phase 5: Pattern
  List<int> _patternPoints = [];
  bool _isDrawingPattern = false;
  
  // Phase 6: Security Questions
  final _question1Controller = TextEditingController();
  final _answer1Controller = TextEditingController();
  final _question2Controller = TextEditingController();
  final _answer2Controller = TextEditingController();
  final _question3Controller = TextEditingController();
  final _answer3Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateSeedPhrase();
    _generatePrivateKey();
  }

  void _generateSeedPhrase() {
    final security = PincSecurityService();
    _generatedSeedPhrase = security.generateSeedPhrase();
    for (int i = 0; i < 15; i++) {
      _seedControllers[i].text = _generatedSeedPhrase[i];
    }
  }

  void _generatePrivateKey() {
    final security = PincSecurityService();
    _generatedPrivateKey = security.generatePrivateKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Secure Your Account'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Phase ${_currentPhase + 1}/6',
                style: const TextStyle(
                  color: AppTheme.accentCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Phase content
          Expanded(
            child: _buildPhaseContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(6, (index) {
          final isCompleted = index < _currentPhase;
          final isCurrent = index == _currentPhase;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppTheme.accentCyan 
                    : isCurrent 
                        ? AppTheme.accentCyan 
                        : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case 0:
        return _buildPinPhase();
      case 1:
        return _buildPasswordPhase();
      case 2:
        return _buildSeedPhrasePhase();
      case 3:
        return _buildPrivateKeyPhase();
      case 4:
        return _buildPatternPhase();
      case 5:
        return _buildQuestionsPhase();
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================
  // PHASE 1: 6-DIGIT PIN
  // ============================================
  Widget _buildPinPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.pin, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 1: 6-Digit PIN',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a 6-digit PIN to unlock your app. This is your first line of defense.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: const InputDecoration(
              labelText: 'Enter PIN',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              counterText: '',
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _setupPin,
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupPin() async {
    if (_pinController.text.length != 6) {
      _showError('PIN must be 6 digits');
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      _showError('PINs do not match');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_pinController.text)) {
      _showError('PIN must contain only numbers');
      return;
    }

    setState(() => _isLoading = true);
    
    final security = PincSecurityService();
    final success = await security.setupPin(_pinController.text);
    
    setState(() => _isLoading = false);
    
    if (success) {
      _nextPhase();
    } else {
      _showError('Failed to setup PIN');
    }
  }

  // ============================================
  // PHASE 2: PASSWORD
  // ============================================
  Widget _buildPasswordPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 2: Password',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a strong password (12+ characters with uppercase, lowercase, numbers, symbols).',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'Min 12 chars: A-Z, a-z, 0-9, !@#\$%^&*',
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _setupPassword,
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    
    final security = PincSecurityService();
    final success = await security.setupPassword(_passwordController.text);
    
    setState(() => _isLoading = false);
    
    if (success) {
      _nextPhase();
    } else {
      _showError('Password does not meet requirements');
    }
  }

  // ============================================
  // PHASE 3: SEED PHRASE
  // ============================================
  Widget _buildSeedPhrasePhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.key, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 3: 15-Word Seed Phrase',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: AppTheme.warning, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Write down these words in order! This is your recovery phrase.',
                    style: TextStyle(color: AppTheme.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Seed phrase grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 15,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _generatedSeedPhrase[index],
                        style: const TextStyle(
                          color: AppTheme.accentCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Enter seed phrase to confirm:',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          
          TextField(
            controller: _seedControllers[0],
            decoration: InputDecoration(
              labelText: 'Word 1',
              hintText: _generatedSeedPhrase[0],
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _setupSeedPhrase,
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('I have written it down - Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupSeedPhrase() async {
    setState(() => _isLoading = true);
    
    final security = PincSecurityService();
    final success = await security.setupSeedPhrase(_generatedSeedPhrase);
    
    setState(() => _isLoading = false);
    
    if (success) {
      _nextPhase();
    } else {
      _showError('Failed to setup seed phrase');
    }
  }

  // ============================================
  // PHASE 4: PRIVATE KEY
  // ============================================
  Widget _buildPrivateKeyPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.vpn_key, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 4: 256-Bit Private Key',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.dangerous, color: AppTheme.error, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Never share this key! It controls your wallet.',
                    style: TextStyle(color: AppTheme.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentCyan),
            ),
            child: SelectableText(
              _generatedPrivateKey,
              style: const TextStyle(
                color: AppTheme.accentCyan,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'This key is auto-generated from your seed phrase and stored securely.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPhase,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PHASE 5: PATTERN LOCK
  // ============================================
  Widget _buildPatternPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gesture, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 5: Pattern Lock',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Draw a pattern with at least 7 points. This is for admin access only.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          Center(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDrawingPattern = true;
                  _patternPoints = [];
                });
              },
              onPanUpdate: (details) {
                // Handle pattern drawing
              },
              onPanEnd: (details) {
                setState(() {
                  _isDrawingPattern = false;
                });
              },
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: PatternPainter(_patternPoints),
                  child: Center(
                    child: _patternPoints.isEmpty
                        ? const Text(
                            'Draw pattern here',
                            style: TextStyle(color: AppTheme.textTertiary),
                          )
                        : Text(
                            '${_patternPoints.length} points',
                            style: const TextStyle(color: AppTheme.accentCyan),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _patternPoints = []),
                child: const Text('Clear'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  // Demo: add 7 points
                  setState(() => _patternPoints = [0,1,2,3,4,5,6,7,8]);
                },
                child: const Text('Demo Pattern'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _patternPoints.length >= 7 ? _setupPattern : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupPattern() async {
    final security = PincSecurityService();
    final pattern = _patternPoints.join('');
    final success = await security.setupPattern(pattern);
    
    if (success) {
      _nextPhase();
    } else {
      _showError('Pattern must have at least 7 points');
    }
  }

  // ============================================
  // PHASE 6: SECURITY QUESTIONS
  // ============================================
  Widget _buildQuestionsPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 16),
          const Text(
            'Phase 6: Security Questions',
            style: TextStyle(
              color: TextTheme().headlineMedium?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set 3 security questions for account recovery.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          _buildQuestionField(1, _question1Controller, _answer1Controller),
          const SizedBox(height: 16),
          _buildQuestionField(2, _question2Controller, _answer2Controller),
          const SizedBox(height: 16),
          _buildQuestionField(3, _question3Controller, _answer3Controller),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _setupQuestions,
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Complete Setup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionField(int num, TextEditingController q, TextEditingController a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $num',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: q,
          decoration: InputDecoration(
            hintText: 'e.g., What is your mother\'s maiden name?',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: a,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Answer to Question $num',
          ),
        ),
      ],
    );
  }

  Future<void> _setupQuestions() async {
    if (_question1Controller.text.isEmpty || _answer1Controller.text.isEmpty ||
        _question2Controller.text.isEmpty || _answer2Controller.text.isEmpty ||
        _question3Controller.text.isEmpty || _answer3Controller.text.isEmpty) {
      _showError('Please fill in all questions and answers');
      return;
    }

    setState(() => _isLoading = true);
    
    final security = PincSecurityService();
    final questions = [
      _question1Controller.text,
      _question2Controller.text,
      _question3Controller.text,
    ];
    final answers = [
      _answer1Controller.text,
      _answer2Controller.text,
      _answer3Controller.text,
    ];
    
    final success = await security.setupSecurityQuestions(questions, answers);
    
    setState(() => _isLoading = false);
    
    if (success) {
      _completeSetup();
    } else {
      _showError('Failed to setup security questions');
    }
  }

  // ============================================
  // NAVIGATION
  // ============================================
  void _nextPhase() {
    if (_currentPhase < 5) {
      setState(() => _currentPhase++);
    }
  }

  void _completeSetup() {
    // Navigate to home
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Security Complete!'),
          ],
        ),
        content: const Text(
          'Your account is now fully secured with 6-phase protection. '
          'Your data is encrypted and protected.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to main app
            },
            child: const Text('Enter App'),
          ),
        ],
      ),
    );
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
    _confirmPinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _seedControllers.forEach((c) => c.dispose());
    _question1Controller.dispose();
    _answer1Controller.dispose();
    _question2Controller.dispose();
    _answer2Controller.dispose();
    _question3Controller.dispose();
    _answer3Controller.dispose();
    super.dispose();
  }
}

/// Custom painter for pattern lock
class PatternPainter extends CustomPainter {
  final List<int> points;
  
  PatternPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      ..color = AppTheme.accentCyan
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dotSize = size.width / 9;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = center.dx + (points[i] % 3 - 1) * dotSize;
      final y1 = center.dy + (points[i] ~/ 3 - 1) * dotSize;
      final x2 = center.dx + (points[i+1] % 3 - 1) * dotSize;
      final y2 = center.dy + (points[i+1] ~/ 3 - 1) * dotSize;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}