import 'dart:async';
import 'dart:math';

/// PINC Network Gaming Platform
/// Built-in games, leagues, competitions, and betting system
class PincGamesService {
  static final PincGamesService _instance = PincGamesService._internal();
  factory PincGamesService() => _instance;
  PincGamesService._internal();

  // Games storage
  final List<GameSession> _sessions = [];
  final List<League> _leagues = [];
  final Map<String, List<GameRecord>> _gameRecords = {};
  final Map<String, double> _userBalances = {};

  // Getters
  List<GameSession> get activeSessions => _sessions.where((s) => s.status == GameStatus.active).toList();
  List<League> get activeLeagues => _leagues.where((l) => l.status == LeagueStatus.active).toList();
  List<GameInfo> get availableGames => _getAvailableGames();

  // ============================================
  // AVAILABLE GAMES
  // ============================================

  List<GameInfo> _getAvailableGames() {
    return [
      GameInfo(
        id: 'chess',
        name: 'Chess',
        description: 'Classic strategy game. Checkmate your opponent!',
        minPlayers: 2,
        maxPlayers: 2,
        gameType: GameType.board,
        minBet: 1.0,
        maxBet: 10000.0,
        icon: '♔',
      ),
      GameInfo(
        id: 'checkers',
        name: 'Checkers',
        description: 'Jump and capture all opponent pieces.',
        minPlayers: 2,
        maxPlayers: 2,
        gameType: GameType.board,
        minBet: 1.0,
        maxBet: 10000.0,
        icon: '⭕',
      ),
      GameInfo(
        id: 'draughts',
        name: 'Draughts',
        description: 'International draughts with varied rules.',
        minPlayers: 2,
        maxPlayers: 2,
        gameType: GameType.board,
        minBet: 1.0,
        maxBet: 10000.0,
        icon: '◎',
      ),
      GameInfo(
        id: 'tetriss',
        name: 'Tetris',
        description: 'Stack blocks and clear lines. High score wins!',
        minPlayers: 1,
        maxPlayers: 50,
        gameType: GameType.puzzle,
        minBet: 1.0,
        maxBet: 1000.0,
        icon: '🧱',
      ),
      GameInfo(
        id: 'snake',
        name: 'Snake',
        description: 'Eat food, grow longer, avoid walls.',
        minPlayers: 1,
        maxPlayers: 50,
        gameType: GameType.arcade,
        minBet: 1.0,
        maxBet: 500.0,
        icon: '🐍',
      ),
      GameInfo(
        id: 'pong',
        name: 'Pong',
        description: 'Classic paddle game. First to score wins!',
        minPlayers: 2,
        maxPlayers: 2,
        gameType: GameType.arcade,
        minBet: 1.0,
        maxBet: 5000.0,
        icon: '🏓',
      ),
      GameInfo(
        id: 'tic_tac_toe',
        name: 'Tic Tac Toe',
        description: '3-in-a-row. Simple and addictive!',
        minPlayers: 2,
        maxPlayers: 2,
        gameType: GameType.board,
        minBet: 1.0,
        maxBet: 100.0,
        icon: '❌',
      ),
      GameInfo(
        id: 'wordle',
        name: 'Wordle',
        description: 'Guess the 5-letter word in 6 tries.',
        minPlayers: 1,
        maxPlayers: 50,
        gameType: GameType.puzzle,
        minBet: 1.0,
        maxBet: 500.0,
        icon: '📝',
      ),
      GameInfo(
        id: 'memory',
        name: 'Memory Match',
        description: 'Match pairs of cards. Fastest wins!',
        minPlayers: 1,
        maxPlayers: 10,
        gameType: GameType.puzzle,
        minBet: 1.0,
        maxBet: 200.0,
        icon: '🃏',
      ),
      GameInfo(
        id: 'quiz',
        name: 'Quiz',
        description: 'Test your knowledge across categories.',
        minPlayers: 1,
        maxPlayers: 100,
        gameType: GameType.trivia,
        minBet: 1.0,
        maxBet: 1000.0,
        icon: '❓',
      ),
    ];
  }

  // ============================================
  // GAME SESSIONS
  // ============================================

  /// Create new game session
  Future<GameSession> createSession({
    required String gameId,
    required String hostId,
    required double bet,
    required bool isRanked,
    Map<String, dynamic>? gameSettings,
  }) async {
    final gameInfo = _getGameInfo(gameId);
    final session = GameSession(
      id: _generateId(),
      gameId: gameId,
      hostId: hostId,
      players: [hostId],
      bet: bet,
      isRanked: isRanked,
      status: GameStatus.waiting,
      createdAt: DateTime.now(),
      settings: gameSettings ?? {},
    );

    _sessions.add(session);
    _gameRecords[session.id] = [];

    return session;
  }

  /// Join existing game
  Future<bool> joinSession({
    required String sessionId,
    required String userId,
  }) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final gameInfo = _getGameInfo(session.gameId);

    if (session.players.length >= gameInfo.maxPlayers) {
      return false;
    }

    final updatedPlayers = List<String>.from(session.players)..add(userId);
    final updatedSession = session.copyWith(
      players: updatedPlayers,
      status: session.players.length + 1 >= gameInfo.minPlayers
          ? GameStatus.active
          : GameStatus.waiting,
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;

    return true;
  }

  /// Submit game score
  Future<void> submitScore({
    required String sessionId,
    required String userId,
    required double score,
    required int duration,
  }) async {
    _gameRecords[sessionId] ??= [];
    _gameRecords[sessionId]!.add(GameRecord(
      id: _generateId(),
      sessionId: sessionId,
      userId: userId,
      score: score,
      duration: duration,
      timestamp: DateTime.now(),
    ));
  }

  /// End game session
  Future<GameResult> endSession({
    required String sessionId,
    required String winnerId,
  }) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final index = _sessions.indexWhere((s) => s.id == sessionId);

    _sessions[index] = session.copyWith(
      status: GameStatus.completed,
      winnerId: winnerId,
    );

    // Calculate winnings
    final totalPot = session.bet * session.players.length;
    final winnerShare = session.isRanked ? totalPot * 0.9 : totalPot;

    return GameResult(
      sessionId: sessionId,
      winnerId: winnerId,
      totalPot: totalPot,
      winnerShare: winnerShare,
      isRanked: session.isRanked,
    );
  }

  /// Get game high scores
  List<GameRecord> getHighScores(String gameId, {int limit = 10}) {
    final records = <GameRecord>[];
    for (final sessionRecords in _gameRecords.values) {
      records.addAll(sessionRecords);
    }
    records.sort((a, b) => b.score.compareTo(a.score));
    return records.take(limit).toList();
  }

  // ============================================
  // LEAGUES
  // ============================================

  /// Create a league
  Future<League> createLeague({
    required String creatorId,
    required String name,
    required String gameId,
    required double entryFee,
    required int maxPlayers,
    required DateTime startDate,
    required DateTime endDate,
    LeagueType leagueType = LeagueType.elimination,
  }) async {
    final league = League(
      id: _generateId(),
      name: name,
      gameId: gameId,
      creatorId: creatorId,
      entryFee: entryFee,
      maxPlayers: maxPlayers,
      currentPlayers: 1,
      startDate: startDate,
      endDate: endDate,
      leagueType: leagueType,
      status: LeagueStatus.active,
      players: [LeaguePlayer(
        id: _generateId(),
        userId: creatorId,
        joinedAt: DateTime.now(),
        rank: 1,
        wins: 0,
        losses: 0,
        points: 0,
      )],
      createdAt: DateTime.now(),
    );

    _leagues.add(league);
    return league;
  }

  /// Join league
  Future<bool> joinLeague({
    required String leagueId,
    required String userId,
  }) async {
    final league = _leagues.firstWhere((l) => l.id == leagueId);

    if (league.currentPlayers >= league.maxPlayers) {
      return false;
    }

    if (league.players.any((p) => p.userId == userId)) {
      return false; // Already joined
    }

    final newPlayer = LeaguePlayer(
      id: _generateId(),
      userId: userId,
      joinedAt: DateTime.now(),
      rank: league.currentPlayers + 1,
      wins: 0,
      losses: 0,
      points: 0,
    );

    final updatedPlayers = List<LeaguePlayer>.from(league.players)..add(newPlayer);
    final index = _leagues.indexWhere((l) => l.id == leagueId);
    _leagues[index] = league.copyWith(
      players: updatedPlayers,
      currentPlayers: league.currentPlayers + 1,
    );

    return true;
  }

  /// Get league leaderboard
  List<LeaguePlayer> getLeagueLeaderboard(String leagueId) {
    final league = _leagues.firstWhere((l) => l.id == leagueId);
    final sorted = List<LeaguePlayer>.from(league.players);
    sorted.sort((a, b) => b.points.compareTo(a.points));
    return sorted;
  }

  /// End league and award winners
  Future<List<LeagueReward>> endLeague({
    required String leagueId,
  }) async {
    final league = _leagues.firstWhere((l) => l.id == leagueId);
    final leaderboard = getLeagueLeaderboard(leagueId);

    final rewards = <LeagueReward>[];
    final prizePool = league.entryFee * league.currentPlayers;

    // Top 3 get prizes
    if (leaderboard.isNotEmpty) {
      rewards.add(LeagueReward(
        position: 1,
        userId: leaderboard[0].userId,
        amount: prizePool * 0.50,
        title: 'Champion',
      ));
    }
    if (leaderboard.length > 1) {
      rewards.add(LeagueReward(
        position: 2,
        userId: leaderboard[1].userId,
        amount: prizePool * 0.30,
        title: 'Runner Up',
      ));
    }
    if (leaderboard.length > 2) {
      rewards.add(LeagueReward(
        position: 3,
        userId: leaderboard[2].userId,
        amount: prizePool * 0.20,
        title: 'Third Place',
      ));
    }

    // Update league status
    final index = _leagues.indexWhere((l) => l.id == leagueId);
    _leagues[index] = league.copyWith(status: LeagueStatus.completed);

    return rewards;
  }

  // ============================================
  // BETTING SYSTEM
  // ============================================

  /// Create custom bet
  Future<Bet> createBet({
    required String creatorId,
    required String title,
    required String description,
    required double amount,
    required List<String> options,
    required DateTime deadline,
  }) async {
    final bet = Bet(
      id: _generateId(),
      creatorId: creatorId,
      title: title,
      description: description,
      amount: amount,
      options: options,
      bets: {},
      status: BetStatus.active,
      deadline: deadline,
      createdAt: DateTime.now(),
    );

    return bet;
  }

  /// Place bet on option
  Future<bool> placeBet({
    required String betId,
    required String userId,
    required String option,
  }) async {
    // Verify bet is active and not expired
    // Add user to bet options
    return true;
  }

  /// Resolve bet (creator decides winner)
  Future<void> resolveBet({
    required String betId,
    required String winningOption,
    required String resolverId,
  }) async {
    // Distribute winnings to winners
  }

  // ============================================
  // GAME LOGIC (Simplified)
  // ============================================

  GameInfo _getGameInfo(String gameId) {
    return _getAvailableGames().firstWhere((g) => g.id == gameId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(9999).toString();
  }

  /// Validate chess move (simplified)
  bool validateChessMove(String from, String to, String piece) {
    // Simplified - real implementation would have full chess logic
    return true;
  }

  /// Validate checkers move
  bool validateCheckersMove(String from, String to, bool isKing) {
    // Simplified
    return true;
  }

  /// Calculate tetris score
  int calculateTetrisScore(int linesCleared, int level) {
    // Standard tetris scoring
    final baseScores = [0, 100, 300, 500, 800, 1200];
    return baseScores[linesCleared.clamp(0, 5)] * (level + 1);
  }
}

// ============================================
// DATA MODELS
// ============================================

enum GameType {
  board,
  arcade,
  puzzle,
  trivia,
  other,
}

enum GameStatus {
  waiting,
  active,
  paused,
  completed,
  cancelled,
}

enum LeagueType {
  elimination,
  roundRobin,
  points,
}

enum LeagueStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

enum BetStatus {
  draft,
  active,
  resolved,
  cancelled,
}

class GameInfo {
  final String id;
  final String name;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final GameType gameType;
  final double minBet;
  final double maxBet;
  final String icon;

  GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.gameType,
    required this.minBet,
    required this.maxBet,
    required this.icon,
  });
}

class GameSession {
  final String id;
  final String gameId;
  final String hostId;
  final List<String> players;
  final double bet;
  final bool isRanked;
  final GameStatus status;
  final String? winnerId;
  final DateTime createdAt;
  final Map<String, dynamic> settings;

  GameSession({
    required this.id,
    required this.gameId,
    required this.hostId,
    required this.players,
    required this.bet,
    required this.isRanked,
    required this.status,
    this.winnerId,
    required this.createdAt,
    required this.settings,
  });

  GameSession copyWith({
    List<String>? players,
    GameStatus? status,
    String? winnerId,
  }) {
    return GameSession(
      id: id,
      gameId: gameId,
      hostId: hostId,
      players: players ?? this.players,
      bet: bet,
      isRanked: isRanked,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      createdAt: createdAt,
      settings: settings,
    );
  }
}

class GameRecord {
  final String id;
  final String sessionId;
  final String userId;
  final double score;
  final int duration;
  final DateTime timestamp;

  GameRecord({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.score,
    required this.duration,
    required this.timestamp,
  });
}

class GameResult {
  final String sessionId;
  final String winnerId;
  final double totalPot;
  final double winnerShare;
  final bool isRanked;

  GameResult({
    required this.sessionId,
    required this.winnerId,
    required this.totalPot,
    required this.winnerShare,
    required this.isRanked,
  });
}

class League {
  final String id;
  final String name;
  final String gameId;
  final String creatorId;
  final double entryFee;
  final int maxPlayers;
  final int currentPlayers;
  final DateTime startDate;
  final DateTime endDate;
  final LeagueType leagueType;
  final LeagueStatus status;
  final List<LeaguePlayer> players;
  final DateTime createdAt;

  League({
    required this.id,
    required this.name,
    required this.gameId,
    required this.creatorId,
    required this.entryFee,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.startDate,
    required this.endDate,
    required this.leagueType,
    required this.status,
    required this.players,
    required this.createdAt,
  });

  League copyWith({
    List<LeaguePlayer>? players,
    int? currentPlayers,
    LeagueStatus? status,
  }) {
    return League(
      id: id,
      name: name,
      gameId: gameId,
      creatorId: creatorId,
      entryFee: entryFee,
      maxPlayers: maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      startDate: startDate,
      endDate: endDate,
      leagueType: leagueType,
      status: status ?? this.status,
      players: players ?? this.players,
      createdAt: createdAt,
    );
  }
}

class LeaguePlayer {
  final String id;
  final String userId;
  final DateTime joinedAt;
  final int rank;
  final int wins;
  final int losses;
  final double points;

  LeaguePlayer({
    required this.id,
    required this.userId,
    required this.joinedAt,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.points,
  });
}

class LeagueReward {
  final int position;
  final String userId;
  final double amount;
  final String? title;

  LeagueReward({
    required this.position,
    required this.userId,
    required this.amount,
    this.title,
  });
}

class Bet {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final double amount;
  final List<String> options;
  final Map<String, List<String>> bets;
  final BetStatus status;
  final String? winningOption;
  final DateTime deadline;
  final DateTime createdAt;

  Bet({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.amount,
    required this.options,
    required this.bets,
    required this.status,
    this.winningOption,
    required this.deadline,
    required this.createdAt,
  });
}