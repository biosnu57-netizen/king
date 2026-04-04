// PINC Network - Game Service
// Handles built-in games, challenges, and leagues

import 'fee_service.dart';
import 'storage_service.dart';

class GameService {
  List<Map<String, dynamic>> _challenges = [];
  List<Map<String, dynamic>> _leagues = [];
  
  // ==================== GET DATA ====================
  
  List<Map<String, dynamic>> getChallenges() => _challenges;
  List<Map<String, dynamic>> getLeagues() => _leagues;
  
  // ==================== INITIALIZE ====================
  
  Future<void> initialize() async {
    _challenges = LocalStorageService.getChallenges();
    _leagues = LocalStorageService.getLeagues();
  }
  
  // ==================== CREATE P2P CHALLENGE ====================
  
  Future<Map<String, dynamic>> createP2PChallenge({
    required String creatorPincId,
    required String gameType,
    required double entryFee,
    required double prizePool,
    double? creatorFee,
  }) async {
    // Validate minimum wager
    if (entryFee < FeeService.getMinWager()) {
      return {'success': false, 'error': 'Minimum wager is ${FeeService.getMinWager()} PINC'};
    }
    
    // Calculate fees
    double platformFee = entryFee * FeeService.getP2PBetFee();
    double creatorFeeAmount = creatorFee != null ? entryFee * creatorFee : 0;
    double totalDeducted = entryFee;
    double netPrize = prizePool;
    
    final challenge = {
      'id': _generateChallengeId(),
      'type': 'p2p',
      'creator': creatorPincId,
      'gameType': gameType,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'creatorFee': creatorFeeAmount,
      'platformFee': platformFee,
      'status': 'waiting',
      'participants': [
        {'pincId': creatorPincId, 'role': 'creator', 'joinedAt': DateTime.now().toIso8601String()}
      ],
      'createdAt': DateTime.now().toIso8601String(),
      'expiredAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };
    
    _challenges.insert(0, challenge);
    await LocalStorageService.saveChallenges(_challenges);
    
    return {
      'success': true,
      'challenge': challenge,
      'feeDetails': {
        'entryFee': entryFee,
        'platformFee': platformFee,
        'creatorFee': creatorFeeAmount,
        'netWinnings': prizePool - platformFee - creatorFeeAmount,
      },
    };
  }
  
  // ==================== CREATE GLOBAL CHALLENGE ====================
  
  Future<Map<String, dynamic>> createGlobalChallenge({
    required String creatorPincId,
    required String title,
    required String gameType,
    required double entryFee,
    required int winnerPositions,
    required double prizePool,
  }) async {
    // Global challenge requires 1560 PINC creation fee
    double creationFee = FeeService.getGlobalChallengeFee();
    
    final challenge = {
      'id': _generateChallengeId(),
      'type': 'global',
      'creator': creatorPincId,
      'title': title,
      'gameType': gameType,
      'entryFee': entryFee,
      'winnerPositions': winnerPositions,
      'prizePool': prizePool,
      'creationFee': creationFee,
      'platformFeePercent': FeeService.getChallengeCollectionFee() * 100,
      'status': 'open',
      'participants': [],
      'broadcastEndsAt': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _challenges.insert(0, challenge);
    await LocalStorageService.saveChallenges(_challenges);
    
    return {
      'success': true,
      'challenge': challenge,
      'feeDetails': {
        'creationFee': creationFee,
        'prizePool': prizePool,
        'platformFee': prizePool * FeeService.getChallengeCollectionFee(),
        'perWinner': (prizePool * (1 - FeeService.getChallengeCollectionFee())) / winnerPositions,
      },
    };
  }
  
  // ==================== JOIN CHALLENGE ====================
  
  Future<Map<String, dynamic>> joinChallenge({
    required String challengeId,
    required String pincId,
  }) async {
    final index = _challenges.indexWhere((c) => c['id'] == challengeId);
    if (index < 0) {
      return {'success': false, 'error': 'Challenge not found'};
    }
    
    Map<String, dynamic> challenge = _challenges[index];
    
    // Check if already joined
    List participants = List.from(challenge['participants'] ?? []);
    if (participants.any((p) => p['pincId'] == pincId)) {
      return {'success': false, 'error': 'Already joined'};
    }
    
    // For P2P, can only have 2 participants
    if (challenge['type'] == 'p2p' && participants.length >= 2) {
      return {'success': false, 'error': 'Challenge full'};
    }
    
    participants.add({
      'pincId': pincId,
      'role': 'participant',
      'joinedAt': DateTime.now().toIso8601String(),
      'score': 0,
    });
    
    _challenges[index]['participants'] = participants;
    
    // If P2P and full, start the challenge
    if (challenge['type'] == 'p2p' && participants.length == 2) {
      _challenges[index]['status'] = 'active';
      _challenges[index]['startedAt'] = DateTime.now().toIso8601String();
    }
    
    await LocalStorageService.saveChallenges(_challenges);
    
    return {'success': true, 'challenge': _challenges[index], 'participantCount': participants.length};
  }
  
  // ==================== SUBMIT SCORE ====================
  
  Future<Map<String, dynamic>> submitScore({
    required String challengeId,
    required String pincId,
    required double score,
  }) async {
    final index = _challenges.indexWhere((c) => c['id'] == challengeId);
    if (index < 0) {
      return {'success': false, 'error': 'Challenge not found'};
    }
    
    List participants = List.from(_challenges[index]['participants'] ?? []);
    int pIndex = participants.indexWhere((p) => p['pincId'] == pincId);
    
    if (pIndex < 0) {
      return {'success': false, 'error': 'Not a participant'};
    }
    
    participants[pIndex]['score'] = score;
    _challenges[index]['participants'] = participants;
    
    await LocalStorageService.saveChallenges(_challenges);
    
    return {'success': true, 'score': score, 'participants': participants};
  }
  
  // ==================== END CHALLENGE & DISTRIBUTE PRIZES ====================
  
  Future<Map<String, dynamic>> endChallenge({
    required String challengeId,
    required String refereePincId,
  }) async {
    final index = _challenges.indexWhere((c) => c['id'] == challengeId);
    if (index < 0) {
      return {'success': false, 'error': 'Challenge not found'};
    }
    
    Map<String, dynamic> challenge = _challenges[index];
    List participants = List.from(challenge['participants'] ?? []);
    
    // Sort by score (descending)
    participants.sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));
    
    // Calculate prizes
    double prizePool = challenge['prizePool'] ?? 0;
    double platformFee = prizePool * FeeService.getChallengeCollectionFee();
    double prizeMoney = prizePool - platformFee;
    
    int winnerPositions = challenge['winnerPositions'] ?? 1;
    double perWinner = prizeMoney / winnerPositions;
    
    // Create winners list with prizes
    List winners = [];
    for (int i = 0; i < winnerPositions && i < participants.length; i++) {
      winners.add({
        'position': i + 1,
        'pincId': participants[i]['pincId'],
        'score': participants[i]['score'],
        'prize': perWinner,
      });
    }
    
    _challenges[index]['status'] = 'completed';
    _challenges[index]['endedAt'] = DateTime.now().toIso8601String();
    _challenges[index]['referee'] = refereePincId;
    _challenges[index]['winners'] = winners;
    _challenges[index]['platformFee'] = platformFee;
    
    await LocalStorageService.saveChallenges(_challenges);
    
    return {
      'success': true,
      'challenge': _challenges[index],
      'winners': winners,
      'prizeDetails': {
        'totalPrizePool': prizePool,
        'platformFee': platformFee,
        'prizeMoney': prizeMoney,
        'perWinner': perWinner,
      },
    };
  }
  
  // ==================== CREATE LEAGUE ====================
  
  Future<Map<String, dynamic>> createLeague({
    required String creatorPincId,
    required String name,
    required String gameType,
    required double entryFee,
    required int maxPlayers,
  }) async {
    final league = {
      'id': _generateLeagueId(),
      'name': name,
      'creator': creatorPincId,
      'gameType': gameType,
      'entryFee': entryFee,
      'maxPlayers': maxPlayers,
      'platformFeePercent': 9.0, // 9% of total pool
      'status': 'open',
      'players': [
        {'pincId': creatorPincId, 'joinedAt': DateTime.now().toIso8601String(), 'points': 0, 'wins': 0, 'losses': 0}
      ],
      'matches': [],
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _leagues.insert(0, league);
    await LocalStorageService.saveLeagues(_leagues);
    
    return {'success': true, 'league': league};
  }
  
  // ==================== JOIN LEAGUE ====================
  
  Future<Map<String, dynamic>> joinLeague({
    required String leagueId,
    required String pincId,
  }) async {
    final index = _leagues.indexWhere((l) => l['id'] == leagueId);
    if (index < 0) {
      return {'success': false, 'error': 'League not found'};
    }
    
    Map<String, dynamic> league = _leagues[index];
    List players = List.from(league['players'] ?? []);
    
    if (players.length >= (league['maxPlayers'] ?? 50)) {
      return {'success': false, 'error': 'League full'};
    }
    
    if (players.any((p) => p['pincId'] == pincId)) {
      return {'success': false, 'error': 'Already in league'};
    }
    
    players.add({
      'pincId': pincId,
      'joinedAt': DateTime.now().toIso8601String(),
      'points': 0,
      'wins': 0,
      'losses': 0,
    });
    
    _leagues[index]['players'] = players;
    
    if (players.length >= 2 && league['status'] == 'open') {
      _leagues[index]['status'] = 'active';
    }
    
    await LocalStorageService.saveLeagues(_leagues);
    
    return {'success': true, 'league': _leagues[index], 'playerCount': players.length};
  }
  
  // ==================== GET LEAGUE STANDINGS ====================
  
  List<Map<String, dynamic>> getLeagueStandings(String leagueId) {
    final index = _leagues.indexWhere((l) => l['id'] == leagueId);
    if (index < 0) return [];
    
    List players = List.from(_leagues[index]['players'] ?? []);
    players.sort((a, b) => (b['points'] ?? 0).compareTo(a['points'] ?? 0));
    
    List<Map<String, dynamic>> standings = players.asMap().entries.map((e) => {
      'position': e.key + 1,
      ...Map<String, dynamic>.from(e.value),
    }).toList();
    return standings;
  }
  
  // ==================== BUILT-IN GAMES ====================
  
  // Simple Tic-Tac-Toe logic
  static List<int>? checkTicTacToeWinner(List<String> board) {
    // Rows
    for (int i = 0; i < 3; i++) {
      if (board[i*3] != '' && board[i*3] == board[i*3+1] && board[i*3] == board[i*3+2]) {
        return [i*3, i*3+1, i*3+2];
      }
    }
    // Columns
    for (int i = 0; i < 3; i++) {
      if (board[i] != '' && board[i] == board[i+3] && board[i] == board[i+6]) {
        return [i, i+3, i+6];
      }
    }
    // Diagonals
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8]) {
      return [0, 4, 8];
    }
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6]) {
      return [2, 4, 6];
    }
    return null;
  }
  
  // Snake game state
  static Map<String, dynamic> initSnakeGame() {
    return {
      'snake': [[5, 5], [5, 6], [5, 7]], // Initial snake positions
      'food': [10, 10],
      'direction': 'up',
      'score': 0,
      'gameOver': false,
    };
  }
  
  // ==================== HELPERS ====================
  
  String _generateChallengeId() => 'CHG-${DateTime.now().millisecondsSinceEpoch}';
  String _generateLeagueId() => 'LGE-${DateTime.now().millisecondsSinceEpoch}';
}