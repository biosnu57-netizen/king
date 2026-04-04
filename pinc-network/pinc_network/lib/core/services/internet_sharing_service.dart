// PINC Network - Internet Sharing Service
// Handles P2P mesh VPN, internet selling, and network sharing

import 'fee_service.dart';
import 'storage_service.dart';

class InternetSharingService {
  bool _isConnected = false;
  bool _isSeller = false;
  double _mySpeedMbps = 0.0;
  int _connectedUsers = 0;
  List<Map<String, dynamic>> _recentSessions = [];
  
  // ==================== GET STATUS ====================
  
  bool get isConnected => _isConnected;
  bool get isSeller => _isSeller;
  double get mySpeedMbps => _mySpeedMbps;
  int get connectedUsers => _connectedUsers;
  
  // ==================== BECOME SELLER ====================
  
  Future<Map<String, dynamic>> becomeSeller({
    required double speedMbps,
    required double monthlyPrice, // User's chosen price
    required bool isPremium,
  }) async {
    // Validate speed
    if (speedMbps < 1.0) {
      return {'success': false, 'error': 'Minimum speed must be at least 1 Mbps'};
    }
    
    // Calculate platform fee
    double platformFee;
    int maxUsers;
    
    if (isPremium) {
      platformFee = FeeService.getPremiumSharingFee();
      maxUsers = 10;
    } else {
      platformFee = FeeService.getInternetSellerFee();
      maxUsers = FeeService.calculateMaxUsers(speedMbps);
    }
    
    _isSeller = true;
    _mySpeedMbps = speedMbps;
    
    // Save seller profile
    final sellerProfile = {
      'speedMbps': speedMbps,
      'monthlyPrice': monthlyPrice,
      'isPremium': isPremium,
      'maxUsers': maxUsers,
      'currentUsers': 0,
      'platformFee': platformFee,
      'uptimePercent': 100.0,
      'speedPercent': 100.0,
      'totalEarnings': 0.0,
      'totalSessions': 0,
      'violations': 0,
      'status': 'active',
      'startedAt': DateTime.now().toIso8601String(),
    };
    
    await LocalStorageService.saveSettings({'sellerProfile': sellerProfile});
    
    return {
      'success': true,
      'profile': sellerProfile,
      'feeDetails': {
        'platformFee': platformFee,
        'maxUsers': maxUsers,
        'speedPerUser': FeeService.getSpeedPerPersonMbps(),
      },
    };
  }
  
  // ==================== SET SPEED (Simulated speed test) ====================
  
  Future<Map<String, dynamic>> runSpeedTest() async {
    // Simulate speed test - in real app would measure actual bandwidth
    _mySpeedMbps = (10 + (DateTime.now().millisecond % 90)).toDouble(); // Random 10-100 Mbps
    
    int maxUsers = FeeService.calculateMaxUsers(_mySpeedMbps);
    
    return {
      'success': true,
      'speedMbps': _mySpeedMbps,
      'maxUsers': maxUsers,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  // ==================== CONNECT TO NETWORK ====================
  
  Future<Map<String, dynamic>> connectToNetwork({
    required String myPincId,
  }) async {
    if (_isConnected) {
      return {'success': false, 'error': 'Already connected'};
    }
    
    // Simulate finding nodes
    final nodes = _generateAvailableNodes();
    
    _isConnected = true;
    
    return {
      'success': true,
      'connectedNodes': nodes.length,
      'yourIp': '10.${DateTime.now().second}.${DateTime.now().millisecond % 255}.1',
      'encrypted': true,
      'ipPreserved': true,
    };
  }
  
  // ==================== CONNECT TO SELLER ====================
  
  Future<Map<String, dynamic>> connectToSeller({
    required String sellerId,
    required double requiredSpeed,
    required int duration, // hours
  }) async {
    // Simulate finding sellers
    final sellers = _findSellers(requiredSpeed);
    
    if (sellers.isEmpty) {
      return {'success': false, 'error': 'No sellers available with required speed'};
    }
    
    final seller = sellers.first;
    
    // Calculate cost
    double hourlyRate = seller['hourlyRate'] ?? (seller['monthlyPrice'] / 720); // Approximate
    double totalCost = hourlyRate * duration;
    
    // Create escrow session
    final session = {
      'id': _generateSessionId(),
      'sellerId': sellerId,
      'sellerSpeed': seller['speedMbps'],
      'requestedSpeed': requiredSpeed,
      'duration': duration,
      'totalCost': totalCost,
      'status': 'active',
      'startTime': DateTime.now().toIso8601String(),
      'uptimePercent': 0,
      'speedPercent': 0,
      'userConfirmed': false,
    };
    
    _recentSessions.insert(0, session);
    
    return {
      'success': true,
      'session': session,
      'sellerInfo': seller,
    };
  }
  
  // ==================== CONFIRM SESSION (After 87% completion) ====================
  
  Future<Map<String, dynamic>> confirmSession({
    required String sessionId,
    required bool satisfied,
    required double uptimePercent,
    required double speedPercent,
  }) async {
    final sessionIndex = _recentSessions.indexWhere((s) => s['id'] == sessionId);
    if (sessionIndex < 0) {
      return {'success': false, 'error': 'Session not found'};
    }
    
    Map<String, dynamic> session = _recentSessions[sessionIndex];
    
    // Check if meets SLA (87%)
    bool meetsSLA = uptimePercent >= FeeService.getSLAThreshold() && 
                   speedPercent >= FeeService.getSLAThreshold();
    
    session['userConfirmed'] = true;
    session['uptimePercent'] = uptimePercent;
    session['speedPercent'] = speedPercent;
    session['satisfied'] = satisfied;
    session['completedAt'] = DateTime.now().toIso8601String();
    
    if (satisfied && meetsSLA) {
      session['status'] = 'completed_paid';
      
      // Seller gets paid
      return {
        'success': true,
        'session': session,
        'result': 'paid',
        'earnings': session['totalCost'],
      };
    } else if (!satisfied) {
      session['status'] = 'disputed';
      return {
        'success': true,
        'session': session,
        'result': 'dispute',
        'refundAmount': session['totalCost'],
      };
    } else {
      // SLA not met - partial payment
      double refundPercent = 1 - ((uptimePercent + speedPercent) / 2);
      double refund = session['totalCost'] * refundPercent;
      
      session['status'] = 'partial_payment';
      session['refundPercent'] = refundPercent * 100;
      
      return {
        'success': true,
        'session': session,
        'result': 'partial',
        'earnings': session['totalCost'] - refund,
        'refund': refund,
      };
    }
  }
  
  // ==================== DISCONNECT ====================
  
  Future<void> disconnect() async {
    _isConnected = false;
    _connectedUsers = 0;
  }
  
  // ==================== SELLER STATS ====================
  
  Map<String, dynamic> getSellerStats() {
    return {
      'isSeller': _isSeller,
      'currentSpeed': _mySpeedMbps,
      'maxUsers': _isSeller ? FeeService.calculateMaxUsers(_mySpeedMbps) : 0,
      'connectedUsers': _connectedUsers,
      'recentSessions': _recentSessions.take(10).toList(),
    };
  }
  
  // ==================== FIND AVAILABLE SELLERS ====================
  
  List<Map<String, dynamic>> findSellers({
    double? minSpeed,
    double? maxPrice,
  }) {
    // In real app, this would query P2P network
    return _findSellers(minSpeed ?? 1.0).where((s) {
      if (maxPrice != null && (s['monthlyPrice'] ?? 0) > maxPrice) return false;
      return true;
    }).toList();
  }
  
  // ==================== PRIVATE HELPERS ====================
  
  List<Map<String, dynamic>> _findSellers(double minSpeed) {
    // Demo sellers
    return [
      {
        'id': 'PINC-KE-001',
        'country': 'Kenya',
        'speedMbps': 50.0,
        'monthlyPrice': 200.0,
        'hourlyRate': 5.0,
        'currentUsers': 12,
        'maxUsers': 50,
        'uptimePercent': 95.0,
        'rating': 4.5,
      },
      {
        'id': 'PINC-DE-002',
        'country': 'Germany',
        'speedMbps': 100.0,
        'monthlyPrice': 350.0,
        'hourlyRate': 10.0,
        'currentUsers': 5,
        'maxUsers': 100,
        'uptimePercent': 99.0,
        'rating': 4.8,
      },
      {
        'id': 'PINC-US-003',
        'country': 'USA',
        'speedMbps': 75.0,
        'monthlyPrice': 280.0,
        'hourlyRate': 7.0,
        'currentUsers': 20,
        'maxUsers': 75,
        'uptimePercent': 92.0,
        'rating': 4.2,
      },
    ].where((s) => (s['speedMbps'] as double) >= minSpeed).toList();
  }
  
  List<Map<String, dynamic>> _generateAvailableNodes() {
    // Generate random nodes for mesh network
    return List.generate(50, (i) => {
      'id': 'NODE-$i',
      'country': ['Kenya', 'Germany', 'USA', 'Japan', 'UK'][i % 5],
      'speedMbps': (10 + (i * 5)).toDouble(),
      'latency': 20 + (i * 2),
    });
  }
  
  String _generateSessionId() => 'SES-${DateTime.now().millisecondsSinceEpoch}';
}