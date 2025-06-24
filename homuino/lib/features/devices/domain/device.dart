class Device {
  final String deviceId;
  final String ownerId;
  final String name;
  final String type;
  final String switchName;
  final String groupId;
  final bool isFavorite;
  final bool isOn;
  final String status;
  final String switchState;
  final int? createdAt;
  final int? updatedAt;
  final Map<String, dynamic>? timers;

  Device({
    required this.deviceId,
    required this.ownerId,
    required this.name,
    required this.type,
    this.switchName = '',
    this.groupId = '',
    this.isFavorite = false,
    this.isOn = false,
    this.status = 'OFFLINE',
    this.switchState = 'OFF',
    this.createdAt,
    this.updatedAt,
    this.timers,
  });

  Device copyWith({
    String? deviceId,
    String? ownerId,
    String? name,
    String? type,
    String? switchName,
    String? groupId,
    bool? isFavorite,
    bool? isOn,
    String? status,
    String? switchState,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? timers,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      switchName: switchName ?? this.switchName,
      groupId: groupId ?? this.groupId,
      isFavorite: isFavorite ?? this.isFavorite,
      isOn: isOn ?? this.isOn,
      status: status ?? this.status,
      switchState: switchState ?? this.switchState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timers: timers ?? this.timers,
    );
  }

  factory Device.fromMap(String id, Map<String, dynamic> data) {
    // Ensure timers are properly parsed
    Map<String, dynamic>? parsedTimers;
    if (data['timers'] != null) {
      if (data['timers'] is Map) {
        parsedTimers = Map<String, dynamic>.from(data['timers']);
      } else {
        // Handle case where timers might be in a different format
        parsedTimers = {};
      }
    }

    return Device(
      deviceId: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'Light',
      switchName: data['switchName'] ?? '',
      groupId: data['groupId'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      isOn: data['isOn'] ?? false,
      status: data['status'] ?? 'OFFLINE',
      switchState: data['switchState'] ?? 'OFF',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      timers: parsedTimers,
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'type': type,
    'switchName': switchName,
    'groupId': groupId,
    'isFavorite': isFavorite,
    'isOn': isOn,
    'status': status,
    'switchState': switchState,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'timers': timers,
  };
}