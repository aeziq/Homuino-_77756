import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../domain/device.dart';
import '../../../core/errors/exceptions.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository();
});

class DeviceRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get _devicesRef => _database.ref('devices');

  Future<List<Device>> getDevicesForUser(String uid) async {
    try {
      print('[DEBUG] Fetching devices for UID: $uid');
      final snapshot = await _devicesRef
          .orderByChild('ownerId')
          .equalTo(uid)
          .get();

      if (!snapshot.exists) {
        print('[DEBUG] No devices found for user');
        return [];
      }

      final Map<dynamic, dynamic> data = snapshot.value as Map;
      print('[DEBUG] Found ${data.length} devices');

      return data.entries.map((e) {
        return Device.fromMap(
          e.key.toString(),
          Map<String, dynamic>.from(e.value as Map),
        );
      }).toList();
    } catch (e) {
      print('[ERROR] Failed to get devices: $e');
      throw DatabaseException.readFailed('devices/$uid');
    }
  }

  Stream<List<Device>> watchDevices(String uid) {
    return _devicesRef
        .orderByChild('ownerId')
        .equalTo(uid)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];

      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      return data.entries.map((e) {
        return Device.fromMap(
          e.key.toString(),
          Map<String, dynamic>.from(e.value as Map),
        );
      }).toList();
    });
  }

  Future<String> addDevice(String userId, Device device) async {
    try {
      final newDeviceRef = _devicesRef.push();
      await newDeviceRef.set({
        'ownerId': userId,
        'name': device.name,
        'type': device.type,
        'status': 'OFFLINE',
        'createdAt': ServerValue.timestamp,
      });
      return newDeviceRef.key!;
    } catch (e) {
      throw DatabaseException.writeFailed('devices');
    }
  }

  Future<void> updateDevice(String userId, Device device) async {
    try {
      print('[DEBUG] Updating device ${device.deviceId} for UID: $userId');

      // Create update data map
      final Map<String, dynamic> updateData = {
        'name': device.name,
        'type': device.type,
        'switchName': device.switchName,
        'groupId': device.groupId,
        'isFavorite': device.isFavorite,
        'isOn': device.isOn,
        'status': device.status,
        'switchState': device.switchState,
        'updatedAt': ServerValue.timestamp,
      };

      // Only add timers if they exist
      if (device.timers != null) {
        updateData['timers'] = device.timers;
      }

      await _devicesRef.child(device.deviceId).update(updateData);
      print('[DEBUG] Device updated successfully');
    } catch (e) {
      print('[ERROR] Failed to update device: $e');
      throw DatabaseException.writeFailed('devices/${device.deviceId}');
    }
  }

  Future<void> deleteDevice(String userId, String deviceId) async {
    try {
      print('[DEBUG] Deleting device $deviceId for UID: $userId');
      await _devicesRef.child(deviceId).remove();
      print('[DEBUG] Device deleted successfully');
    } catch (e) {
      print('[ERROR] Failed to delete device: $e');
      throw DatabaseException.writeFailed('devices/$deviceId');
    }
  }
}