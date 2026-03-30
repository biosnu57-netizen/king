import 'dart:async';

/// PINC Network Global Events & Notification System
/// Enables users to create/join global events with rules, fees, and competitions
class PincEventsService {
  static final PincEventsService _instance = PincEventsService._internal();
  factory PincEventsService() => _instance;
  PincEventsService._internal();

  // Events storage
  final List<GlobalEvent> _events = [];
  final List<EventParticipant> _participants = [];
  final Map<String, List<Notification>> _notifications = {};
  final Map<String, List<Message>> _eventMessages = {};

  // Getters
  List<GlobalEvent> get activeEvents => _events.where((e) => e.status == EventStatus.active).toList();
  List<GlobalEvent> get allEvents => List.unmodifiable(_events);

  // ============================================
  // EVENT CREATION
  // ============================================

  /// Create a new global event
  Future<GlobalEvent> createEvent({
    required String creatorId,
    required String title,
    required String description,
    required EventType eventType,
    required double entryFee,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? rules,
    List<Reward>? rewards,
    bool isPublic = true,
  }) async {
    final event = GlobalEvent(
      id: _generateId(),
      creatorId: creatorId,
      title: title,
      description: description,
      eventType: eventType,
      entryFee: entryFee,
      maxParticipants: maxParticipants,
      currentParticipants: 0,
      startDate: startDate,
      endDate: endDate,
      rules: rules ?? [],
      rewards: rewards ?? [],
      status: EventStatus.active,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );

    _events.add(event);
    _eventMessages[event.id] = [];

    // Notify all users about new event
    await _broadcastNotification(
      title: 'New Global Event: $title',
      body: 'Join now! Entry fee: $entryFee PINC',
      data: {'eventId': event.id, 'type': 'new_event'},
    );

    return event;
  }

  /// Update event
  Future<bool> updateEvent({
    required String eventId,
    String? title,
    String? description,
    List<String>? rules,
    List<Reward>? rewards,
  }) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    final event = _events[index];
    _events[index] = event.copyWith(
      title: title ?? event.title,
      description: description ?? event.description,
      rules: rules ?? event.rules,
      rewards: rewards ?? event.rewards,
    );

    return true;
  }

  /// Cancel event (refund participants)
  Future<void> cancelEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _events[index];
    _events[index] = event.copyWith(status: EventStatus.cancelled);

    // Notify all participants
    await _notifyParticipants(
      eventId: eventId,
      title: 'Event Cancelled: ${event.title}',
      body: 'Entry fees will be refunded',
    );
  }

  // ============================================
  // EVENT PARTICIPATION
  // ============================================

  /// Join an event
  Future<EventJoinResult> joinEvent({
    required String eventId,
    required String userId,
    required double entryFee,
  }) async {
    final event = _events.firstWhere((e) => e.id == eventId, orElse: () => throw Exception('Event not found'));

    // Check if event is full
    if (event.currentParticipants >= event.maxParticipants) {
      return EventJoinResult(success: false, reason: 'Event is full');
    }

    // Check if already joined
    final alreadyJoined = _participants.any(
      (p) => p.eventId == eventId && p.userId == userId,
    );
    if (alreadyJoined) {
      return EventJoinResult(success: false, reason: 'Already joined');
    }

    // Add participant
    _participants.add(EventParticipant(
      id: _generateId(),
      eventId: eventId,
      userId: userId,
      entryFee: entryFee,
      joinedAt: DateTime.now(),
      rank: event.currentParticipants + 1,
      score: 0,
      status: ParticipantStatus.active,
    ));

    // Update event participant count
    final index = _events.indexWhere((e) => e.id == eventId);
    _events[index] = event.copyWith(currentParticipants: event.currentParticipants + 1);

    // Notify creator
    await _notifyUser(
      userId: event.creatorId,
      title: 'New Participant',
      body: 'User $userId joined ${event.title}',
    );

    return EventJoinResult(success: true, eventId: eventId);
  }

  /// Leave an event
  Future<bool> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    final participantIndex = _participants.indexWhere(
      (p) => p.eventId == eventId && p.userId == userId,
    );
    if (participantIndex == -1) return false;

    _participants[participantIndex] = _participants[participantIndex].copyWith(
      status: ParticipantStatus.left,
    );

    return true;
  }

  /// Update participant score (for competitions)
  Future<void> updateScore({
    required String eventId,
    required String userId,
    required double score,
  }) async {
    final index = _participants.indexWhere(
      (p) => p.eventId == eventId && p.userId == userId,
    );
    if (index == -1) return;

    _participants[index] = _participants[index].copyWith(score: score);
  }

  /// Get event leaderboard
  List<EventParticipant> getLeaderboard(String eventId) {
    final eventParticipants = _participants
        .where((p) => p.eventId == eventId)
        .toList();
    eventParticipants.sort((a, b) => b.score.compareTo(a.score));
    return eventParticipants;
  }

  // ============================================
  // EVENT MESSAGES & CHAT
  // ============================================

  /// Send message to event
  Future<void> sendMessage({
    required String eventId,
    required String userId,
    required String message,
  }) async {
    final msg = Message(
      id: _generateId(),
      eventId: eventId,
      userId: userId,
      message: message,
      timestamp: DateTime.now(),
    );

    _eventMessages[eventId]?.add(msg);
  }

  /// Get event messages
  List<Message> getEventMessages(String eventId) {
    return _eventMessages[eventId] ?? [];
  }

  // ============================================
  // RANKING & REWARDS
  // ============================================

  /// End event and distribute rewards
  Future<void> endEvent({
    required String eventId,
    required String adminId,
  }) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final leaderboard = getLeaderboard(eventId);

    // Mark event as completed
    final index = _events.indexWhere((e) => e.id == eventId);
    _events[index] = event.copyWith(status: EventStatus.completed);

    // Distribute rewards to top players
    if (event.rewards.isNotEmpty) {
      for (int i = 0; i < event.rewards.length && i < leaderboard.length; i++) {
        final participant = leaderboard[i];
        final reward = event.rewards[i];

        await _notifyUser(
          userId: participant.userId,
          title: 'Congratulations!',
          body: 'You won ${reward.amount} PINC in ${event.title}!',
        );
      }
    }

    // Update all participant ranks
    for (int i = 0; i < leaderboard.length; i++) {
      final pIndex = _participants.indexWhere((p) => p.id == leaderboard[i].id);
      _participants[pIndex] = _participants[pIndex].copyWith(rank: i + 1);
    }
  }

  // ============================================
  // GLOBAL NOTIFICATIONS
  // ============================================

  /// Broadcast notification to all users
  Future<void> _broadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // In production: send push notification to all users via FCM
    // This notifies all online users globally
  }

  /// Notify specific user
  Future<void> _notifyUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    _notifications[userId] ??= [];
    _notifications[userId]!.add(Notification(
      id: _generateId(),
      title: title,
      body: body,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Notify all participants of event
  Future<void> _notifyParticipants({
    required String eventId,
    required String title,
    required String body,
  }) async {
    final eventParticipants = _participants.where((p) => p.eventId == eventId);
    for (final p in eventParticipants) {
      await _notifyUser(userId: p.userId, title: title, body: body);
    }
  }

  /// Get user notifications
  List<Notification> getNotifications(String userId) {
    return _notifications[userId] ?? [];
  }

  /// Mark notification as read
  void markNotificationRead(String userId, String notificationId) {
    final index = _notifications[userId]?.indexWhere((n) => n.id == notificationId);
    if (index != null && index >= 0) {
      // Mark as read
    }
  }

  /// Clear all notifications
  void clearNotifications(String userId) {
    _notifications[userId]?.clear();
  }

  // ============================================
  // UTILITIES
  // ============================================

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get events by type
  List<GlobalEvent> getEventsByType(EventType type) {
    return _events.where((e) => e.eventType == type && e.status == EventStatus.active).toList();
  }

  /// Search events
  List<GlobalEvent> searchEvents(String query) {
    return _events.where((e) =>
      e.title.toLowerCase().contains(query.toLowerCase()) ||
      e.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

// ============================================
// DATA MODELS
// ============================================

enum EventType {
  competition,
  tournament,
  league,
  challenge,
  bet,
  social,
  other,
}

enum EventStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

enum ParticipantStatus {
  active,
  left,
  disqualified,
  winner,
}

class GlobalEvent {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final EventType eventType;
  final double entryFee;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> rules;
  final List<Reward> rewards;
  final EventStatus status;
  final bool isPublic;
  final DateTime createdAt;

  GlobalEvent({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.entryFee,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.startDate,
    required this.endDate,
    required this.rules,
    required this.rewards,
    required this.status,
    required this.isPublic,
    required this.createdAt,
  });

  GlobalEvent copyWith({
    String? title,
    String? description,
    List<String>? rules,
    List<Reward>? rewards,
    int? currentParticipants,
    EventStatus? status,
  }) {
    return GlobalEvent(
      id: id,
      creatorId: creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType,
      entryFee: entryFee,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      startDate: startDate,
      endDate: endDate,
      rules: rules ?? this.rules,
      rewards: rewards ?? this.rewards,
      status: status ?? this.status,
      isPublic: isPublic,
      createdAt: createdAt,
    );
  }
}

class EventParticipant {
  final String id;
  final String eventId;
  final String userId;
  final double entryFee;
  final DateTime joinedAt;
  final int rank;
  final double score;
  final ParticipantStatus status;

  EventParticipant({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.entryFee,
    required this.joinedAt,
    required this.rank,
    required this.score,
    required this.status,
  });

  EventParticipant copyWith({
    int? rank,
    double? score,
    ParticipantStatus? status,
  }) {
    return EventParticipant(
      id: id,
      eventId: eventId,
      userId: userId,
      entryFee: entryFee,
      joinedAt: joinedAt,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      status: status ?? this.status,
    );
  }
}

class Reward {
  final int position;
  final double amount;
  final String? title;

  Reward({
    required this.position,
    required this.amount,
    this.title,
  });
}

class Message {
  final String id;
  final String eventId;
  final String userId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.message,
    required this.timestamp,
  });
}

class Notification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
  });
}

class EventJoinResult {
  final bool success;
  final String? eventId;
  final String? reason;

  EventJoinResult({
    required this.success,
    this.eventId,
    this.reason,
  });
}