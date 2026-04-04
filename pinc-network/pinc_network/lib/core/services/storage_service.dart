// PINC Network - Local Storage Service
// Handles all local data storage with encryption

import 'dart:convert';
import 'dart:math';

class LocalStorageService {
  // Simulated local storage - in production use SharedPreferences/Hive/SQLite
  static final Map<String, dynamic> _storage = {};
  
  // ==================== USER DATA ====================
  
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    _storage['user'] = _encryptData(jsonEncode(userData));
  }
  
  static Map<String, dynamic>? getUserData() {
    final data = _storage['user'];
    if (data == null) return null;
    return jsonDecode(_decryptData(data));
  }
  
  // ==================== WALLET DATA ====================
  
  static Future<void> saveWalletData(double balance, List<Map<String, dynamic>> transactions) async {
    _storage['wallet'] = _encryptData(jsonEncode({
      'balance': balance,
      'transactions': transactions,
    }));
  }
  
  static Map<String, dynamic> getWalletData() {
    final data = _storage['wallet'];
    if (data == null) {
      return {'balance': 0.0, 'transactions': []};
    }
    return jsonDecode(_decryptData(data));
  }
  
  static Future<void> addTransaction(Map<String, dynamic> transaction) async {
    final wallet = getWalletData();
    List<Map<String, dynamic>> transactions = List<Map<String, dynamic>>.from(wallet['transactions']);
    transactions.insert(0, {
      ...transaction,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 365 days of transactions
    if (transactions.length > 365) {
      transactions = transactions.sublist(0, 365);
    }
    
    await saveWalletData(wallet['balance'], transactions);
  }
  
  // ==================== CHATS ====================
  
  static Future<void> saveChats(List<Map<String, dynamic>> chats) async {
    _storage['chats'] = _encryptData(jsonEncode(chats));
  }
  
  static List<Map<String, dynamic>> getChats() {
    final data = _storage['chats'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  static Future<void> addChatMessage(String chatId, Map<String, dynamic> message) async {
    final chats = getChats();
    int chatIndex = chats.indexWhere((c) => c['id'] == chatId);
    
    if (chatIndex >= 0) {
      List messages = List.from(chats[chatIndex]['messages'] ?? []);
      messages.add({
        ...message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      chats[chatIndex]['messages'] = messages;
      chats[chatIndex]['lastMessage'] = message['message'];
      chats[chatIndex]['lastTime'] = DateTime.now().toIso8601String();
    } else {
      chats.insert(0, {
        'id': chatId,
        'messages': [message],
        'lastMessage': message['message'],
        'lastTime': DateTime.now().toIso8601String(),
        'unread': 1,
      });
    }
    
    await saveChats(chats);
  }
  
  // ==================== JOBS ====================
  
  static Future<void> saveJobs(List<Map<String, dynamic>> jobs) async {
    _storage['jobs'] = _encryptData(jsonEncode(jobs));
  }
  
  static List<Map<String, dynamic>> getJobs() {
    final data = _storage['jobs'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  static Future<void> saveMyJobs(List<Map<String, dynamic>> myJobs) async {
    _storage['myJobs'] = _encryptData(jsonEncode(myJobs));
  }
  
  static List<Map<String, dynamic>> getMyJobs() {
    final data = _storage['myJobs'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  // ==================== GAMES/CHALLENGES ====================
  
  static Future<void> saveChallenges(List<Map<String, dynamic>> challenges) async {
    _storage['challenges'] = _encryptData(jsonEncode(challenges));
  }
  
  static List<Map<String, dynamic>> getChallenges() {
    final data = _storage['challenges'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  static Future<void> saveLeagues(List<Map<String, dynamic>> leagues) async {
    _storage['leagues'] = _encryptData(jsonEncode(leagues));
  }
  
  static List<Map<String, dynamic>> getLeagues() {
    final data = _storage['leagues'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  // ==================== SACCO/CHAMA ====================
  
  static Future<void> saveSACCOS(List<Map<String, dynamic>> saccos) async {
    _storage['saccos'] = _encryptData(jsonEncode(saccos));
  }
  
  static List<Map<String, dynamic>> getSACCOS() {
    final data = _storage['saccos'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  // ==================== FUNDRAISING ====================
  
  static Future<void> saveFundraisers(List<Map<String, dynamic>> fundraisers) async {
    _storage['fundraisers'] = _encryptData(jsonEncode(fundraisers));
  }
  
  static List<Map<String, dynamic>> getFundraisers() {
    final data = _storage['fundraisers'];
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(_decryptData(data)));
  }
  
  // ==================== SETTINGS ====================
  
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    _storage['settings'] = _encryptData(jsonEncode(settings));
  }
  
  static Map<String, dynamic> getSettings() {
    final data = _storage['settings'];
    if (data == null) {
      return {
        'language': 'English',
        'currency': 'USD',
        'notifications': true,
        'biometric': false,
        'antiTheft': true,
      };
    }
    return jsonDecode(_decryptData(data));
  }
  
  // ==================== DEVICE SECURITY ====================
  
  static Future<void> saveSecurityData(Map<String, dynamic> securityData) async {
    _storage['security'] = _encryptData(jsonEncode(securityData));
  }
  
  static Map<String, dynamic> getSecurityData() {
    final data = _storage['security'];
    if (data == null) {
      return {
        'pin': '',
        'biometricEnabled': false,
        'antiTheftEnabled': true,
        'shutdownProtection': true,
        'locationTracking': true,
        'stealthMode': false,
      };
    }
    return jsonDecode(_decryptData(data));
  }
  
  // ==================== ENCRYPTION ====================
  
  static String _encryptData(String data) {
    // Simple XOR encryption for demo - in production use proper encryption
    final random = Random();
    final key = random.nextInt(256);
    final encrypted = data.codeUnits.map((c) => c ^ key).toList();
    encrypted.insert(0, key);
    return base64Encode(encrypted);
  }
  
  static String _decryptData(String encryptedData) {
    try {
      final bytes = base64Decode(encryptedData);
      final key = bytes[0];
      final decrypted = bytes.sublist(1).map((c) => c ^ key).toList();
      return String.fromCharCodes(decrypted);
    } catch (e) {
      return '{}';
    }
  }
  
  // ==================== CLEAR DATA ====================
  
  static Future<void> clearAllData() async {
    _storage.clear();
  }
  
  static Future<void> clearTransactionLogs() async {
    final wallet = getWalletData();
    wallet['transactions'] = [];
    await saveWalletData(wallet['balance'], []);
  }
}