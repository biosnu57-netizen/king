import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// PINC Network Anti-Theft & Tracking Service
/// Prevents device shutdown, tracks thief, maps movement
class PincTrackingService {
  static final PincTrackingService _instance = PincTrackingService._internal();
  factory PincTrackingService() => _instance;
  PincTrackingService._internal();

  // Tracking Configuration
  static const int locationUpdateIntervalSeconds = 30;
  static const int maxTrackingHistoryDays = 365;

  // State
  bool _isTrackingEnabled = false;
  bool _isTheftMode = false;
  String? _ownerId;
  DateTime? _lastLocationUpdate;
  final List<LocationRecord> _locationHistory = [];
  final List<DeviceStatus> _deviceStatusHistory = [];

  // Getters
  bool get isTrackingEnabled => _isTrackingEnabled;
  bool get isTheftMode => _isTheftMode;
  List<LocationRecord> get locationHistory => List.unmodifiable(_locationHistory);

  // ============================================
  // THEFT PREVENTION - DEVICE CONTROL
  // ============================================

  /// Prevent device from being turned off
  Future<bool> enableShutdownProtection() async {
    // In production: use AccessibilityService or DeviceAdmin
    // to intercept power button and show PIN prompt
    _isTrackingEnabled = true;
    return true;
  }

  /// Disable shutdown protection
  Future<bool> disableShutdownProtection() async {
    _isTrackingEnabled = false;
    return true;
  }

  /// Check if device can be turned off
  bool canShutdown() {
    return !_isTrackingEnabled || !_isTheftMode;
  }

  /// Activate theft mode (lost/stolen)
  Future<void> activateTheftMode({
    required String ownerId,
    String? message,
  }) async {
    _isTheftMode = true;
    _ownerId = ownerId;
    
    // Enable all tracking
    await enableShutdownProtection();
    
    // Start aggressive location tracking
    await _startAggressiveTracking();
    
    // Log activation
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'THEFT_MODE_ACTIVATED',
      message: message ?? 'Device reported stolen',
    ));
  }

  /// Deactivate theft mode (device found)
  Future<void> deactivateTheftMode() async {
    _isTheftMode = false;
    
    // Reduce tracking frequency
    await _startNormalTracking();
    
    // Log deactivation
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'THEFT_MODE_DEACTIVATED',
      message: 'Device recovered',
    ));
  }

  // ============================================
  // LOCATION TRACKING
  // ============================================

  /// Start normal location tracking
  Future<void> _startNormalTracking() async {
    // Update location every 30 seconds
    Timer.periodic(
      const Duration(seconds: locationUpdateIntervalSeconds),
      (_) => _updateLocation(),
    );
  }

  /// Start aggressive tracking (theft mode)
  Future<void> _startAggressiveTracking() async {
    // Update location every 10 seconds
    Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateLocation(),
    );
  }

  /// Update current location
  Future<void> _updateLocation() async {
    // In production: get actual GPS location
    final record = LocationRecord(
      timestamp: DateTime.now(),
      latitude: 0.0, // Would be actual GPS
      longitude: 0.0,
      accuracy: 0.0,
      speed: 0.0,
      heading: 0.0,
      batteryLevel: 0.0,
      isCharging: false,
      networkType: 'wifi',
    );
    
    _locationHistory.add(record);
    _lastLocationUpdate = record.timestamp;
    
    // Keep only last N days
    _cleanupOldLocations();
  }

  /// Get current location
  Future<LocationRecord?> getCurrentLocation() async {
    return _locationHistory.isNotEmpty ? _locationHistory.last : null;
  }

  /// Get location history for a time period
  List<LocationRecord> getLocationHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _locationHistory;
    
    if (startDate != null) {
      filtered = filtered.where((r) => r.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((r) => r.timestamp.isBefore(endDate)).toList();
    }
    
    return filtered;
  }

  /// Cleanup old location records
  void _cleanupOldLocations() {
    final cutoff = DateTime.now().subtract(
      Duration(days: maxTrackingHistoryDays),
    );
    _locationHistory.removeWhere((r) => r.timestamp.isBefore(cutoff));
  }

  // ============================================
  // MOVEMENT MAPPING
  // ============================================

  /// Generate movement map data
  MovementMap getMovementMap({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final locations = getLocationHistory(
      startDate: startDate,
      endDate: endDate,
    );
    
    return MovementMap(
      records: locations,
      totalDistanceKm: _calculateTotalDistance(locations),
      placesVisited: _extractUniquePlaces(locations),
      timeAtEachLocation: _calculateTimeAtLocations(locations),
    );
  }

  double _calculateTotalDistance(List<LocationRecord> locations) {
    if (locations.length < 2) return 0;
    
    double totalDistance = 0;
    for (int i = 1; i < locations.length; i++) {
      totalDistance += _haversineDistance(
        locations[i-1].latitude,
        locations[i-1].longitude,
        locations[i].latitude,
        locations[i].longitude,
      );
    }
    return totalDistance;
  }

  List<String> _extractUniquePlaces(List<LocationRecord> locations) {
    // In production: reverse geocode to get place names
    return ['Home', 'Work', 'Market', 'Park']; // Placeholder
  }

  Map<String, Duration> _calculateTimeAtLocations(List<LocationRecord> locations) {
    // Calculate time spent at each location
    return {'Home': const Duration(hours: 8), 'Work': const Duration(hours: 8)};
  }

  /// Haversine distance calculation
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat/2) * sin(dLat/2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon/2) * sin(dLon/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;

  // ============================================
  // DEVICE STATUS MONITORING
  // ============================================

  /// Monitor device status changes
  void monitorDeviceStatus() {
    // In production: listen to system broadcasts
    // - Battery level changes
    // - Network changes
    // - Screen on/off
    // - App installation/removal
  }

  /// Get device status history
  List<DeviceStatus> getDeviceStatusHistory() {
    return List.unmodifiable(_deviceStatusHistory);
  }

  // ============================================
  // REMOTE CONTROL
  // ============================================

  /// Remote wipe device
  Future<void> remoteWipe() async {
    // In production: execute factory reset
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'REMOTE_WIPE',
      message: 'Device wiped remotely',
    ));
  }

  /// Remote lock device
  Future<void> remoteLock() async {
    // In production: lock device with PIN
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'REMOTE_LOCK',
      message: 'Device locked remotely',
    ));
  }

  /// Play alarm sound
  Future<void> playAlarm() async {
    // In production: play loud alarm sound
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'ALARM_PLAYED',
      message: 'Alarm triggered',
    ));
  }

  /// Display message on screen
  Future<void> displayMessage(String message) async {
    // In production: show lock screen message
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'MESSAGE_DISPLAYED',
      message: message,
    ));
  }

  /// Take photo with front camera
  Future<void> takePhoto() async {
    // In production: capture photo and upload
    _deviceStatusHistory.add(DeviceStatus(
      timestamp: DateTime.now(),
      status: 'PHOTO_CAPTURED',
      message: 'Photo captured for tracking',
    ));
  }

  // ============================================
  // NETWORK SYNC
  // ============================================

  /// Sync location to network (other nodes)
  Future<void> syncToNetwork() async {
    // Upload encrypted location to mesh network
    // Other nodes hold backup of location data
  }

  /// Get last sync time
  DateTime? getLastNetworkSync() {
    // Return last sync timestamp
    return _lastLocationUpdate;
  }
}

// ============================================
// DATA MODELS
// ============================================

class LocationRecord {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final double heading;
  final double batteryLevel;
  final bool isCharging;
  final String networkType;

  LocationRecord({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.batteryLevel,
    required this.isCharging,
    required this.networkType,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'speed': speed,
    'heading': heading,
    'batteryLevel': batteryLevel,
    'isCharging': isCharging,
    'networkType': networkType,
  };
}

class DeviceStatus {
  final DateTime timestamp;
  final String status;
  final String message;

  DeviceStatus({
    required this.timestamp,
    required this.status,
    required this.message,
  });
}

class MovementMap {
  final List<LocationRecord> records;
  final double totalDistanceKm;
  final List<String> placesVisited;
  final Map<String, Duration> timeAtEachLocation;

  MovementMap({
    required this.records,
    required this.totalDistanceKm,
    required this.placesVisited,
    required this.timeAtEachLocation,
  });
}