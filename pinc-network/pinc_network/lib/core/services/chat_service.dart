// PINC Network - Chat Service
// Handles encrypted messaging, voice/video calls

import 'storage_service.dart';

class ChatService {
  List<Map<String, dynamic>> _chats = [];
  
  // ==================== GET CHATS ====================
  
  List<Map<String, dynamic>> getChats() => _chats;
  
  // ==================== INITIALIZE ====================
  
  Future<void> initialize() async {
    _chats = LocalStorageService.getChats();
  }
  
  // ==================== START NEW CHAT ====================
  
  Future<Map<String, dynamic>> startChat({
    required String myPincId,
    required String recipientPincId,
  }) async {
    // Check if chat already exists
    final existingIndex = _chats.indexWhere((c) => c['id'] == recipientPincId);
    
    if (existingIndex >= 0) {
      return {'success': true, 'chat': _chats[existingIndex], 'existing': true};
    }
    
    // Create new chat
    final newChat = {
      'id': recipientPincId,
      'name': _generateName(recipientPincId),
      'messages': [],
      'lastMessage': '',
      'lastTime': '',
      'unread': 0,
      'encrypted': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _chats.insert(0, newChat);
    await LocalStorageService.saveChats(_chats);
    
    return {'success': true, 'chat': newChat, 'existing': false};
  }
  
  // ==================== SEND MESSAGE ====================
  
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
    required String myPincId,
  }) async {
    // Encrypt message (simple demo - use proper E2E encryption in production)
    final encryptedMessage = _encryptMessage(message);
    
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex < 0) {
      return {'success': false, 'error': 'Chat not found'};
    }
    
    final msgObj = {
      'id': _generateMessageId(),
      'sender': myPincId,
      'message': encryptedMessage,
      'decryptedMessage': message,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sent',
      'type': 'text',
    };
    
    List messages = List.from(_chats[chatIndex]['messages'] ?? []);
    messages.add(msgObj);
    
    _chats[chatIndex]['messages'] = messages;
    _chats[chatIndex]['lastMessage'] = message;
    _chats[chatIndex]['lastTime'] = DateTime.now().toIso8601String();
    
    await LocalStorageService.saveChats(_chats);
    await LocalStorageService.addChatMessage(chatId, msgObj);
    
    return {'success': true, 'message': msgObj, 'chat': _chats[chatIndex]};
  }
  
  // ==================== SEND VOICE MESSAGE ====================
  
  Future<Map<String, dynamic>> sendVoiceMessage({
    required String chatId,
    required String myPincId,
    required String audioData, // Base64 encoded audio
  }) async {
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex < 0) {
      return {'success': false, 'error': 'Chat not found'};
    }
    
    final msgObj = {
      'id': _generateMessageId(),
      'sender': myPincId,
      'message': '[Voice Message]',
      'audioData': audioData,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sent',
      'type': 'voice',
    };
    
    List messages = List.from(_chats[chatIndex]['messages'] ?? []);
    messages.add(msgObj);
    
    _chats[chatIndex]['messages'] = messages;
    _chats[chatIndex]['lastMessage'] = '🎤 Voice message';
    _chats[chatIndex]['lastTime'] = DateTime.now().toIso8601String();
    
    await LocalStorageService.saveChats(_chats);
    await LocalStorageService.addChatMessage(chatId, msgObj);
    
    return {'success': true, 'message': msgObj};
  }
  
  // ==================== SEND FILE ====================
  
  Future<Map<String, dynamic>> sendFile({
    required String chatId,
    required String myPincId,
    required String fileName,
    required String fileData, // Base64 encoded
    required int fileSize, // in bytes
  }) async {
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex < 0) {
      return {'success': false, 'error': 'Chat not found'};
    }
    
    // Check file size - 10TB free, 100 PINC per 10TB overage
    // For demo, just allow up to 100MB
    if (fileSize > 100 * 1024 * 1024) {
      return {'success': false, 'error': 'File too large. Max 100MB for demo.'};
    }
    
    final msgObj = {
      'id': _generateMessageId(),
      'sender': myPincId,
      'message': '📎 $fileName',
      'fileName': fileName,
      'fileData': fileData,
      'fileSize': fileSize,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sent',
      'type': 'file',
    };
    
    List messages = List.from(_chats[chatIndex]['messages'] ?? []);
    messages.add(msgObj);
    
    _chats[chatIndex]['messages'] = messages;
    _chats[chatIndex]['lastMessage'] = '📎 $fileName';
    _chats[chatIndex]['lastTime'] = DateTime.now().toIso8601String();
    
    await LocalStorageService.saveChats(_chats);
    await LocalStorageService.addChatMessage(chatId, msgObj);
    
    return {'success': true, 'message': msgObj};
  }
  
  // ==================== GET MESSAGES FOR CHAT ====================
  
  List<Map<String, dynamic>> getMessages(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex < 0) return [];
    
    return List<Map<String, dynamic>>.from(_chats[chatIndex]['messages'] ?? []);
  }
  
  // ==================== MARK AS READ ====================
  
  Future<void> markAsRead(String chatId) async {
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex >= 0) {
      _chats[chatIndex]['unread'] = 0;
      await LocalStorageService.saveChats(_chats);
    }
  }
  
  // ==================== DELETE CHAT ====================
  
  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((c) => c['id'] == chatId);
    await LocalStorageService.saveChats(_chats);
  }
  
  // ==================== ENCRYPTION (DEMO) ====================
  
  String _encryptMessage(String message) {
    // Simple XOR encryption - use proper E2E in production
    final key = 42;
    final encrypted = message.codeUnits.map((c) => c ^ key).toList();
    return String.fromCharCodes(encrypted);
  }
  
  String _decryptMessage(String encrypted) {
    final key = 42;
    final decrypted = encrypted.codeUnits.map((c) => c ^ key).toList();
    return String.fromCharCodes(decrypted);
  }
  
  // ==================== CALL FUNCTIONALITY ====================
  
  Future<Map<String, dynamic>> initiateCall({
    required String chatId,
    required String callType, // 'voice', 'video', 'screen'
    required String myPincId,
  }) async {
    // Return call session info
    final callSession = {
      'id': _generateMessageId(),
      'type': callType,
      'from': myPincId,
      'chatId': chatId,
      'status': 'initiating',
      'startTime': DateTime.now().toIso8601String(),
    };
    
    return {
      'success': true,
      'session': callSession,
      'message': callType == 'voice' ? 'Initiating voice call...' : 
                 callType == 'video' ? 'Initiating video call...' : 
                 'Initiating screen share...',
    };
  }
  
  // ==================== HELPERS ====================
  
  String _generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond % 10000;
    return 'MSG-$timestamp-$random';
  }
  
  String _generateName(String pincId) {
    // Generate a name from PINC ID
    return 'User-${pincId.substring(5, 9)}';
  }
  
  // ==================== GET UNREAD COUNT ====================
  
  int getTotalUnreadCount() {
    return _chats.fold(0, (sum, chat) => sum + ((chat['unread'] ?? 0) as int));
  }
  
  // ==================== SEARCH CHATS ====================
  
  List<Map<String, dynamic>> searchChats(String query) {
    if (query.isEmpty) return _chats;
    
    return _chats.where((chat) {
      final name = (chat['name'] ?? '').toLowerCase();
      final lastMsg = (chat['lastMessage'] ?? '').toLowerCase();
      final id = (chat['id'] ?? '').toLowerCase();
      
      return name.contains(query.toLowerCase()) ||
             lastMsg.contains(query.toLowerCase()) ||
             id.contains(query.toLowerCase());
    }).toList();
  }
}