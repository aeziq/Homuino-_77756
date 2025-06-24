import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/features/devices/data/device_repository.dart';
import 'package:homuino/features/devices/domain/device.dart';

class TimerListDialog extends ConsumerWidget {
  final Device device;
  final String userId;

  const TimerListDialog({
    Key? key,
    required this.device,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = device.timers ?? {};

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
                      color: entry.value['enabled'] ? Colors.green : Colors.grey,
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
                              userId,
                              device.copyWith(timers: updatedTimers),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update timer: ${e.toString()}')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final updatedTimers = Map<String, dynamic>.from(timers);
                          updatedTimers.remove(entry.key);

                          try {
                            await ref.read(deviceRepositoryProvider).updateDevice(
                              userId,
                              device.copyWith(timers: updatedTimers),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete timer: ${e.toString()}')),
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