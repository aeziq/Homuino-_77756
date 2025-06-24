import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homuino/core/loading_indicator.dart';
import '../../devices/data/device_repository.dart';
import '../../devices/domain/device.dart';
import '../presentation/widgets/device_card.dart';
import 'add_device_screen.dart'; // We'll create this new screen
import '../presentation/widgets/timer_dialog.dart';
import '../presentation/widgets/timer_list_dialog.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({Key? key}) : super(key: key);

  @override
  _DeviceManagementScreenState createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view devices'));
    }

    final devicesStream = ref.watch(deviceRepositoryProvider).watchDevices(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddDevice(context, user.uid),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : StreamBuilder<List<Device>>(
        stream: devicesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading devices',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(deviceRepositoryProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: LoadingIndicator());
          }

          final devices = snapshot.data!;

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices_other, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add your first device'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(deviceRepositoryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final device = devices[index];
                return Dismissible(
                  key: Key(device.deviceId),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this device?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteDevice(ref, user.uid, device.deviceId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${device.name} deleted')),
                    );
                  },
                  child: DeviceCard(
                    device: device,
                    onFavoriteChanged: (isFavorite) {
                      _updateDevice(
                        ref,
                        user.uid,
                        device.copyWith(isFavorite: isFavorite),
                      );
                    },
                    onTap: () => _showDeviceDetails(context, device),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddDevice(BuildContext context, String userId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDeviceScreen(userId: userId),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device added successfully')),
      );
    }
  }

  void _showDeviceDetails(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Type: ${device.type}'),
              Text('Status: ${device.status}'),
              Text('Switch State: ${device.switchState}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateDevice(
                        ref,
                        FirebaseAuth.instance.currentUser!.uid,
                        device.copyWith(isOn: !device.isOn),
                      );
                    },
                    child: Text(device.isOn ? 'Turn Off' : 'Turn On'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => TimerDialog(
                          device: device,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      );
                    },
                    child: const Text('Set Timer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => TimerListDialog(
                          device: device,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      );
                    },
                    child: const Text('View Timers'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateDevice(WidgetRef ref, String userId, Device device) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(deviceRepositoryProvider).updateDevice(userId, device);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating device: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDevice(WidgetRef ref, String userId, String deviceId) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(deviceRepositoryProvider).deleteDevice(userId, deviceId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting device: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}