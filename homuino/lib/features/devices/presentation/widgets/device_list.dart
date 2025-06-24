import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homuino/core/loading_indicator.dart';
import 'package:homuino/features/devices/data/device_repository.dart';
import 'package:homuino/features/devices/domain/device.dart';
import 'package:homuino/features/devices/presentation/widgets/device_card.dart';

class DeviceList extends ConsumerWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Please log in to view devices',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final devicesStream = ref.watch(deviceRepositoryProvider).watchDevices(user.uid);

    return StreamBuilder<List<Device>>(
      stream: devicesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingIndicator(
              size: 32,
              message: 'Loading your devices...',
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error, () {
            ref.refresh(deviceRepositoryProvider);
          });
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildDeviceList(context, ref, user.uid, snapshot.data!);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object? error, VoidCallback onRetry) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          Text(
            'Add your first device to get started',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, WidgetRef ref, String userId, List<Device> devices) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(deviceRepositoryProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final device = devices[index];
          return DeviceCard(
            device: device,
            onTap: () => _navigateToDeviceDetails(context, device),
            onFavoriteChanged: (isFavorite) {
              ref.read(deviceRepositoryProvider).updateDevice(
                userId,
                device.copyWith(isFavorite: isFavorite),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDeviceDetails(BuildContext context, Device device) {
    Navigator.of(context).pushNamed(
      '/device-details',
      arguments: device,
    );
  }
}