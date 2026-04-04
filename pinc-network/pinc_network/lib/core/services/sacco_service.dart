// PINC Network - SACCO/Chama Service
// Handles group savings with multi-signature withdrawal

import 'fee_service.dart';
import 'storage_service.dart';

class SACCOService {
  List<Map<String, dynamic>> _saccos = [];
  
  // ==================== GET SACCOS ====================
  
  List<Map<String, dynamic>> getSACCOS() => _saccos;
  
  // ==================== INITIALIZE ====================
  
  Future<void> initialize() async {
    _saccos = LocalStorageService.getSACCOS();
  }
  
  // ==================== CREATE SACCO ====================
  
  Future<Map<String, dynamic>> createSACCO({
    required String name,
    required String myPincId,
    required double minContribution,
    required bool lockPeriodEnabled,
    int? lockDays,
  }) async {
    final sacco = {
      'id': _generateSACCOId(),
      'name': name,
      'creator': myPincId,
      'minContribution': minContribution,
      'lockPeriodEnabled': lockPeriodEnabled,
      'lockDays': lockDays,
      'balance': 0.0,
      'members': [
        {
          'pincId': myPincId,
          'role': 'chairman',
          'joinedAt': DateTime.now().toIso8601String(),
          'contribution': 0.0,
        }
      ],
      'transactions': [],
      'pendingWithdrawals': [],
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _saccos.insert(0, sacco);
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {'success': true, 'sacco': sacco};
  }
  
  // ==================== JOIN SACCO ====================
  
  Future<Map<String, dynamic>> joinSACCO({
    required String saccoId,
    required String pincId,
    required String role, // 'secretary', 'treasurer', 'member'
  }) async {
    final saccoIndex = _saccos.indexWhere((s) => s['id'] == saccoId);
    if (saccoIndex < 0) {
      return {'success': false, 'error': 'SACCO not found'};
    }
    
    // Check if already member
    List members = List.from(_saccos[saccoIndex]['members'] ?? []);
    final existing = members.where((m) => m['pincId'] == pincId).firstOrNull;
    if (existing != null) {
      return {'success': false, 'error': 'Already a member'};
    }
    
    // Validate role availability
    if (role == 'chairman') {
      final hasChairman = members.any((m) => m['role'] == 'chairman');
      if (hasChairman) {
        return {'success': false, 'error': 'Chairman already exists'};
      }
    }
    if (role == 'secretary') {
      final hasSecretary = members.any((m) => m['role'] == 'secretary');
      if (hasSecretary) {
        return {'success': false, 'error': 'Secretary already exists'};
      }
    }
    if (role == 'treasurer') {
      final hasTreasurer = members.any((m) => m['role'] == 'treasurer');
      if (hasTreasurer) {
        return {'success': false, 'error': 'Treasurer already exists'};
      }
    }
    
    members.add({
      'pincId': pincId,
      'role': role,
      'joinedAt': DateTime.now().toIso8601String(),
      'contribution': 0.0,
    });
    
    _saccos[saccoIndex]['members'] = members;
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {'success': true, 'sacco': _saccos[saccoIndex]};
  }
  
  // ==================== CONTRIBUTE ====================
  
  Future<Map<String, dynamic>> contribute({
    required String saccoId,
    required String pincId,
    required double amount,
  }) async {
    final saccoIndex = _saccos.indexWhere((s) => s['id'] == saccoId);
    if (saccoIndex < 0) {
      return {'success': false, 'error': 'SACCO not found'};
    }
    
    Map<String, dynamic> sacco = _saccos[saccoIndex];
    
    // Check minimum contribution
    if (amount < (sacco['minContribution'] ?? 0)) {
      return {'success': false, 'error': 'Minimum contribution is ${sacco['minContribution']} PINC'};
    }
    
    // Check lock period
    if (sacco['lockPeriodEnabled'] == true && sacco['lockDays'] != null) {
      // Check if recently joined
      List members = List.from(sacco['members'] ?? []);
      final memberIndex = members.indexWhere((m) => m['pincId'] == pincId);
      if (memberIndex >= 0) {
        final joinedAt = DateTime.parse(members[memberIndex]['joinedAt']);
        final daysSinceJoin = DateTime.now().difference(joinedAt).inDays;
        if (daysSinceJoin < sacco['lockDays']) {
          return {
            'success': false,
            'error': 'Lock period active. ${sacco['lockDays'] - daysSinceJoin} days remaining.',
          };
        }
      }
    }
    
    // Update member contribution
    List members = List.from(sacco['members'] ?? []);
    int memberIndex = members.indexWhere((m) => m['pincId'] == pincId);
    if (memberIndex >= 0) {
      double currentContrib = members[memberIndex]['contribution'] ?? 0.0;
      members[memberIndex]['contribution'] = currentContrib + amount;
    }
    
    // Update sacco balance
    double newBalance = (sacco['balance'] ?? 0.0) + amount;
    
    // Record transaction
    List transactions = List.from(sacco['transactions'] ?? []);
    transactions.insert(0, {
      'id': _generateTransactionId(),
      'type': 'contribution',
      'pincId': pincId,
      'amount': amount,
      'balance': newBalance,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _saccos[saccoIndex] = {
      ...sacco,
      'balance': newBalance,
      'members': members,
      'transactions': transactions,
    };
    
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {
      'success': true,
      'newBalance': newBalance,
      'transaction': transactions[0],
    };
  }
  
  // ==================== REQUEST WITHDRAWAL (Multi-Sig) ====================
  
  Future<Map<String, dynamic>> requestWithdrawal({
    required String saccoId,
    required String requesterPincId,
    required double amount,
    required String reason,
  }) async {
    final saccoIndex = _saccos.indexWhere((s) => s['id'] == saccoId);
    if (saccoIndex < 0) {
      return {'success': false, 'error': 'SACCO not found'};
    }
    
    Map<String, dynamic> sacco = _saccos[saccoIndex];
    
    if ((sacco['balance'] ?? 0.0) < amount) {
      return {'success': false, 'error': 'Insufficient balance'};
    }
    
    // Create withdrawal request
    final withdrawal = {
      'id': _generateWithdrawalId(),
      'requester': requesterPincId,
      'amount': amount,
      'reason': reason,
      'approvals': [
        {'pincId': requesterPincId, 'approved': true, 'timestamp': DateTime.now().toIso8601String()}
      ],
      'requiredApprovals': _getRequiredApprovals(sacco),
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    List pending = List.from(sacco['pendingWithdrawals'] ?? []);
    pending.add(withdrawal);
    
    _saccos[saccoIndex]['pendingWithdrawals'] = pending;
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {
      'success': true,
      'withdrawal': withdrawal,
      'requiredApprovals': withdrawal['requiredApprovals'],
      'currentApprovals': 1,
    };
  }
  
  // ==================== APPROVE WITHDRAWAL ====================
  
  Future<Map<String, dynamic>> approveWithdrawal({
    required String saccoId,
    required String withdrawalId,
    required String approverPincId,
  }) async {
    final saccoIndex = _saccos.indexWhere((s) => s['id'] == saccoId);
    if (saccoIndex < 0) {
      return {'success': false, 'error': 'SACCO not found'};
    }
    
    Map<String, dynamic> sacco = _saccos[saccoIndex];
    List pending = List.from(sacco['pendingWithdrawals'] ?? []);
    int wdIndex = pending.indexWhere((w) => w['id'] == withdrawalId);
    
    if (wdIndex < 0) {
      return {'success': false, 'error': 'Withdrawal not found'};
    }
    
    // Check if approver is authorized (Chairman, Secretary, or Treasurer)
    List members = List.from(sacco['members'] ?? []);
    final member = members.where((m) => m['pincId'] == approverPincId).firstOrNull;
    if (member == null) {
      return {'success': false, 'error': 'Not a member'};
    }
    
    String role = member['role'] ?? 'member';
    if (role != 'chairman' && role != 'secretary' && role != 'treasurer') {
      return {'success': false, 'error': 'Only Chairman, Secretary, or Treasurer can approve'};
    }
    
    // Check if already approved
    List approvals = List.from(pending[wdIndex]['approvals'] ?? []);
    final alreadyApproved = approvals.any((a) => a['pincId'] == approverPincId);
    if (alreadyApproved) {
      return {'success': false, 'error': 'Already approved'};
    }
    
    // Add approval
    approvals.add({
      'pincId': approverPincId,
      'approved': true,
      'role': role,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    pending[wdIndex]['approvals'] = approvals;
    
    // Check if enough approvals
    int required = pending[wdIndex]['requiredApprovals'];
    if (approvals.length >= required) {
      // Execute withdrawal
      pending[wdIndex]['status'] = 'approved';
      pending[wdIndex]['executedAt'] = DateTime.now().toIso8601String();
      
      // Deduct from balance
      double newBalance = (sacco['balance'] ?? 0.0) - pending[wdIndex]['amount'];
      _saccos[saccoIndex]['balance'] = newBalance;
      
      // Add to transactions
      List transactions = List.from(sacco['transactions'] ?? []);
      transactions.insert(0, {
        'id': _generateTransactionId(),
        'type': 'withdrawal',
        'withdrawalId': withdrawalId,
        'amount': pending[wdIndex]['amount'],
        'reason': pending[wdIndex]['reason'],
        'balance': newBalance,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _saccos[saccoIndex]['transactions'] = transactions;
    }
    
    _saccos[saccoIndex]['pendingWithdrawals'] = pending;
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {
      'success': true,
      'withdrawal': pending[wdIndex],
      'approvalsCount': approvals.length,
      'required': required,
    };
  }
  
  // ==================== REJECT WITHDRAWAL ====================
  
  Future<Map<String, dynamic>> rejectWithdrawal({
    required String saccoId,
    required String withdrawalId,
    required String rejectorPincId,
    required String reason,
  }) async {
    final saccoIndex = _saccos.indexWhere((s) => s['id'] == saccoId);
    if (saccoIndex < 0) {
      return {'success': false, 'error': 'SACCO not found'};
    }
    
    Map<String, dynamic> sacco = _saccos[saccoIndex];
    List pending = List.from(sacco['pendingWithdrawals'] ?? []);
    int wdIndex = pending.indexWhere((w) => w['id'] == withdrawalId);
    
    if (wdIndex < 0) {
      return {'success': false, 'error': 'Withdrawal not found'};
    }
    
    pending[wdIndex]['status'] = 'rejected';
    pending[wdIndex]['rejectedBy'] = rejectorPincId;
    pending[wdIndex]['rejectionReason'] = reason;
    pending[wdIndex]['rejectedAt'] = DateTime.now().toIso8601String();
    
    _saccos[saccoIndex]['pendingWithdrawals'] = pending;
    await LocalStorageService.saveSACCOS(_saccos);
    
    return {'success': true, 'withdrawal': pending[wdIndex]};
  }
  
  // ==================== GET SACCO DETAILS ====================
  
  Map<String, dynamic>? getSACCODetails(String saccoId) {
    final index = _saccos.indexWhere((s) => s['id'] == saccoId);
    return index >= 0 ? _saccos[index] : null;
  }
  
  List<Map<String, dynamic>> getMySACCOS(String pincId) {
    return _saccos.where((s) {
      List members = List.from(s['members'] ?? []);
      return members.any((m) => m['pincId'] == pincId);
    }).toList();
  }
  
  // ==================== HELPERS ====================
  
  int _getRequiredApprovals(Map<String, dynamic> sacco) {
    List members = List.from(sacco['members'] ?? []);
    
    // Get key roles
    bool hasChairman = members.any((m) => m['role'] == 'chairman');
    bool hasSecretary = members.any((m) => m['role'] == 'secretary');
    bool hasTreasurer = members.any((m) => m['role'] == 'treasurer');
    
    int keyRoles = 0;
    if (hasChairman) keyRoles++;
    if (hasSecretary) keyRoles++;
    if (hasTreasurer) keyRoles++;
    
    // Need at least 2 of 3 key roles, or all available
    if (keyRoles >= 2) return 2;
    return keyRoles;
  }
  
  String _generateSACCOId() => 'SACCO-${DateTime.now().millisecondsSinceEpoch}';
  String _generateTransactionId() => 'SACTX-${DateTime.now().millisecondsSinceEpoch}';
  String _generateWithdrawalId() => 'SAW-${DateTime.now().millisecondsSinceEpoch}';
}