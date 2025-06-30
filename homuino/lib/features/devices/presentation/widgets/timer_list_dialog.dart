import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/features/devices/data/device_repository.dart';
import 'package:homuino/features/devices/domain/device.dart';

class TimerListDialog extends ConsumerStatefulWidget {
  final Device device;
  final String userId;
  final String deviceId;

  const TimerListDialog({
    Key? key,
    required this.device,
    required this.userId,
    required this.deviceId,
  }) : super(key: key);

  @override
  _TimerListDialogState createState() => _TimerListDialogState();
}

class _TimerListDialogState extends ConsumerState<TimerListDialog> {
  late Map<String, dynamic> timers;

  @override
  void initState() {
    super.initState();
    timers = Map<String, dynamic>.from(widget.device.timers ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Device Timers'),
      content: timers.isEmpty
          ? const Text('No timers set for this device')
          : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in timers.entries)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    '${entry.value['time']} - ${entry.value['action'] == 'turn_on' ? 'Turn On' : 'Turn Off'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.value['enabled'] ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: entry.value['enabled']
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: entry.value['enabled'] ?? false,
                        onChanged: (value) async {
                          final updatedTimers = Map<String, dynamic>.from(timers);
                          updatedTimers[entry.key] = {
                            ...entry.value,
                            'enabled': value,
                          };
                          try {
                            await ref.read(deviceRepositoryProvider).updateDevice(
                              widget.userId,
                              widget.device.copyWith(timers: updatedTimers),
                            );
                            setState(() {
                              timers = updatedTimers;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update timer: ${e.toString()}')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            final updatedTimers =
                            Map<String, dynamic>.from(timers);
                            updatedTimers.remove(entry.key);

                            await ref.read(deviceRepositoryProvider).updateDevice(
                              widget.userId,
                              widget.device.copyWith(timers: updatedTimers),
                            );

                            if (widget.deviceId.isNotEmpty) {
                              await ref
                                  .read(deviceRepositoryProvider)
                                  .deleteTimer(widget.deviceId, entry.key);
                            }

                            setState(() {
                              timers = updatedTimers;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Timer deleted')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete timer: ${e.toString()}')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
