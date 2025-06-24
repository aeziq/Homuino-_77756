import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/core/services/google_auth_service.dart';
// import 'package:homuino/core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isSystemTheme = themeMode == ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 30),

            // Account Settings
            _buildSectionTitle('Account Settings', context),
            _buildSettingItem(
              context: context,
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () => _showPersonalInfo(context),
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => _showChangePassword(context),
            ),
            const SizedBox(height: 20),

            // App Preferences
            _buildSectionTitle('App Preferences', context),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme(value);
              },
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: theme.colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('System Theme'),
              value: isSystemTheme,
              onChanged: (value) {
                if (value) {
                  ref.read(themeProvider.notifier).setSystemTheme();
                } else {
                  ref.read(themeProvider.notifier)
                      .toggleTheme(Theme.of(context).brightness == Brightness.dark);
                }
              },
              secondary: Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: Icon(
                Icons.notifications_active_outlined,
                color: theme.colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            // About
            _buildSectionTitle('About', context),
            _buildSettingItem(
              context: context,
              icon: Icons.info_outline,
              title: 'About Homuino',
              onTap: () => _showAppAboutDialog(context),
            ),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Premium Member',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showPersonalInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personal Information'),
        content: const Text(
          'This section would allow you to view or edit your personal details.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'This section would allow you to change your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Homuino',
      applicationVersion: '1.0.0',
      applicationLegalese: '©2023-2025 Homuino Inc.',
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('Simple house control at your fingertips.'),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(googleAuthServiceProvider).signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}