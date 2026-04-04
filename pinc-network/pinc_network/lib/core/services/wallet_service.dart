// PINC Network - Wallet Service
// Handles wallet operations, transactions, and balance

import 'fee_service.dart';
import 'storage_service.dart';

class WalletService {
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  
  // ==================== GET BALANCE ====================
  
  double getBalance() => _balance;
  
  List<Map<String, dynamic>> getTransactions() => _transactions;
  
  // ==================== INITIALIZE ====================
  
  Future<void> initialize() async {
    final data = LocalStorageService.getWalletData();
    _balance = (data['balance'] ?? 0.0) as double;
    _transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
  }
  
  // ==================== SEND PINC ====================
  
  Future<Map<String, dynamic>> sendPINC({
    required String toPincId,
    required double amount,
    required int transferType,
  }) async {
    // Validate amount
    if (amount <= 0) {
      return {'success': false, 'error': 'Invalid amount'};
    }
    
    if (amount > _balance) {
      return {'success': false, 'error': 'Insufficient balance'};
    }
    
    if (amount > FeeService.getMaxTransfer()) {
      return {'success': false, 'error': 'Amount exceeds maximum transfer limit'};
    }
    
    // Internal P2P transfer is FREE
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'send',
      'to': toPincId,
      'amount': amount,
      'transferType': FeeService.transferTypes[transferType] ?? 'Unknown',
      'fee': 0.0, // Free internal transfer
      'status': 'completed',
    };
    
    _balance -= amount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
    };
  }
  
  // ==================== WITHDRAW PINC ====================
  
  Future<Map<String, dynamic>> withdrawPINC({
    required double amount,
    required String method,
  }) async {
    // Validate amount
    if (amount < FeeService.getMinWithdrawal()) {
      return {'success': false, 'error': 'Minimum withdrawal is ${FeeService.getMinWithdrawal()} PINC'};
    }
    
    if (amount > _balance) {
      return {'success': false, 'error': 'Insufficient balance'};
    }
    
    // Calculate fee
    double fee = FeeService.getWithdrawalFee(amount);
    double netAmount = amount - fee;
    
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'withdraw',
      'method': method,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'status': 'pending',
    };
    
    _balance -= amount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
      'feeBreakdown': FeeService.getWithdrawalBreakdown(amount),
    };
  }
  
  // ==================== RECEIVE PINC ====================
  
  Future<Map<String, dynamic>> receivePINC({
    required String fromPincId,
    required double amount,
    required int transferType,
  }) async {
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'receive',
      'from': fromPincId,
      'amount': amount,
      'transferType': FeeService.transferTypes[transferType] ?? 'Unknown',
      'fee': 0.0,
      'status': 'completed',
    };
    
    _balance += amount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
    };
  }
  
  // ==================== DEPOSIT ====================
  
  Future<Map<String, dynamic>> depositPINC({
    required double amount,
    required String method,
  }) async {
    // Deposits are free
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'deposit',
      'method': method,
      'amount': amount,
      'fee': 0.0,
      'status': 'completed',
    };
    
    _balance += amount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
    };
  }
  
  // ==================== JOB PAYMENTS ====================
  
  Future<Map<String, dynamic>> payForJob({
    required double jobValue,
  }) async {
    double fee = jobValue * FeeService.getCreateJobFee();
    double total = jobValue + fee;
    
    if (total > _balance) {
      return {'success': false, 'error': 'Insufficient balance for job + fees'};
    }
    
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'job_payment',
      'jobValue': jobValue,
      'fee': fee,
      'total': total,
      'status': 'escrow',
    };
    
    _balance -= total;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
      'feeDetails': {'jobValue': jobValue, 'fee': fee, 'total': total},
    };
  }
  
  Future<Map<String, dynamic>> receiveJobPayment({
    required double amount,
  }) async {
    double fee = amount * FeeService.getReceivePaymentFee();
    double netAmount = amount - fee;
    
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'job_receive',
      'grossAmount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'status': 'completed',
    };
    
    _balance += netAmount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
      'feeDetails': {'gross': amount, 'fee': fee, 'net': netAmount},
    };
  }
  
  // ==================== BETTING ====================
  
  Future<Map<String, dynamic>> placeBet({
    required double amount,
    required bool isDeveloperBet,
    double? creatorFee,
  }) async {
    if (amount < FeeService.getMinWager()) {
      return {'success': false, 'error': 'Minimum wager is ${FeeService.getMinWager()} PINC'};
    }
    
    if (amount > _balance) {
      return {'success': false, 'error': 'Insufficient balance'};
    }
    
    Map<String, dynamic> fees;
    if (isDeveloperBet) {
      fees = FeeService.calculateDeveloperBetFees(amount);
    } else {
      fees = FeeService.calculateP2PBetFees(amount, creatorFee ?? 0);
    }
    
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'bet',
      'amount': amount,
      'betType': isDeveloperBet ? 'developer' : 'p2p',
      'fees': fees,
      'status': 'escrow',
    };
    
    _balance -= amount;
    _transactions.insert(0, transaction);
    
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
      'feeBreakdown': fees,
    };
  }
  
  Future<Map<String, dynamic>> settleBet({
    required String transactionId,
    required bool won,
    required double winnings,
  }) async {
    if (won) {
      _balance += winnings;
      
      final idx = _transactions.indexWhere((t) => t['id'] == transactionId);
      if (idx >= 0) {
        _transactions[idx]['status'] = 'settled';
        _transactions[idx]['winnings'] = winnings;
      }
      
      await LocalStorageService.saveWalletData(_balance, _transactions);
    }
    
    return {'success': true, 'newBalance': _balance};
  }
  
  // ==================== FUNDRAISING ====================
  
  Future<Map<String, dynamic>> createFundraiser({
    required double goalAmount,
    required String title,
    bool lockPeriod = false,
  }) async {
    // Platform takes 9% of total raised
    // This is collected when fundraiser completes
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'fundraiser_created',
      'title': title,
      'goalAmount': goalAmount,
      'platformFeePercent': FeeService.getFundraisingFee() * 100,
      'lockPeriod': lockPeriod,
      'status': 'active',
    };
    
    // No upfront cost to create fundraiser
    _transactions.insert(0, transaction);
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {'success': true, 'transaction': transaction};
  }
  
  Future<Map<String, dynamic>> contributeToFundraiser({
    required String fundraiserId,
    required double amount,
  }) async {
    if (amount > _balance) {
      return {'success': false, 'error': 'Insufficient balance'};
    }
    
    double fee = amount * FeeService.getFundraisingFee();
    double netContribution = amount - fee;
    
    _balance -= amount;
    
    final transaction = {
      'id': _generateTransactionId(),
      'type': 'fundraiser_contribute',
      'fundraiserId': fundraiserId,
      'grossAmount': amount,
      'fee': fee,
      'netAmount': netContribution,
      'status': 'completed',
    };
    
    _transactions.insert(0, transaction);
    await LocalStorageService.saveWalletData(_balance, _transactions);
    await LocalStorageService.addTransaction(transaction);
    
    return {
      'success': true,
      'transaction': transaction,
      'newBalance': _balance,
      'feeDetails': {'gross': amount, 'fee': fee, 'net': netContribution},
    };
  }
  
  // ==================== HELPERS ====================
  
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond % 10000;
    return 'TX-$timestamp-$random';
  }
  
  // ==================== GET TRANSACTION SUMMARY ====================
  
  Map<String, dynamic> getTransactionSummary() {
    return {
      'balance': _balance,
      'transactionCount': _transactions.length,
      'totalSent': _transactions.where((t) => t['type'] == 'send').fold(0.0, (sum, t) => sum + (t['amount'] ?? 0)),
      'totalReceived': _transactions.where((t) => t['type'] == 'receive').fold(0.0, (sum, t) => sum + (t['amount'] ?? 0)),
      'totalWithdrawn': _transactions.where((t) => t['type'] == 'withdraw').fold(0.0, (sum, t) => sum + (t['amount'] ?? 0)),
      'totalDeposited': _transactions.where((t) => t['type'] == 'deposit').fold(0.0, (sum, t) => sum + (t['amount'] ?? 0)),
      'totalWagered': _transactions.where((t) => t['type'] == 'bet').fold(0.0, (sum, t) => sum + (t['amount'] ?? 0)),
      'totalFeesPaid': _transactions.fold(0.0, (sum, t) => sum + (t['fee'] ?? 0)),
    };
  }
}