# 🎯 PINC NETWORK - 4-AI TEAM INSTRUCTIONS

## COMPLETE DEVELOPMENT GUIDE FOR AI AGENTS

---

## 🔑 CORE PRINCIPLES (ALL AIs MUST FOLLOW)

```
✅ Use EXISTING GitHub projects - modify, don't rebuild from scratch
✅ Test every feature BEFORE pushing - no broken code
✅ Use const CORRECTLY - never use with non-const constructors
✅ Keep code under 500 lines per file - split larger files
✅ Comment complex logic with // WHY:
✅ Run flutter analyze before every push
✅ Build APK locally before marking complete
```

---

## 🤖 AI #1: CORE APP ENGINEER
### Repository: biosnu57-netizen/pinc-core

### 🎯 MISSION
Build the main Flutter app with PINC Net (VPN), Chat, Jobs, Profile tabs using existing open source projects as base.

### 📚 RESEARCH PHASE (Complete in 2 hours)

**Search these GitHub repos to FIND and MODIFY:**

1. **Main App Structure:**
   - Search: "flutter bottom navigation tabs dark theme"
   - Found: Use any MIT/Apache licensed tab-based Flutter app
   - Modify: Replace colors with PINC cyan (#00D4AA) + dark (#0A0E14)

2. **VPN/Mesh Network UI:**
   - Search: "flutter vpn app template open source"
   - Found: Use VPN client UI templates
   - Modify: Rename "VPN" to "PINC Net", add node selection

3. **Chat UI:**
   - Search: "flutter chat app template encrypted"
   - Found: Use Signal/Telegram clones
   - Modify: Add Voice/Video/Screen call buttons

### 🔧 TOOLS TO USE
- Flutter SDK 3.41+
- flutter_riverpod (state management)
- hive_flutter (local storage)
- dio (networking)

### 📝 BUILD STEPS

**Step 1: Create Flutter project**
```bash
flutter create pinc-core --org com.pincnetwork
cd pinc-core
flutter pub add flutter_riverpod hive hive_flutter dio
```

**Step 2: Build main app structure (main.dart)**
- MaterialApp with dark theme
- BottomNavigationBar with 6 tabs
- Tab 1: PINC Net (VPN)
- Tab 2: Wallet (placeholder for AI #4)
- Tab 3: Chat
- Tab 4: Jobs
- Tab 5: Games (placeholder for AI #3)
- Tab 6: Profile

**Step 3: PINC Net Tab (VPN)**
- Large connect button (gradient cyan/green)
- Node list: Kenya, Germany, USA, Japan, UK, Nigeria
- Quick connect flags
- Network status: "Connected to X nodes"
- Your IP status: "Protected • Hidden"
- Speed ranking display

**Step 4: Chat Tab**
- Conversation list (mock data)
- Floating action button for new chat
- Top bar: Voice call, Video call, Screen share buttons
- Message bubbles (encrypted style)

**Step 5: Jobs Tab**
- Tab bar: Find Jobs | My Jobs | Post Job | Fundraiser
- Job cards with: Title, Budget, Deadline, Bids count
- Post job form: Title, Description, Budget, Deadline
- Fundraiser creation form

**Step 6: Profile Tab**
- Avatar + PINC ID display
- Language dropdown (20+ languages)
- Security section (links to AI #2)
- SACCO/Chama create button
- Forums, Event Hosting, Settings

### ✅ VERIFICATION CHECKLIST
- [ ] `flutter analyze lib/` shows 0 errors
- [ ] `flutter build apk --debug` succeeds
- [ ] APK size is 40-120MB
- [ ] All 6 tabs navigate correctly
- [ ] PINC Net shows node selection
- [ ] Chat shows call buttons

### 📤 PUSH COMMAND
```bash
cd pinc-core
git add .
git commit -m "feat: Core app with PINC Net, Chat, Jobs, Profile tabs"
git push origin main
```

---

## 🤖 AI #2: SECURITY ENGINEER
### Repository: biosnu57-netizen/pinc-security

### 🎯 MISSION
Build 6-phase security system, hardware binding, anti-theft features using existing security libraries.

### 📚 RESEARCH PHASE (Complete in 2 hours)

**Search these GitHub repos:**

1. **6-Phase Auth:**
   - Search: "flutter biometric authentication pin pattern"
   - Found: Use local_auth, flutter_secure_storage
   - Modify: Combine PIN + Password + Pattern + Fingerprint + Questions

2. **Device Admin (Anti-theft):**
   - Search: "flutter device admin android unlock"
   - Found: Use device_info_plus, android_device_admin
   - Modify: Shutdown protection, SIM change detection

3. **Encryption:**
   - Search: "flutter aes encryption crypto"
   - Found: Use encrypt, crypto, pointycastle packages
   - Modify: AES-256 for data encryption

4. **Admin System:**
   - Search: "flutter admin panel dashboard"
   - Modify: Create admin panel with your key

### 🔧 TOOLS TO USE
- local_auth (biometrics)
- flutter_secure_storage (keys)
- encrypt + crypto (AES-256, SHA-3)
- device_info_plus (fingerprint)
- android_device_admin (admin features)

### 📝 BUILD STEPS

**Step 1: Create Flutter module**
```bash
flutter create pinc-security --org com.pincnetwork
cd pinc-security
flutter pub add local_auth flutter_secure_storage encrypt crypto pointycastle device_info_plus
```

**Step 2: Create 6-Phase Security**

```dart
// lib/security/phases.dart

enum SecurityPhase {
  pin,           // 6-digit PIN
  password,      // 12+ chars, complex
  seedPhrase,    // 15 words BIP39
  privateKey,    // 256-bit Ed25519
  pattern,       // 7+ points
  questions,     // 3 recovery questions
}

class SecurityService {
  // Validate each phase
  bool validatePin(String pin) => pin.length == 6;
  bool validatePassword(String pwd) => pwd.length >= 12 && 
    RegExp(r'[A-Z]').hasMatch(pwd) && 
    RegExp(r'[a-z]').hasMatch(pwd) && 
    RegExp(r'[0-9]').hasMatch(pwd) &&
    RegExp(r'[!@#$%^&*]').hasMatch(pwd);
  // ... etc
}
```

**Step 3: Device Fingerprinting**

```dart
class DeviceFingerprint {
  // Combine: Android ID + Hardware serial + CPU info
  // Hash to create unique device ID
  // This binds account to device
}
```

**Step 4: Anti-Theft Features**

```dart
class AntiTheftService {
  // Shutdown protection: require auth before power off
  // SIM change detection: alert if SIM removed
  // Remote lock/wipe: via P2P network command
  // Uninstall protection: Android Device Admin
}
```

**Step 5: Admin Panel**

```dart
// Your one-time key: david orata anglex ambuch elderman makaveli
// This activates admin panel with:
// - Network pause/resume
// - Network freeze
// - Settings
// - Statistics
```

**Step 6: Data Encryption**

```dart
class PincEncryption {
  // AES-256-GCM for all sensitive data
  // SHA-3 for hashing
  // Fragment data across P2P network
  // Self-destruct on tampering detection
}
```

### ✅ VERIFICATION CHECKLIST
- [ ] 6-phase security flow works
- [ ] Device fingerprint generated
- [ ] PIN + Pattern + Password validation works
- [ ] Admin key (david orata anglex ambuch elderman makaveli) opens admin panel
- [ ] Encryption service encrypts/decrypts correctly

### 📤 PUSH COMMAND
```bash
cd pinc-security
git add .
git commit -m "feat: 6-phase security, device binding, anti-theft"
git push origin main
```

---

## 🤖 AI #3: GAMES ENGINEER
### Repository: biosnu57-netizen/pinc-games

### 🎯 MISSION
Build 6 playable games + external game monitoring using existing open source games.

### 📚 RESEARCH PHASE (Complete in 2 hours)

**Search GitHub for EXISTING games to MODIFY:**

1. **Tetris:**
   - Search: "flutter tetris game open source"
   - Found: Take any MIT licensed Tetris
   - Modify: Add PINC styling, scoring

2. **Chess:**
   - Search: "flutter chess game"
   - Found: Use dart-chess library + UI
   - Modify: Add AI opponent, tournaments

3. **Checkers:**
   - Search: "flutter checkers draughts"
   - Modify: Similar to chess

4. **Word Games:**
   - Search: "flutter wordle clone"
   - Modify: Wordle-style game

5. **Other games to add:**
   - Search: "flutter snake game"
   - Search: "flutter pong game"
   - Search: "flutter connect four"

### 🔧 TOOLS TO USE
- flame (game engine)
- dart-chess (chess logic)
- Custom implementations for simpler games

### 📝 BUILD STEPS

**Step 1: Create Flutter project**
```bash
flutter create pinc-games --org com.pincnetwork
cd pinc-games
flutter pub add flame
```

**Step 2: Games to Build (in priority order)**

| # | Game | Source | Status |
|---|------|--------|--------|
| 1 | Connect 4 | Custom | ✓ (already exists) |
| 2 | Tic Tac Toe | Custom | ✓ (already exists) |
| 3 | Snake | Custom | Build fresh |
| 4 | Tetris | Find on GitHub | Modify existing |
| 5 | Chess | dart-chess | Build with library |
| 6 | Wordle/Word Game | Custom | Build fresh |

**Step 3: Game Logic Structure**

```dart
// lib/games/tetris.dart
class TetrisGame {
  // 7 tetromino shapes
  // Rotation system
  // Line clearing
  // Score tracking
  // Level progression
}

// lib/games/chess.dart
class ChessGame {
  // Full chess rules
  // Move validation
  // Check/checkmate detection
  // Draw conditions
}

// lib/games/checkers.dart
class CheckersGame {
  // King jump rules
  // Multi-jump logic
  // Win detection
}
```

**Step 4: League System**

```dart
class League {
  String name;
  int maxPlayers = 50;
  List<String> players;
  String entryFee;
  List<int> prizePositions; // [1, 2, 3] or [1-10]
  String prizeAmount;
  
  // Create league
  // Join league
  // Leaderboard
  // Prize distribution
}
```

**Step 5: Challenge System**

```dart
class Challenge {
  String creator;
  String gameType;
  int wager; // min 20 PINC
  String opponent; // or "open"
  
  // Create challenge
  // Accept challenge
  // Result verification (anti-forgery)
}
```

**Step 6: External Game Linking (UI only)**

```dart
class ExternalGameLink {
  String platform; // PSN, Xbox, Steam
  String username;
  bool verified;
  
  // Link account
  // Monitor matches (requires API - future)
}
```

### ✅ VERIFICATION CHECKLIST
- [ ] At least 4 games playable
- [ ] Chess moves work correctly
- [ ] Tetris pieces rotate and fall
- [ ] League creation works (up to 50)
- [ ] Challenge creation with wager (min 20 PINC)
- [ ] Games use PINC styling

### 📤 PUSH COMMAND
```bash
cd pinc-games
git add .
git commit -m "feat: 6+ games, leagues, challenges, external linking"
git push origin main
```

---

## 🤖 AI #4: FINANCE ENGINEER
### Repository: biosnu57-netizen/pinc-finance

### 🎯 MISSION
Build PINC wallet, escrow system, fee calculation using existing wallet apps as reference.

### 📚 RESEARCH PHASE (Complete in 2 hours)

**Search GitHub for EXISTING wallets to MODIFY:**

1. **Crypto Wallets:**
   - Search: "flutter crypto wallet open source"
   - Found: Use as UI template
   - Modify: Replace with PINC coin

2. **Escrow:**
   - Search: "flutter escrow system"
   - Found: Build custom (not many existing)
   - Modify: Create PINC-specific escrow

3. **Payment Integration:**
   - Search: "flutter payment gateway"
   - Found: Use stripe_flutter, razorpay
   - Modify: UI only (no real integration yet)

### 🔧 TOOLS TO USE
- hive (local wallet storage)
- shared_preferences (settings)
- flutter_secure_storage (keys)

### 📝 BUILD STEPS

**Step 1: Create Flutter project**
```bash
flutter create pinc-finance --org com.pincnetwork
cd pinc-finance
flutter pub add hive hive_flutter shared_preferences flutter_secure_storage
```

**Step 2: Fee Service (EXACT - copy your specs)**

```dart
class FeeService {
  // Internet Selling
  static const sellerSubscription = 435; // PINC/month
  static const premiumSharing = 325; // PINC/month (up to 10 users)
  static const freeTierLimit = 3;
  
  // Betting
  static double p2pBetFee(double winnerAmount) => winnerAmount * 0.07; // 7%
  static double developerBetFee(double totalStakes) => totalStakes * 0.13; // 13%
  static const minWager = 20;
  
  // Platform
  static const basicSubscription = 325;
  static const unlimitedJobs = 300;
  static const globalChallenge = 1560;
  static const apiAccess = 1000;
  
  // Jobs
  static double jobCreateFee(double jobValue) => jobValue * 0.03; // 3%
  static double jobPaymentFee(double amount) => amount * 0.09; // 9%
  
  // Withdrawals (TIERED - exact)
  static int withdrawalFee(int amount) {
    if (amount <= 1000) return 3;
    if (amount <= 3000) return 10;
    if (amount <= 10000) return 19;
    if (amount <= 39000) return 35;
    if (amount <= 60000) return 45;
    if (amount <= 90000) return 60;
    if (amount <= 500000) return 74;
    return 103;
  }
  
  // File Storage
  static const freeStorageTB = 10;
  static const overageFeePer10TB = 100;
  
  // Fundraising/Challenges
  static double fundraisingFee(double raised) => raised * 0.09;
  static double challengeCollectionFee(double total) => total * 0.09;
}
```

**Step 3: Wallet Service**

```dart
class PincWallet {
  double balance; // PINC
  String pincId;
  List<Transaction> transactions;
  
  // Send PINC (with fee deduction)
  // Receive PINC
  // Transaction history
}
```

**Step 4: Deposit Methods (UI)**

```dart
class DepositMethod {
  static const methods = ['Crypto (BSC)', 'PayPal', 'P2P Agent'];
  // Show fees: FREE for deposits
  // Show limits, processing time
}
```

**Step 5: Withdrawal UI**

```dart
class WithdrawScreen {
  // Input amount
  // Show fee (using FeeService)
  // Show final amount = amount - fee
  // Select method: Crypto, PayPal, P2P Agent
  // Confirm with 6-phase auth
}
```

**Step 6: Job Escrow**

```dart
class JobEscrow {
  String jobId;
  double amount;
  String employer;
  String worker;
  String status; // pending, funded, completed, disputed
  
  // Employer funds escrow (3% fee)
  // Worker completes job
  // Employer approves (funds released to worker - 9% fee)
  // Or dispute (3 attempts, then AI #1 arbitrates)
}
```

**Step 7: Transfer Types**

```dart
enum TransferType {
  subscription,  // Recurring
  wagers,       // Gaming bets
  savings,      // SACCO/Chama
  servicePayment, // Freelance work
  papaBusiness,   // Merchant payment
}
```

### ✅ VERIFICATION CHECKLIST
- [ ] Fee calculation matches EXACT specs
- [ ] Withdrawal shows correct fee per tier
- [ ] Internal transfers show as FREE
- [ ] Job escrow shows 3% create, 9% payment fees
- [ ] All 5 transfer types selectable

### 📤 PUSH COMMAND
```bash
cd pinc-finance
git add .
git commit -m "feat: Wallet, fee system, job escrow, deposits/withdrawals"
git push origin main
```

---

## 🔄 INTEGRATION COORDINATION

### How AIs Work Together

```
AI #1 (Core) imports modules from:
  - AI #2: Security module (for profile security section)
  - AI #3: Games module (for games tab)
  - AI #4: Finance module (for wallet tab)

Example import in AI #1:
  import 'package:pinc_security/security_service.dart';
  import 'package:pinc_games/games_service.dart';
  import 'package:pinc_finance/fee_service.dart';
```

### Weekly Merge Schedule

| Week | AI #1 | AI #2 | AI #3 | AI #4 |
|------|-------|-------|-------|-------|
| 1 | App skeleton | Auth setup | Games 1-3 | Wallet UI |
| 2 | Import #2,#3,#4 | Security complete | Games 4-6 | Escrow |
| 3 | Full integration | Admin panel | Leagues | Fee system |
| 4 | Testing | Anti-theft | Challenges | Final polish |

---

## 🎯 START COMMANDS

### AI #1 - Start Core App
```bash
cd /workspace
git clone https://github.com/biosnu57-netizen/pinc-core.git
cd pinc-core
# Follow AI #1 instructions above
```

### AI #2 - Start Security
```bash
cd /workspace
git clone https://github.com/biosnu57-netizen/pinc-security.git
cd pinc-security
# Follow AI #2 instructions above
```

### AI #3 - Start Games
```bash
cd /workspace
git clone https://github.com/biosnu57-netizen/pinc-games.git
cd pinc-games
# Follow AI #3 instructions above
```

### AI #4 - Start Finance
```bash
cd /workspace
git clone https://github.com/biosnu57-netizen/pinc-finance.git
cd pinc-finance
# Follow AI #4 instructions above
```

---

## ✅ CRITICAL REMINDERS

1. **SEARCH FIRST** - Don't build from scratch, find existing Flutter projects
2. **TEST EVERYTHING** - Build APK before pushing
3. **USE CORRECT CONST** - No const with non-const constructors
4. **KEEP IT SIMPLE** - No over-engineering
5. **PINC STYLING** - Always use cyan (#00D4AA) + dark (#0A0E14)

---

**This document is the source of truth. Every AI must follow these instructions exactly.**

🔐 Build with precision. Test relentlessly. Ship only what works. 🎮