import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const PincNetworkApp());

class PincNetworkApp extends StatelessWidget {
  const PincNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINC Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0E14)),
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
      appBar: AppBar(title: const Text('PINC VPN'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
              child: const Text('Connect', style: TextStyle(color: Color(0xFF0A0E14), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(children: [
              Text('Total Balance', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 14)),
              SizedBox(height: 8),
              Text('0.00 PINC', style: TextStyle(color: Color(0xFF0A0E14), fontSize: 32, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _walletAction(Icons.upload, 'Send'),
              _walletAction(Icons.download, 'Receive'),
              _walletAction(Icons.swap_horiz, 'Swap'),
            ],
          ),
          const SizedBox(height: 24),
          _tile(Icons.credit_card, 'Credit Card', 'Via agents'),
          _tile(Icons.paid, 'P2P Agents', 'Country-based'),
          _tile(Icons.account_balance, 'PayPal', 'Third-party'),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('Transfer Types', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _transferCard('1', 'Subscription', 'Recurring', const Color(0xFF667eea)),
          _transferCard('2', 'Wagers', 'Gaming escrow', const Color(0xFFf093fb)),
          _transferCard('3', 'Savings', 'Protected', const Color(0xFF11998e)),
          _transferCard('4', 'Service Payment', 'Jobs/freelance', const Color(0xFF4facfe)),
        ]),
      ),
    );
  }

  Widget _walletAction(IconData icon, String label) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF00D4AA)),
      ),
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00D4AA)),
        ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D4AA), onPressed: () {},
        child: const Icon(Icons.edit, color: Color(0xFF0A0E14)),
      ),
      body: ListView(children: const [
        ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('A', style: TextStyle(color: Color(0xFF0A0E14)))),
          title: Text('Alice', style: TextStyle(color: Colors.white)),
          subtitle: Text('Hey! How are you?', style: TextStyle(color: Colors.grey)),
          trailing: Text('2:34 PM', style: TextStyle(color: Colors.grey))),
        ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF00D4AA), child: Text('B', style: TextStyle(color: Color(0xFF0A0E14)))),
          title: Text('Bob (Work)', style: TextStyle(color: Colors.white)),
          subtitle: Text('Project ready', style: TextStyle(color: Colors.grey)),
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Remote Jobs'), backgroundColor: const Color(0xFF0A0E14),
          bottom: const TabBar(labelColor: Color(0xFF00D4AA), indicatorColor: Color(0xFF00D4AA),
            tabs: [Tab(text: 'Find Jobs'), Tab(text: 'My Jobs'), Tab(text: 'Post Job')])),
        backgroundColor: const Color(0xFF0A0E14),
        body: const TabBarView(children: [_FindJobsView(), _MyJobsView(), _PostJobView()]),
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
  Widget build(BuildContext context) {
    return const Center(child: Text('No active jobs yet', style: TextStyle(color: Colors.grey)));
  }
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

// ==================== GAMES HUB TAB WITH 6 PLAYABLE GAMES ====================
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
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.all(16),
        children: [
          _GameCard(name: 'Chess', icon: '♔', color: const Color(0xFF8B4513), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChessGame()))),
          _GameCard(name: 'Checkers', icon: '⭕', color: const Color(0xFFDC143C), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckersGame()))),
          _GameCard(name: 'Tetris', icon: '🧱', color: const Color(0xFF00CED1), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TetrisGame()))),
          _GameCard(name: 'Snake', icon: '🐍', color: const Color(0xFF32CD32), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnakeGame()))),
          _GameCard(name: 'Pong', icon: '🏓', color: const Color(0xFFFF6347), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PongGame()))),
          _GameCard(name: 'Wordle', icon: '📝', color: const Color(0xFFFFD700), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordleGame()))),
        ],
      ),
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

// ==================== CHESS GAME ====================
class ChessGame extends StatefulWidget {
  const ChessGame({super.key});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  List<List<String>> board = List.generate(8, (_) => List.generate(8, (_) => ''));
  bool whiteTurn = true;
  String? selectedPiece;
  int? selectedRow, selectedCol;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    // Set up pieces
    for (int i = 0; i < 8; i++) {
      board[1][i] = '♟'; // Black pawns
      board[6][i] = '♙'; // White pawns
    }
    board[0] = ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'];
    board[7] = ['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Column(children: [
        Text(whiteTurn ? "White's Turn" : "Black's Turn", style: const TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemCount: 64,
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;
              bool isDark = (row + col) % 2 == 1;
              bool isSelected = selectedRow == row && selectedCol == col;
              return GestureDetector(
                onTap: () => _onTap(row, col),
                child: Container(
                  color: isSelected ? const Color(0xFF00D4AA) : (isDark ? Colors.brown[800] : Colors.brown[300]),
                  child: Center(child: Text(board[row][col], style: TextStyle(fontSize: 32, color: board[row][col].isNotEmpty ? (board[row][col].codeUnitAt(0) > 0x2600 ? Colors.white : Colors.black) : null))),
                ),
              );
            },
          ),
        ),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Exit')),
      ]),
    );
  }

  void _onTap(int row, int col) {
    if (selectedPiece == null) {
      if (board[row][col].isNotEmpty) {
        setState(() {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        });
      }
    } else {
      setState(() {
        board[row][col] = selectedPiece!;
        board[selectedRow!][selectedCol!] = '';
        selectedPiece = null;
        selectedRow = null;
        selectedCol = null;
        whiteTurn = !whiteTurn;
      });
    }
  }
}

// ==================== CHECKERS GAME ====================
class CheckersGame extends StatefulWidget {
  const CheckersGame({super.key});

  @override
  State<CheckersGame> createState() => _CheckersGameState();
}

class _CheckersGameState extends State<CheckersGame> {
  List<List<int>> board = List.generate(8, (_) => List.generate(8, (_) => 0));
  // 0 = empty, 1 = white, 2 = black, 3 = white king, 4 = black king

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 == 1) {
          if (r < 3) board[r][c] = 2;
          else if (r > 4) board[r][c] = 1;
        }
      }
    }
  }

  String _piece(int p) {
    if (p == 1) return '⚪';
    if (p == 2) return '⚫';
    if (p == 3) return '👑';
    if (p == 4) return '👑';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkers'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: 64,
        itemBuilder: (context, index) {
          int row = index ~/ 8;
          int col = index % 8;
          bool isDark = (row + col) % 2 == 1;
          return Container(
            color: isDark ? Colors.black : Colors.white,
            child: Center(child: Text(_piece(board[row][col]), style: const TextStyle(fontSize: 28))),
          );
        },
      ),
    );
  }
}

// ==================== TETRIS GAME ====================
class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  List<List<int>> board = List.generate(20, (_) => List.filled(10, 0));
  List<List<int>> piece = [[1, 1, 1, 1]];
  int px = 3, py = 0;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tetris - Score: $score'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Column(children: [
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
            itemCount: 200,
            itemBuilder: (context, index) {
              int row = index ~/ 10;
              int col = index % 10;
              bool isPiece = py >= 0 && py < piece.length && px >= 0 && px < piece[0].length && piece[py][px] == 1;
              return Container(
                color: (board[row][col] == 1 || isPiece) ? const Color(0xFF00D4AA) : Colors.grey[800],
                margin: const EdgeInsets.all(1),
              );
            },
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: ElevatedButton(onPressed: _moveDown, child: const Text('Drop'))),
      ]),
    );
  }

  void _moveDown() {
    setState(() {
      py++;
      if (py >= 20 - piece.length) {
        for (int r = 0; r < piece.length; r++) {
          for (int c = 0; c < piece[0].length; c++) {
            if (piece[r][c] == 1 && py + r < 20) board[py + r][px + c] = 1;
          }
        }
        score += 10;
        py = 0;
        px = 3;
      }
    });
  }
}

// ==================== SNAKE GAME ====================
class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  List<List<int>> board = List.generate(20, (_) => List.filled(20, 0));
  List<int> snake = [0, 1, 2];
  int direction = 1; // 0=up,1=right,2=down,3=left
  int food = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _placeFood();
  }

  void _placeFood() {
    food = Random().nextInt(400);
    while (snake.contains(food)) food = Random().nextInt(400);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snake - Score: $score'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 20),
        itemCount: 400,
        itemBuilder: (context, index) {
          return Container(
            color: index == food ? Colors.red : (snake.contains(index) ? const Color(0xFF00D4AA) : Colors.black),
          );
        },
      ),
    );
  }
}

// ==================== PONG GAME ====================
class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> {
  double ballX = 0.5, ballY = 0.5;
  double ballDX = 0.02, ballDY = 0.02;
  double paddle1Y = 0.4, paddle2Y = 0.4;
  int p1Score = 0, p2Score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pong - $p1Score : $p2Score'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: GestureDetector(
        onVerticalDragUpdate: (d) => setState(() {
          paddle2Y = (paddle2Y + d.delta.dy / 500).clamp(0.1, 0.8);
        }),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              Container(color: Colors.black),
              Positioned(left: 10, top: paddle1Y * 300, child: Container(width: 10, height: 60, color: Colors.white)),
              Positioned(right: 10, top: paddle2Y * 300, child: Container(width: 10, height: 60, color: Colors.white)),
              Positioned(left: ballX * 300, top: ballY * 400, child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF00D4AA), shape: BoxShape.circle))),
            ]),
          ),
          ElevatedButton(onPressed: _reset, child: const Text('Reset')),
        ]),
      ),
    );
  }

  void _reset() {
    setState(() {
      ballX = 0.5;
      ballY = 0.5;
      ballDX = 0.02;
      ballDY = 0.02;
    });
  }
}

// ==================== WORDLE GAME ====================
class WordleGame extends StatefulWidget {
  const WordleGame({super.key});

  @override
  State<WordleGame> createState() => _WordleGameState();
}

class _WordleGameState extends State<WordleGame> {
  final List<String> words = ['HELLO', 'WORLD', 'GAMES', 'PINC', 'CRYPT', 'BLOCK', 'CHAT', 'WALLET', 'VPN', 'NETWORK'];
  late String target;
  List<String> guesses = [];
  String current = '';
  int maxGuesses = 6;

  @override
  void initState() {
    super.initState();
    target = words[Random().nextInt(words.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wordle'), backgroundColor: const Color(0xFF0A0E14)),
      backgroundColor: const Color(0xFF0A0E14),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: maxGuesses,
            itemBuilder: (context, i) {
              String guess = i < guesses.length ? guesses[i] : '';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (j) {
                    Color bg = Colors.grey[800]!;
                    if (guess.length > j) {
                      if (target[j] == guess[j]) bg = Colors.green;
                      else if (target.contains(guess[j])) bg = Colors.orange;
                    }
                    return Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.white)),
                      child: Center(child: Text(guess.length > j ? guess[j] : '', style: const TextStyle(color: Colors.white, fontSize: 24))),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            maxLength: 5,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            decoration: InputDecoration(hintText: 'Enter 5 letters', hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A2028)),
            onSubmitted: (v) {
              if (v.length == 5 && guesses.length < maxGuesses) {
                setState(() {
                  guesses.add(v.toUpperCase());
                  current = '';
                  if (v.toUpperCase() == target) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You Won!')));
                  } else if (guesses.length >= maxGuesses) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Game Over! Word: $target')));
                  }
                });
              }
            },
          ),
        ),
      ]),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)]), shape: BoxShape.circle),
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
              Text('6-Phase Security', style: TextStyle(color: Colors.green, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),
          _profileItem(Icons.shield, 'Security'),
          _profileItem(Icons.forum, 'Forums'),
          _profileItem(Icons.settings, 'Settings'),
          _profileItem(Icons.help, 'Help & Support'),
        ]),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2028), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00D4AA))),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }
}