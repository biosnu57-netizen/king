// PINC Network - Complete Fee Service
// All fee calculations as per user specifications

class FeeService {
  // ==================== INTERNET SHARING FEES ====================
  
  /// Seller subscription fee - 435 PINC per month
  static double getInternetSellerFee() => 435.0;
  
  /// Premium sharing (up to 10 people) - 325 PINC per month  
  static double getPremiumSharingFee() => 325.0;
  
  /// Free tier max people sharing
  static int getFreeSharingLimit() => 3;
  
  /// Speed per person minimum in Mbps
  static double getSpeedPerPersonMbps() => 1.0;
  
  /// SLA threshold for payment release (87%)
  static double getSLAThreshold() => 0.87;
  
  /// Delist threshold after 3 violations (76%)
  static double getDelistThreshold() => 0.76;
  
  /// Number of violations before delist
  static int getDelistViolations() => 3;
  
  /// Calculate max users based on internet speed
  static int calculateMaxUsers(double speedMbps) {
    return (speedMbps / getSpeedPerPersonMbps()).floor();
  }
  
  // ==================== BETTING FEES ====================
  
  /// P2P bet platform fee - 7% of winner's payout
  static double getP2PBetFee() => 0.07;
  
  /// Developer bet platform fee - 13% of total stakes
  static double getDeveloperBetFee() => 0.13;
  
  /// Maximum creator fee - 5% of winnings
  static double getCreatorMaxFee() => 0.05;
  
  /// Minimum wager amount
  static double getMinWager() => 20.0;
  
  /// Global challenge creation fee
  static double getGlobalChallengeFee() => 1560.0;
  
  /// Global challenge collection fee - 9%
  static double getChallengeCollectionFee() => 0.09;
  
  /// Calculate P2P bet fees
  static Map<String, dynamic> calculateP2PBetFees(double totalStake, double creatorFeePercent) {
    double platformFee = totalStake * getP2PBetFee();
    double creatorFee = totalStake * creatorFeePercent;
    double netWinnings = totalStake - platformFee - creatorFee;
    
    return {
      'totalStake': totalStake,
      'platformFee': platformFee,
      'platformFeePercent': getP2PBetFee() * 100,
      'creatorFee': creatorFee,
      'creatorFeePercent': creatorFeePercent * 100,
      'netWinnings': netWinnings,
    };
  }
  
  /// Calculate Developer bet fees
  static Map<String, dynamic> calculateDeveloperBetFees(double totalStake) {
    double platformFee = totalStake * getDeveloperBetFee();
    double poolForWinners = totalStake - platformFee;
    
    return {
      'totalStake': totalStake,
      'platformFee': platformFee,
      'platformFeePercent': getDeveloperBetFee() * 100,
      'poolForWinners': poolForWinners,
    };
  }
  
  /// Calculate global challenge fees
  static Map<String, dynamic> calculateChallengeFees(double totalCollection, int winnerPositions) {
    double platformFee = totalCollection * getChallengeCollectionFee();
    double prizePool = totalCollection - platformFee;
    double perWinner = winnerPositions > 0 ? prizePool / winnerPositions : 0;
    
    return {
      'totalCollection': totalCollection,
      'platformFee': platformFee,
      'prizePool': prizePool,
      'perWinner': perWinner,
      'winnerCount': winnerPositions,
    };
  }
  
  // ==================== FUNDRAISING FEES ====================
  
  /// Fundraising platform fee - 9%
  static double getFundraisingFee() => 0.09;
  
  static Map<String, dynamic> calculateFundraisingFees(double totalRaised) {
    double platformFee = totalRaised * getFundraisingFee();
    return {
      'totalRaised': totalRaised,
      'platformFee': platformFee,
      'netAmount': totalRaised - platformFee,
    };
  }
  
  // ==================== PLATFORM SUBSCRIPTION ====================
  
  /// Basic platform subscription - 325 PINC/month
  static double getPlatformSubscriptionFee() => 325.0;
  
  /// Free job bids per month
  static int getFreeJobBidsPerMonth() => 15;
  
  /// Unlimited job bids add-on fee - 300 PINC/month
  static double getUnlimitedJobBidsFee() => 300.0;
  
  // ==================== JOB MARKETPLACE FEES ====================
  
  /// Job creation fee - 3% of job value (paid by employer)
  static double getCreateJobFee() => 0.03;
  
  /// Payment receiving fee - 9% (paid by worker)
  static double getReceivePaymentFee() => 0.09;
  
  static Map<String, dynamic> calculateJobFees(double jobValue, double paymentReceived) {
    double createFee = jobValue * getCreateJobFee();
    double receiveFee = paymentReceived * getReceivePaymentFee();
    
    return {
      'jobValue': jobValue,
      'createFee': createFee,
      'paymentReceived': paymentReceived,
      'receiveFee': receiveFee,
      'netPayment': paymentReceived - receiveFee,
    };
  }
  
  // ==================== WITHDRAWAL FEES (TIERED) ====================
  
  /// Calculate withdrawal fee based on amount
  static double getWithdrawalFee(double amount) {
    if (amount <= 0) return 0;
    if (amount <= 1000) return 3.0;
    if (amount <= 3000) return 10.0;
    if (amount <= 10000) return 19.0;
    if (amount <= 39000) return 35.0;
    if (amount <= 60000) return 45.0;
    if (amount <= 90000) return 60.0;
    if (amount <= 500000) return 74.0;
    return 103.0;
  }
  
  /// Get withdrawal fee breakdown
  static Map<String, dynamic> getWithdrawalBreakdown(double amount) {
    double platformFee = getWithdrawalFee(amount);
    double netReceiving = amount - platformFee;
    
    return {
      'amount': amount,
      'platformFee': platformFee,
      'netReceiving': netReceiving,
      'feePercent': amount > 0 ? (platformFee / amount * 100) : 0,
    };
  }
  
  /// Minimum withdrawal amount
  static double getMinWithdrawal() => 100.0;
  
  /// Maximum single transfer
  static double getMaxTransfer() => 1000000000000; // 1 Trillion
  
  // ==================== API ACCESS ====================
  
  /// API access subscription - 1000 PINC/month
  static double getAPIAccessFee() => 1000.0;
  
  /// API request limit per hour
  static int getAPIRequestLimit() => 1000;
  
  // ==================== FILE STORAGE ====================
  
  /// Free storage limit in TB
  static int getFreeStorageTB() => 10;
  
  /// File overage fee per 10TB
  static double getFileStorageOverageFee() => 100.0;
  
  static Map<String, dynamic> calculateStorageFees(double usedTB) {
    int freeLimit = getFreeStorageTB();
    if (usedTB <= freeLimit) {
      return {
        'usedTB': usedTB,
        'freeLimit': freeLimit.toDouble(),
        'overageTB': 0.0,
        'fee': 0.0,
      };
    }
    
    double overageTB = usedTB - freeLimit;
    int blocks = (overageTB / 10).ceil();
    double fee = blocks * getFileStorageOverageFee();
    
    return {
      'usedTB': usedTB,
      'freeLimit': freeLimit.toDouble(),
      'overageTB': overageTB,
      'fee': fee,
    };
  }
  
  // ==================== DEPOSIT/WITHDRAW METHODS ====================
  
  static const List<Map<String, String>> depositMethods = [
    {'name': 'Credit Card', 'network': 'Third Party', 'fee': 'Free'},
    {'name': 'PayPal', 'network': 'Third Party', 'fee': 'Free'},
    {'name': 'P2P Agents', 'network': 'Direct Swap', 'fee': 'Free'},
    {'name': 'Crypto (USDT/USDC)', 'network': 'BSC Network', 'fee': 'Free'},
  ];
  
  // ==================== TRANSFER TYPES ====================
  
  static const Map<int, String> transferTypes = {
    1: 'Subscription',
    2: 'Wagers/Challenges',
    3: 'Savings',
    4: 'Service Payment',
    5: 'Papa Business',
  };
  
  // ==================== DATA RETENTION ====================
  
  /// Transaction log retention in days
  static int getTransactionLogDays() => 365;
  
  /// Chart/analytics log retention in days
  static int getChartLogDays() => 30;
  
  // ==================== ALL FEES SUMMARY ====================
  
  static Map<String, dynamic> getAllFees() {
    return {
      'internetSeller': getInternetSellerFee(),
      'premiumSharing': getPremiumSharingFee(),
      'freeSharingLimit': getFreeSharingLimit(),
      'p2pBetFee': getP2PBetFee() * 100,
      'developerBetFee': getDeveloperBetFee() * 100,
      'creatorMaxFee': getCreatorMaxFee() * 100,
      'minWager': getMinWager(),
      'globalChallengeFee': getGlobalChallengeFee(),
      'challengeCollection': getChallengeCollectionFee() * 100,
      'fundraising': getFundraisingFee() * 100,
      'platformSubscription': getPlatformSubscriptionFee(),
      'freeJobBids': getFreeJobBidsPerMonth(),
      'unlimitedJobBids': getUnlimitedJobBidsFee(),
      'createJobFee': getCreateJobFee() * 100,
      'receivePaymentFee': getReceivePaymentFee() * 100,
      'apiAccess': getAPIAccessFee(),
      'apiLimit': getAPIRequestLimit(),
      'fileStorageFree': getFreeStorageTB(),
      'fileStorageOverage': getFileStorageOverageFee(),
      'minWithdrawal': getMinWithdrawal(),
    };
  }
}