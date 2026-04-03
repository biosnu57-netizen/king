// PINC Network - Core Cryptography Utilities
// Encryption, Hashing, Key Generation for secure transactions

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Core Cryptography Service for PINC Network
class CryptoService {
  /// Generate SHA-256 hash of data
  static String sha256(String data) {
    // Simplified hash - in production use crypto package
    int hash = 0;
    for (int i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash + data.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(64, '0');
  }

  /// Generate AES-256 encryption key
  static Uint8List generateAESKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }

  /// Generate ECDSA key pair (simplified)
  static Map<String, String> generateKeyPair() {
    final random = Random.secure();
    // Simplified - real implementation uses point multiplication
    final privateKey = List.generate(32, (_) => random.nextInt(256));
    final publicKey = List.generate(64, (_) => random.nextInt(256));
    
    return {
      'privateKey': base64Encode(privateKey),
      'publicKey': base64Encode(publicKey),
      'address': _deriveAddress(base64Encode(publicKey)),
    };
  }

  /// Derive address from public key
  static String _deriveAddress(String publicKey) {
    final hash = sha256(publicKey);
    return 'PINC${hash.substring(0, 32).toUpperCase()}';
  }

  /// Encrypt data with AES (simplified XOR for demo)
  static String encrypt(String data, String key) {
    final keyBytes = key.codeUnits;
    final dataBytes = data.codeUnits;
    final encrypted = Uint8List(dataBytes.length);
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return base64Encode(encrypted);
  }

  /// Decrypt data with AES
  static String decrypt(String encryptedData, String key) {
    return encrypt(encryptedData, key); // XOR is symmetric
  }

  /// Generate PINC address
  static String generatePINCAddress() {
    final random = Random.secure();
    final bytes = List.generate(20, (_) => random.nextInt(256));
    return 'PINC${base64Encode(bytes).substring(0, 24).toUpperCase()}';
  }

  /// Verify transaction signature
  static bool verifySignature(String message, String signature, String publicKey) {
    // Simplified - real implementation uses ECDSA verification
    final expectedSig = sha256(message + publicKey);
    return signature == expectedSig;
  }

  /// Create transaction hash
  static String createTransactionHash({
    required String from,
    required String to,
    required int amount,
    required int timestamp,
    required String data,
  }) {
    final txData = '$from$to$amount$timestamp$data';
    return sha256(txData);
  }

  /// Generate random challenge for verification
  static String generateChallenge() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(10)).join();
  }

  /// Verify phone number format
  static bool verifyPhoneNumber(String phone) {
    // Remove all non-digits
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Encrypt for storage
  static String encryptForStorage(String data, String deviceId) {
    final key = sha256(deviceId).substring(0, 32);
    return encrypt(data, key);
  }

  /// Decrypt from storage
  static String decryptFromStorage(String encryptedData, String deviceId) {
    final key = sha256(deviceId).substring(0, 32);
    return decrypt(encryptedData, key);
  }
}

/// Block for blockchain
class Block {
  final int index;
  final String previousHash;
  final String timestamp;
  final String data;
  final String hash;
  final String merkleRoot;

  Block({
    required this.index,
    required this.previousHash,
    required this.timestamp,
    required this.data,
    required this.hash,
    required this.merkleRoot,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'previousHash': previousHash,
    'timestamp': timestamp,
    'data': data,
    'hash': hash,
    'merkleRoot': merkleRoot,
  };
}

/// PINC Transaction
class Transaction {
  final String from;
  final String to;
  final int amount;
  final int timestamp;
  final String hash;
  final String signature;
  final int type; // 1=Subscription, 2=Wager, 3=Savings, 4=Service, 5=PapaBiz

  Transaction({
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
    required this.hash,
    required this.signature,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'amount': amount,
    'timestamp': timestamp,
    'hash': hash,
    'signature': signature,
    'type': type,
  };
}

/// P2P Node Information
class P2PNode {
  final String id;
  final String address;
  final int port;
  final String publicKey;
  final int bandwidth;
  final int uptime;
  final String country;
  final bool isVerified;

  P2PNode({
    required this.id,
    required this.address,
    required this.port,
    required this.publicKey,
    required this.bandwidth,
    required this.uptime,
    required this.country,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'port': port,
    'publicKey': publicKey,
    'bandwidth': bandwidth,
    'uptime': uptime,
    'country': country,
    'isVerified': isVerified,
  };
}

/// Storage Speed Rankings
class StorageSpeedRankings {
  final int readSpeed;
  final int writeSpeed;
  final int globalRank;
  final int localRank;
  final int compressionLevel;
  final String storageType;

  StorageSpeedRankings({
    required this.readSpeed,
    required this.writeSpeed,
    required this.globalRank,
    required this.localRank,
    this.compressionLevel = 9,
    this.storageType = 'Encrypted',
  });

  Map<String, dynamic> toJson() => {
    'readSpeed': readSpeed,
    'writeSpeed': writeSpeed,
    'globalRank': globalRank,
    'localRank': localRank,
    'compressionLevel': compressionLevel,
    'storageType': storageType,
  };
}

/// External Game Connection
class ExternalGame {
  final String id;
  final String name;
  final String platform;
  final bool isConnected;
  final String? lastResult;
  final DateTime? lastSync;

  ExternalGame({
    required this.id,
    required this.name,
    required this.platform,
    this.isConnected = false,
    this.lastResult,
    this.lastSync,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform,
    'isConnected': isConnected,
    'lastResult': lastResult,
    'lastSync': lastSync?.toIso8601String(),
  };
}

/// Papa Business Verification
class PapaBusiness {
  final String id;
  final String name;
  final String location;
  final bool isVerified;
  final int rating;
  final int transactionCount;

  PapaBusiness({
    required this.id,
    required this.name,
    required this.location,
    this.isVerified = false,
    this.rating = 0,
    this.transactionCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'isVerified': isVerified,
    'rating': rating,
    'transactionCount': transactionCount,
  };
}