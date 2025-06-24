import 'package:flutter/material.dart';
import '../../domain/device.dart';
import '../../data/device_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/core/theme/app_theme.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteChanged;

  const DeviceCard({
    Key? key,
    required this.device,
    this.onTap,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Device Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getDeviceColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getDeviceIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.type} • ${device.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Status Indicator and Controls
              Column(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: device.status == 'ONLINE'
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (device.timers != null && device.timers!.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      device.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: device.isFavorite ? Colors.red : Theme.of(context).disabledColor,
                    ),
                    onPressed: () {
                      if (onFavoriteChanged != null) {
                        onFavoriteChanged!(!device.isFavorite);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Power button
                  IconButton(
                    icon: Icon(
                      device.isOn ? Icons.power_settings_new : Icons.power_off,
                      color: device.isOn
                          ? AppTheme.successColor
                          : Theme.of(context).disabledColor,
                    ),
                    onPressed: () => onTap?.call(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.type.toLowerCase()) {
      case 'light':
        return Icons.lightbulb_outline;
      case 'thermostat':
        return Icons.thermostat;
      case 'sensor':
        return Icons.sensors;
      default:
        return Icons.device_hub;
    }
  }

  Color _getDeviceColor(BuildContext context) {
    switch (device.type.toLowerCase()) {
      case 'light':
        return AppTheme.accent;
      case 'thermostat':
        return AppTheme.warningColor;
      case 'sensor':
        return AppTheme.infoColor;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}