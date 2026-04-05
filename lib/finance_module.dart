// PINC Network - Finance Module
// AI #4: Finance Engineer
// Wallet, escrow, fees, deposits, withdrawals

/// ==================== FEE SERVICE (EXACT AS SPECIFIED) ====================
class FeeService {
  // ============ INTERNET SELLING ============
  /// Seller subscription to sell internet: 435 PINC/month
  static const int internetSellerSubscription = 435;
  
  /// Premium sharing: 325 PINC/month (up to 10 users)
  static const int premiumSharing = 325;
  
  /// Free tier max users
  static const int freeTierLimit = 3;
  
  /// Min speed in Mbps
  static const double minSpeedMbps = 1.0;
  
  /// SLA threshold (87% uptime/speed required)
  static const double slaThreshold = 0.87;
  
  /// Delist threshold (below 76% after 3 times = reapply)
  static const double delistThreshold = 0.76;

  // ============ BETTING ============
  /// P2P bet: 7% of winner
  static double p2pBetFee(double winnerAmount) => winnerAmount * 0.07;
  
  /// Developer bet: 13% of total stakes
  static double developerBetFee(double totalStakes) => totalStakes * 0.13;
  
  /// Creator can take up to 5% of winner
  static const double maxCreatorFee = 0.05;
  
  /// Min wager: 20 PINC
  static const int minWager = 20;

  // ============ PLATFORM ============
  /// Basic subscription: 325 PINC/month
  static const int basicSubscription = 325;
  
  /// Unlimited job bids add-on: 300 PINC/month
  static const int unlimitedJobsAddOn = 300;
  
  /// Global challenge (one-time): 1560 PINC
  static const int globalChallenge = 1560;
  
  /// API access (premium): 1000 PINC/month
  static const int apiAccess = 1000;

  // ============ JOBS ============
  /// Job create fee: 3% of job value
  static double jobCreateFee(double jobValue) => jobValue * 0.03;
  
  /// Job payment fee: 9% of amount (paid by worker)
  static double jobPaymentFee(double amount) => amount * 0.09;

  // ============ WITHDRAWALS (TIERED) ============
  /// Min withdrawal: 100 PINC
  static const int minWithdrawal = 100;
  
  static int withdrawalFee(int amount) {
    if (amount <= 0) return 0;
    if (amount <= 1000) return 3;
    if (amount <= 3000) return 10;
    if (amount <= 10000) return 19;
    if (amount <= 39000) return 35;
    if (amount <= 60000) return 45;
    if (amount <= 90000) return 60;
    if (amount <= 500000) return 74;
    return 103;
  }

  // ============ FILE STORAGE ============
  /// Free storage: 10 TB
  static const int freeStorageTB = 10;
  
  /// Overage fee per 10 TB: 100 PINC
  static const int overageFeePer10TB = 100;

  // ============ FUNDRAISING/CHALLENGES ============
  /// Fundraising fee: 9% of raised
  static double fundraisingFee(double raised) => raised * 0.09;
  
  /// Challenge collection fee: 9% of total
  static double challengeCollectionFee(double total) => total * 0.09;

  // ============ INTERNAL ============
  /// Internal transfers: FREE
  static const double internalTransferFee = 0;
  
  /// Max single transfer: 1 Trillion PINC
  static const int maxSingleTransfer = 1000000000000;

  // ============ DEPOSITS ============
  /// Deposits: FREE (no fee)
  static const double depositFee = 0;

  // ============ Helper Methods ============
  static String getWithdrawalFeeTier(int amount) {
    if (amount <= 1000) return '3 PINC';
    if (amount <= 3000) return '10 PINC';
    if (amount <= 10000) return '19 PINC';
    if (amount <= 39000) return '35 PINC';
    if (amount <= 60000) return '45 PINC';
    if (amount <= 90000) return '60 PINC';
    if (amount <= 500000) return '74 PINC';
    return '103 PINC';
  }
}

/// ==================== WALLET ====================
class PincWallet {
  double balance = 0.0;
  String pincId;
  final List<Transaction> transactions = [];
  
  PincWallet({required this.pincId});
  
  /// Send PINC (deducts fee automatically)
  bool sendPinc(double amount, String recipientId) {
    if (amount <= 0) return false;
    if (amount > balance) return false;
    if (amount > FeeService.maxSingleTransfer) return false;
    
    final fee = FeeService.internalTransferFee; // FREE internally
    final total = amount + fee;
    
    if (total > balance) return false;
    
    balance -= total;
    
    transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.send,
      amount: amount,
      fee: fee,
      recipient: recipientId,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
    ));
    
    return true;
  }
  
  /// Receive PINC
  void receivePinc(double amount, String senderId) {
    balance += amount;
    
    transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.receive,
      amount: amount,
      fee: 0,
      sender: senderId,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
    ));
  }
  
  /// Get balance (formatted)
  String getFormattedBalance() => balance.toStringAsFixed(2);
}

/// ==================== TRANSACTION ====================
enum TransactionType {
  send,
  receive,
  subscription,
  wager,
  savings,
  servicePayment,
  papaBusiness,
  jobPayment,
  fundraiser,
  challenge,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  disputed,
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final double fee;
  final String? recipient;
  final String? sender;
  final DateTime timestamp;
  final TransactionStatus status;
  
  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fee,
    this.recipient,
    this.sender,
    required this.timestamp,
    required this.status,
  });
  
  String get typeName {
    switch (type) {
      case TransactionType.send: return 'Send';
      case TransactionType.receive: return 'Receive';
      case TransactionType.subscription: return 'Subscription';
      case TransactionType.wager: return 'Wager';
      case TransactionType.savings: return 'Savings';
      case TransactionType.servicePayment: return 'Service Payment';
      case TransactionType.papaBusiness: return 'Papa Business';
      case TransactionType.jobPayment: return 'Job Payment';
      case TransactionType.fundraiser: return 'Fundraiser';
      case TransactionType.challenge: return 'Challenge';
    }
  }
}

/// ==================== ESCROW SYSTEM ====================
enum EscrowStatus {
  pending,
  funded,
  inProgress,
  submitted,
  approved,
  disputed,
  refunded,
}

class JobEscrow {
  final String jobId;
  final double amount;
  final double fee; // 3% create, 9% payment
  final String employer;
  String? worker;
  EscrowStatus status;
  final DateTime createdAt;
  DateTime? completedAt;
  int revisionAttempts = 0;
  
  JobEscrow({
    required this.jobId,
    required this.amount,
    required this.employer,
  }) : status = EscrowStatus.pending, 
       fee = FeeService.jobCreateFee(amount),
       createdAt = DateTime.now();
  
  /// Employer funds escrow
  bool fund(String workerId) {
    if (status != EscrowStatus.pending) return false;
    worker = workerId;
    status = EscrowStatus.funded;
    return true;
  }
  
  /// Worker marks job as submitted
  void submitWork() {
    if (status != EscrowStatus.funded) return;
    status = EscrowStatus.submitted;
  }
  
  /// Employer approves (releases payment to worker - 9% fee)
  bool approveAndRelease() {
    if (status != EscrowStatus.submitted) return false;
    final paymentFee = FeeService.jobPaymentFee(amount);
    status = EscrowStatus.approved;
    completedAt = DateTime.now();
    return true; // In real implementation: transfer amount - fee to worker
  }
  
  /// Request revision (max 3 attempts)
  bool requestRevision() {
    if (status != EscrowStatus.submitted) return false;
    if (revisionAttempts >= 3) return false;
    revisionAttempts++;
    status = EscrowStatus.inProgress;
    return true;
  }
  
  /// Dispute (escalates to platform)
  void dispute(String reason) {
    status = EscrowStatus.disputed;
  }
  
  /// Refund to employer
  void refund() {
    status = EscrowStatus.refunded;
  }
}

/// ==================== DEPOSIT METHODS ====================
enum DepositMethod {
  cryptoBSC,
  paypal,
  p2pAgent,
}

class DepositInfo {
  static const List<Map<String, dynamic>> methods = [
    {'type': DepositMethod.cryptoBSC, 'name': 'Crypto (BSC)', 'fee': 0, 'time': '5-15 min', 'limits': 'No limits'},
    {'type': DepositMethod.paypal, 'name': 'PayPal', 'fee': 0, 'time': 'Instant', 'limits': 'Via agents'},
    {'type': DepositMethod.p2pAgent, 'name': 'P2P Agent', 'fee': 0, 'time': 'Variable', 'limits': 'Local currency'},
  ];
  
  static String getFee(DepositMethod method) => 'FREE';
  static String getTime(DepositMethod method) {
    switch (method) {
      case DepositMethod.cryptoBSC: return '5-15 min';
      case DepositMethod.paypal: return 'Instant';
      case DepositMethod.p2pAgent: return 'Variable';
    }
  }
}

/// ==================== WITHDRAWAL ====================
enum WithdrawalMethod {
  cryptoBSC,
  paypal,
  p2pAgent,
}

class WithdrawalRequest {
  final double amount;
  final WithdrawalMethod method;
  final String recipientAddress;
  final double fee;
  final double netAmount;
  final DateTime requestedAt;
  WithdrawalStatus status;
  
  WithdrawalRequest({
    required this.amount,
    required this.method,
    required this.recipientAddress,
  }) : fee = FeeService.withdrawalFee(amount.toInt()).toDouble(),
       netAmount = amount - FeeService.withdrawalFee(amount.toInt()),
       requestedAt = DateTime.now(),
       status = WithdrawalStatus.pending;
  
  String getFee() => FeeService.getWithdrawalFeeTier(amount.toInt());
  String getNetAmount() => netAmount.toStringAsFixed(2);
}

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  failed,
}

/// ==================== TRANSFER TYPES ====================
enum TransferType {
  subscription,
  wagers,
  savings,
  servicePayment,
  papaBusiness,
}

class TransferTypeInfo {
  static String getName(TransferType type) {
    switch (type) {
      case TransferType.subscription: return 'Subscription';
      case TransferType.wagers: return 'Wagers/Challenges';
      case TransferType.savings: return 'Savings';
      case TransferType.servicePayment: return 'Service Payment';
      case TransferType.papaBusiness: return 'Papa Business';
    }
  }
  
  static double getFee(TransferType type) {
    switch (type) {
      case TransferType.subscription: return FeeService.basicSubscription.toDouble();
      case TransferType.wagers: return FeeService.p2pBetFee(100); // example
      case TransferType.savings: return 0;
      case TransferType.servicePayment: return FeeService.jobPaymentFee(100);
      case TransferType.papaBusiness: return FeeService.basicSubscription.toDouble() * 0.5;
    }
  }
}

/// ==================== EXPORTED INTERFACE ====================
class PincFinanceModule {
  static final fees = FeeService();
  
  static PincWallet createWallet(String pincId) => PincWallet(pincId: pincId);
  
  static JobEscrow createJobEscrow(String jobId, double amount, String employer) =>
    JobEscrow(jobId: jobId, amount: amount, employer: employer);
  
  static List<Map<String, dynamic>> getDepositMethods() => DepositInfo.methods;
  
  static WithdrawalRequest createWithdrawal(double amount, WithdrawalMethod method, String address) =>
    WithdrawalRequest(amount: amount, method: method, recipientAddress: address);
  
  static List<TransferType> getTransferTypes() => TransferType.values;
}