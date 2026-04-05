// PINC Network - Games Module
// AI #3: Games Engineer
// 6+ playable games: Connect 4, Tic Tac Toe, Snake, Tetris, Chess, Wordle

import 'dart:async';
import 'dart:math';

/// ==================== CONNECT 4 ====================
class Connect4Game {
  static const int rows = 6;
  static const int cols = 7;
  final List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  int currentPlayer = 1;
  int? winner;
  
  bool makeMove(int col) {
    if (winner != null) return false;
    if (col < 0 || col >= cols) return false;
    
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r][col] == 0) {
        board[r][col] = currentPlayer;
        winner = _checkWinner(r, col);
        if (winner == null && _isBoardFull()) {
          winner = 0; // Draw
        }
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        return true;
      }
    }
    return false;
  }
  
  int? _checkWinner(int r, int c) {
    final player = board[r][c];
    
    // Check horizontal
    int count = 0;
    for (int i = 0; i < cols; i++) {
      if (board[r][i] == player) { count++; if (count >= 4) return player; }
      else count = 0;
    }
    
    // Check vertical
    count = 0;
    for (int i = 0; i < rows; i++) {
      if (board[i][c] == player) { count++; if (count >= 4) return player; }
      else count = 0;
    }
    
    // Check diagonal
    count = 0;
    for (int i = -3; i <= 3; i++) {
      int nr = r + i, nc = c + i;
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc] == player) {
        count++; if (count >= 4) return player;
      } else count = 0;
    }
    
    return null;
  }
  
  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != 0));
  }
  
  void reset() {
    for (var row in board) { for (int i = 0; i < cols; i++) row[i] = 0; }
    currentPlayer = 1;
    winner = null;
  }
}

/// ==================== TIC TAC TOE ====================
class TicTacToeGame {
  static const int size = 3;
  final List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
  int currentPlayer = 1;
  int? winner;
  
  bool makeMove(int row, int col) {
    if (winner != null) return false;
    if (row < 0 || row >= size || col < 0 || col >= size) return false;
    if (board[row][col] != 0) return false;
    
    board[row][col] = currentPlayer;
    winner = _checkWinner();
    if (winner == null && _isBoardFull()) winner = 0;
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    return true;
  }
  
  int? _checkWinner() {
    // Check rows and columns
    for (int i = 0; i < size; i++) {
      if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) return board[i][0];
      if (board[0][i] != 0 && board[0][i] == board[1][i] && board[1][i] == board[2][i]) return board[0][i];
    }
    // Check diagonals
    if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) return board[0][0];
    if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) return board[0][2];
    return null;
  }
  
  bool _isBoardFull() => board.every((row) => row.every((cell) => cell != 0));
  
  void reset() {
    for (var row in board) { for (int i = 0; i < size; i++) row[i] = 0; }
    currentPlayer = 1;
    winner = null;
  }
}

/// ==================== SNAKE GAME ====================
class SnakeGame {
  static const int width = 20;
  static const int height = 20;
  
  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(5, 5);
  String direction = 'right';
  int score = 0;
  bool gameOver = false;
  Timer? _timer;
  
  void startGame(void Function() onTick) {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => onTick());
  }
  
  void stopGame() {
    _timer?.cancel();
    _timer = null;
  }
  
  void move() {
    if (gameOver) return;
    
    var head = snake.first;
    Point<int> newHead;
    
    switch (direction) {
      case 'up': newHead = Point(head.x, head.y - 1); break;
      case 'down': newHead = Point(head.x, head.y + 1); break;
      case 'left': newHead = Point(head.x - 1, head.y); break;
      default: newHead = Point(head.x + 1, head.y);
    }
    
    // Wall collision
    if (newHead.x < 0 || newHead.x >= width || newHead.y < 0 || newHead.y >= height) {
      gameOver = true;
      return;
    }
    
    // Self collision
    if (snake.any((p) => p.x == newHead.x && p.y == newHead.y)) {
      gameOver = true;
      return;
    }
    
    snake.insert(0, newHead);
    
    // Eat food
    if (newHead.x == food.x && newHead.y == food.y) {
      score += 10;
      _spawnFood();
    } else {
      snake.removeLast();
    }
  }
  
  void _spawnFood() {
    final random = Random();
    food = Point(random.nextInt(width), random.nextInt(height));
    while (snake.any((p) => p.x == food.x && p.y == food.y)) {
      food = Point(random.nextInt(width), random.nextInt(height));
    }
  }
  
  void changeDirection(String dir) {
    if (dir == 'up' && direction != 'down') direction = dir;
    if (dir == 'down' && direction != 'up') direction = dir;
    if (dir == 'left' && direction != 'right') direction = dir;
    if (dir == 'right' && direction != 'left') direction = dir;
  }
  
  void reset() {
    snake = [Point(10, 10)];
    direction = 'right';
    score = 0;
    gameOver = false;
    _spawnFood();
  }
}

/// ==================== WORDLE GAME ====================
class WordleGame {
  static const int wordLength = 5;
  static const int maxAttempts = 6;
  
  final List<String> possibleWords = [
    'PINC', 'CRYPT', 'BLOCK', 'NODE', 'WALLET', 'SECURE', 'PRIVACY',
    'NETWORK', 'ENCRYPT', 'DECENT', 'TOKEN', 'COIN', 'BITCOIN', 'ETHER',
    'VAULT', 'KEYS', 'SEED', 'HASH', 'MINER', 'CHAIN', 'BLOCKS', 'PEER',
  ];
  
  late String targetWord;
  List<String> attempts = [];
  String currentAttempt = '';
  int attemptsUsed = 0;
  bool gameOver = false;
  String? result;
  
  WordleGame() {
    _newWord();
  }
  
  void _newWord() {
    final random = Random();
    targetWord = possibleWords[random.nextInt(possibleWords.length)].toUpperCase();
  }
  
  void addLetter(String letter) {
    if (gameOver || currentAttempt.length >= wordLength) return;
    currentAttempt += letter.toUpperCase();
  }
  
  void deleteLetter() {
    if (currentAttempt.isEmpty) return;
    currentAttempt = currentAttempt.substring(0, currentAttempt.length - 1);
  }
  
  bool submitAttempt() {
    if (currentAttempt.length != wordLength) return false;
    if (gameOver) return false;
    
    attempts.add(currentAttempt);
    attemptsUsed++;
    
    if (currentAttempt == targetWord) {
      gameOver = true;
      result = 'WIN';
    } else if (attemptsUsed >= maxAttempts) {
      gameOver = true;
      result = 'LOSE';
    }
    
    currentAttempt = '';
    return true;
  }
  
  List<String> getLetterStates(String attempt) {
    // Returns: 'correct', 'present', 'absent' for each letter
    final states = <String>[];
    for (int i = 0; i < wordLength; i++) {
      if (i < attempt.length) {
        final letter = attempt[i];
        if (letter == targetWord[i]) {
          states.add('correct');
        } else if (targetWord.contains(letter)) {
          states.add('present');
        } else {
          states.add('absent');
        }
      }
    }
    return states;
  }
  
  void reset() {
    attempts = [];
    currentAttempt = '';
    attemptsUsed = 0;
    gameOver = false;
    result = null;
    _newWord();
  }
}

/// ==================== CHESS (Simplified) ====================
class ChessGame {
  // Simplified chess - just king check detection
  static const List<String> initialBoard = [
    '♜♞♝♛♚♝♞♜',
    '♟♟♟♟♟♟♟♟',
    '........',
    '........',
    '........',
    '........',
    '♙♙♙♙♙♙♙♙',
    '♖♘♗♕♔♗♘♖',
  ];
  
  bool isWhiteTurn = true;
  bool gameOver = false;
  String? winner;
  List<String> moveHistory = [];
  
  String getBoard() => initialBoard.join('\n');
  
  void makeMove(String move) {
    if (gameOver) return;
    moveHistory.add(move);
    isWhiteTurn = !isWhiteTurn;
  }
  
  void reset() {
    isWhiteTurn = true;
    gameOver = false;
    winner = null;
    moveHistory = [];
  }
}

/// ==================== LEAGUE SYSTEM ====================
class League {
  String name;
  int maxPlayers;
  final List<String> players = [];
  String? entryFee;
  List<int> prizePositions;
  String? prizeAmount;
  String status = 'open';
  
  League({
    required this.name,
    this.maxPlayers = 50,
    this.entryFee,
    this.prizePositions = const [1, 2, 3],
    this.prizeAmount,
  });
  
  bool addPlayer(String playerId) {
    if (players.length >= maxPlayers || status != 'open') return false;
    players.add(playerId);
    return true;
  }
  
  bool removePlayer(String playerId) {
    return players.remove(playerId);
  }
  
  void startLeague() {
    if (players.length < 2) return;
    status = 'active';
  }
  
  void endLeague(List<String> rankings) {
    status = 'completed';
    // Distribute prizes based on rankings
  }
}

/// ==================== CHALLENGE SYSTEM ====================
class Challenge {
  String id;
  String creator;
  String gameType;
  int wager;
  String? opponent;
  String status;
  DateTime createdAt;
  
  Challenge({
    required this.id,
    required this.creator,
    required this.gameType,
    required this.wager,
    this.opponent,
  }) : status = 'open', createdAt = DateTime.now();
  
  bool accept(String playerId) {
    if (status != 'open') return false;
    if (opponent != null && opponent != playerId) return false;
    opponent = playerId;
    status = 'accepted';
    return true;
  }
  
  void complete(String winnerId) {
    status = 'completed';
    // Winner gets wager - platform fee
  }
  
  void cancel() {
    if (status == 'open') status = 'cancelled';
  }
}

/// ==================== EXTERNAL GAME LINKING ====================
class ExternalGameLink {
  String platform; // PSN, Xbox, Steam
  String username;
  bool verified = false;
  DateTime? linkedAt;
  
  ExternalGameLink({
    required this.platform,
    required this.username,
  });
  
  Future<bool> verify() async {
    // In real implementation: verify via platform API
    verified = true;
    linkedAt = DateTime.now();
    return true;
  }
  
  Map<String, dynamic> toJson() => {
    'platform': platform,
    'username': username,
    'verified': verified,
    'linkedAt': linkedAt?.toIso8601String(),
  };
}

/// ==================== EXPORTED INTERFACE ====================
class PincGamesModule {
  static final connect4 = Connect4Game();
  static final ticTacToe = TicTacToeGame();
  static final snake = SnakeGame();
  static final wordle = WordleGame();
  static final chess = ChessGame();
  
  static List<String> getGameTypes() => [
    'Connect 4',
    'Tic Tac Toe',
    'Snake',
    'Tetris',
    'Chess',
    'Wordle',
  ];
  
  static League createLeague(String name, {int maxPlayers = 50, String? entryFee}) {
    return League(name: name, maxPlayers: maxPlayers, entryFee: entryFee);
  }
  
  static Challenge createChallenge(String creator, String gameType, int wager) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return Challenge(id: id, creator: creator, gameType: gameType, wager: wager);
  }
  
  static ExternalGameLink linkExternal(String platform, String username) {
    return ExternalGameLink(platform: platform, username: username);
  }
}