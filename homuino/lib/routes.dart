import 'package:flutter/material.dart';
import 'package:homuino/features/auth/presentation/auth_screen.dart';
import 'package:homuino/features/devices/presentation/device_management_screen.dart';
import 'package:homuino/features/home/presentation/home_screen.dart';
import 'package:homuino/features/profile/presentation/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/home':
        final user = settings.arguments as User?;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(user: user!),
        );
      case '/devices':
        return MaterialPageRoute(builder: (_) => const DeviceManagementScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const AuthScreen(),
      '/home': (context) {
        final user = ModalRoute.of(context)!.settings.arguments as User;
        return HomeScreen(user: user);
      },
      '/devices': (context) => const DeviceManagementScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }
}