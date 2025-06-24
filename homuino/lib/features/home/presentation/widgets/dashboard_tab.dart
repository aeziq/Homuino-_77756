// dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/features/auth/application/auth_controller.dart';
import 'package:homuino/features/devices/data/device_repository.dart';
import 'package:homuino/features/devices/domain/device.dart';
import 'package:homuino/features/devices/presentation/widgets/device_card.dart';
import 'package:homuino/core/theme/app_theme.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    if (user == null) {
      return const Center(child: Text('Please log in to view dashboard'));
    }

    final devicesStream = ref.watch(deviceRepositoryProvider).watchDevices(user.uid);

    return StreamBuilder<List<Device>>(
      stream: devicesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final devices = snapshot.data!;
        final favoriteDevices = devices.where((device) => device.isFavorite).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Your Smart Home',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Quick Actions
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildQuickActionCard(context, index, ref, user.uid, devices, favoriteDevices),
                  childCount: 5, // Updated to 5 actions
                ),
              ),
            ),
            // Favorite Devices
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favorite Devices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Devices List
            if (favoriteDevices.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No favorite devices yet. Add some from your devices list!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceCard(
                        device: favoriteDevices[index],
                        onTap: () => _controlDevice(context, favoriteDevices[index]),
                        onFavoriteChanged: (isFavorite) =>
                            _toggleFavorite(ref, user.uid, favoriteDevices[index], isFavorite),
                      ),
                    ),
                    childCount: favoriteDevices.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(BuildContext context, int index, WidgetRef ref, String userId,
      List<Device> devices, List<Device> favoriteDevices) {
    final actions = [
      {
        'icon': Icons.power_settings_new,
        'label': 'All On',
        'color': AppTheme.successColor,
        'onTap': () => _controlAllDevices(ref, userId, devices, true),
      },
      {
        'icon': Icons.power_off,
        'label': 'All Off',
        'color': AppTheme.errorColor,
        'onTap': () => _controlAllDevices(ref, userId, devices, false),
      },
      {
        'icon': Icons.favorite,
        'label': 'Favorites On',
        'color': AppTheme.successColor,
        'onTap': () => _controlAllDevices(ref, userId, favoriteDevices, true),
      },
      {
        'icon': Icons.favorite_border,
        'label': 'Favorites Off',
        'color': AppTheme.errorColor,
        'onTap': () => _controlAllDevices(ref, userId, favoriteDevices, false),
      },
      {
        'icon': Icons.add,
        'label': 'Add Device',
        'color': AppTheme.primary,
        'onTap': () => _navigateToDeviceManagement(context),
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: actions[index]['onTap'] as VoidCallback,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: actions[index]['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  actions[index]['icon'] as IconData,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                actions[index]['label'] as String,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _controlDevice(BuildContext context, Device device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Controlling ${device.name}')),
    );
  }

  void _toggleFavorite(WidgetRef ref, String userId, Device device, bool isFavorite) {
    ref.read(deviceRepositoryProvider).updateDevice(
      userId,
      device.copyWith(isFavorite: isFavorite),
    );
  }

  void _controlAllDevices(WidgetRef ref, String userId, List<Device> devices, bool turnOn) {
    for (final device in devices) {
      ref.read(deviceRepositoryProvider).updateDevice(
        userId,
        device.copyWith(isOn: turnOn),
      );
    }
  }

  void _navigateToDeviceManagement(BuildContext context) {
    Navigator.of(context).pushNamed('/devices');
  }
}