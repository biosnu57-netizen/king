// PINC Network - Job Service
// Handles job marketplace, bidding, and disputes

import 'fee_service.dart';
import 'storage_service.dart';

class JobService {
  List<Map<String, dynamic>> _availableJobs = [];
  List<Map<String, dynamic>> _myJobs = [];
  int _bidsUsedThisMonth = 0;
  
  // ==================== GET JOBS ====================
  
  List<Map<String, dynamic>> getAvailableJobs() => _availableJobs;
  List<Map<String, dynamic>> getMyJobs() => _myJobs;
  int getBidsUsedThisMonth() => _bidsUsedThisMonth;
  int getRemainingBids() => FeeService.getFreeJobBidsPerMonth() - _bidsUsedThisMonth;
  
  // ==================== INITIALIZE ====================
  
  Future<void> initialize() async {
    _availableJobs = LocalStorageService.getJobs();
    _myJobs = LocalStorageService.getMyJobs();
  }
  
  // ==================== POST JOB ====================
  
  Future<Map<String, dynamic>> postJob({
    required String title,
    required String description,
    required double budget,
    required String deadline,
    required List<String> skills,
    required int workersNeeded,
  }) async {
    // Calculate fee (3% of job value)
    double fee = budget * FeeService.getCreateJobFee();
    double total = budget + fee;
    
    final job = {
      'id': _generateJobId(),
      'title': title,
      'description': description,
      'budget': budget,
      'fee': fee,
      'total': total,
      'deadline': deadline,
      'skills': skills,
      'workersNeeded': workersNeeded,
      'status': 'open',
      'bids': [],
      'createdAt': DateTime.now().toIso8601String(),
      'employerPincId': '', // Set from user
    };
    
    _availableJobs.insert(0, job);
    await LocalStorageService.saveJobs(_availableJobs);
    
    return {
      'success': true,
      'job': job,
      'feeDetails': {'budget': budget, 'fee': fee, 'total': total},
    };
  }
  
  // ==================== PLACE BID ====================
  
  Future<Map<String, dynamic>> placeBid({
    required String jobId,
    required String workerPincId,
    required double bidAmount,
    required String coverLetter,
    required int estimatedDays,
  }) async {
    // Check bid limit
    if (getRemainingBids() <= 0) {
      return {
        'success': false,
        'error': 'Monthly bid limit reached. Subscribe for unlimited bids.',
        'subscribeFee': FeeService.getUnlimitedJobBidsFee(),
      };
    }
    
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    // Check if already bid
    List bids = List.from(_availableJobs[jobIndex]['bids'] ?? []);
    final existingBid = bids.where((b) => b['workerPincId'] == workerPincId).firstOrNull;
    if (existingBid != null) {
      return {'success': false, 'error': 'You have already placed a bid'};
    }
    
    final bid = {
      'id': _generateBidId(),
      'workerPincId': workerPincId,
      'bidAmount': bidAmount,
      'coverLetter': coverLetter,
      'estimatedDays': estimatedDays,
      'status': 'pending',
      'submittedAt': DateTime.now().toIso8601String(),
    };
    
    bids.add(bid);
    _availableJobs[jobIndex]['bids'] = bids;
    _bidsUsedThisMonth++;
    
    await LocalStorageService.saveJobs(_availableJobs);
    
    return {'success': true, 'bid': bid, 'remainingBids': getRemainingBids()};
  }
  
  // ==================== ACCEPT BID ====================
  
  Future<Map<String, dynamic>> acceptBid({
    required String jobId,
    required String bidId,
  }) async {
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    List bids = List.from(_availableJobs[jobIndex]['bids'] ?? []);
    int bidIndex = bids.indexWhere((b) => b['id'] == bidId);
    if (bidIndex < 0) {
      return {'success': false, 'error': 'Bid not found'};
    }
    
    // Update bid status
    bids[bidIndex]['status'] = 'accepted';
    
    // Mark other bids as rejected
    for (int i = 0; i < bids.length; i++) {
      if (i != bidIndex && bids[i]['status'] == 'pending') {
        bids[i]['status'] = 'rejected';
      }
    }
    
    // Update job status
    _availableJobs[jobIndex]['status'] = 'in_progress';
    _availableJobs[jobIndex]['acceptedBid'] = bids[bidIndex];
    
    // Add to my jobs
    final myJob = {..._availableJobs[jobIndex], 'role': 'employer'};
    _myJobs.insert(0, myJob);
    
    await LocalStorageService.saveJobs(_availableJobs);
    await LocalStorageService.saveMyJobs(_myJobs);
    
    return {'success': true, 'job': _availableJobs[jobIndex], 'bid': bids[bidIndex]};
  }
  
  // ==================== SUBMIT WORK ====================
  
  Future<Map<String, dynamic>> submitWork({
    required String jobId,
    required String workDetails,
    required List<String> attachments,
  }) async {
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    final submission = {
      'id': _generateSubmissionId(),
      'jobId': jobId,
      'workDetails': workDetails,
      'attachments': attachments,
      'submittedAt': DateTime.now().toIso8601String(),
      'attempts': 1,
      'status': 'pending_review',
    };
    
    // Add to my jobs if worker
    final myJobIndex = _myJobs.indexWhere((j) => j['id'] == jobId);
    if (myJobIndex >= 0) {
      _myJobs[myJobIndex]['submissions'] = [submission];
      await LocalStorageService.saveMyJobs(_myJobs);
    }
    
    return {'success': true, 'submission': submission};
  }
  
  // ==================== APPROVE WORK ====================
  
  Future<Map<String, dynamic>> approveWork({
    required String jobId,
    required double paymentAmount,
  }) async {
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    // Calculate fees
    double fee = paymentAmount * FeeService.getReceivePaymentFee();
    double netAmount = paymentAmount - fee;
    
    _availableJobs[jobIndex]['status'] = 'completed';
    _availableJobs[jobIndex]['finalPayment'] = paymentAmount;
    _availableJobs[jobIndex]['workerFee'] = fee;
    _availableJobs[jobIndex]['workerNet'] = netAmount;
    
    await LocalStorageService.saveJobs(_availableJobs);
    
    return {
      'success': true,
      'job': _availableJobs[jobIndex],
      'paymentDetails': {
        'gross': paymentAmount,
        'fee': fee,
        'net': netAmount,
      },
    };
  }
  
  // ==================== REQUEST REVISION ====================
  
  Future<Map<String, dynamic>> requestRevision({
    required String jobId,
    required String feedback,
  }) async {
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    // Check attempt limit (max 3)
    List submissions = List.from(_availableJobs[jobIndex]['submissions'] ?? []);
    int attempts = submissions.isNotEmpty ? (submissions[0]['attempts'] ?? 0) : 0;
    
    if (attempts >= 3) {
      return {
        'success': false,
        'error': 'Maximum revision attempts (3) reached',
        'action': 'dispute',
      };
    }
    
    // Create new submission with revision request
    final revision = {
      'id': _generateSubmissionId(),
      'jobId': jobId,
      'feedback': feedback,
      'type': 'revision_request',
      'submittedAt': DateTime.now().toIso8601String(),
      'attempts': attempts + 1,
      'status': 'revision_requested',
    };
    
    if (submissions.isEmpty) {
      submissions.add(revision);
    } else {
      submissions[0] = {...submissions[0], ...revision};
    }
    
    _availableJobs[jobIndex]['submissions'] = submissions;
    await LocalStorageService.saveJobs(_availableJobs);
    
    return {
      'success': true,
      'revision': revision,
      'remainingAttempts': 3 - (attempts + 1),
    };
  }
  
  // ==================== DISPUTE RESOLUTION ====================
  
  Future<Map<String, dynamic>> openDispute({
    required String jobId,
    required String partyPincId,
    required String reason,
    required String evidence,
  }) async {
    final dispute = {
      'id': _generateDisputeId(),
      'jobId': jobId,
      'openedBy': partyPincId,
      'reason': reason,
      'evidence': evidence,
      'status': 'open',
      'attempts': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'resolution': null,
    };
    
    // Add to job
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex >= 0) {
      _availableJobs[jobIndex]['dispute'] = dispute;
      await LocalStorageService.saveJobs(_availableJobs);
    }
    
    return {'success': true, 'dispute': dispute};
  }
  
  Future<Map<String, dynamic>> resolveDispute({
    required String jobId,
    required String resolution, // 'worker_wins', 'client_wins', 'split'
    required String details,
  }) async {
    final jobIndex = _availableJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex < 0) {
      return {'success': false, 'error': 'Job not found'};
    }
    
    Map<String, dynamic>? dispute = _availableJobs[jobIndex]['dispute'];
    if (dispute == null) {
      return {'success': false, 'error': 'No dispute found'};
    }
    
    dispute['status'] = 'resolved';
    dispute['resolution'] = resolution;
    dispute['details'] = details;
    dispute['resolvedAt'] = DateTime.now().toIso8601String();
    
    // Update job status
    if (resolution == 'worker_wins') {
      _availableJobs[jobIndex]['status'] = 'completed_worker';
    } else if (resolution == 'client_wins') {
      _availableJobs[jobIndex]['status'] = 'completed_client';
    } else {
      _availableJobs[jobIndex]['status'] = 'completed_split';
    }
    
    await LocalStorageService.saveJobs(_availableJobs);
    
    return {'success': true, 'dispute': dispute, 'job': _availableJobs[jobIndex]};
  }
  
  // ==================== SEARCH JOBS ====================
  
  List<Map<String, dynamic>> searchJobs({
    String? query,
    String? category,
    double? minBudget,
    double? maxBudget,
  }) {
    var results = _availableJobs.where((job) {
      if (job['status'] != 'open') return false;
      
      if (query != null && query.isNotEmpty) {
        final title = (job['title'] ?? '').toLowerCase();
        final desc = (job['description'] ?? '').toLowerCase();
        if (!title.contains(query.toLowerCase()) && !desc.contains(query.toLowerCase())) {
          return false;
        }
      }
      
      if (category != null && category.isNotEmpty) {
        if (job['category'] != category) return false;
      }
      
      if (minBudget != null && (job['budget'] ?? 0) < minBudget) return false;
      if (maxBudget != null && (job['budget'] ?? 0) > maxBudget) return false;
      
      return true;
    }).toList();
    
    return results;
  }
  
  // ==================== HELPERS ====================
  
  String _generateJobId() => 'JOB-${DateTime.now().millisecondsSinceEpoch}';
  String _generateBidId() => 'BID-${DateTime.now().millisecondsSinceEpoch}';
  String _generateSubmissionId() => 'SUB-${DateTime.now().millisecondsSinceEpoch}';
  String _generateDisputeId() => 'DSP-${DateTime.now().millisecondsSinceEpoch}';
}