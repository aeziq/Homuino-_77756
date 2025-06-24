import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:homuino/core/theme/app_theme.dart';
import 'package:homuino/features/auth/presentation/auth_screen.dart';
import 'package:homuino/features/home/presentation/home_screen.dart';
import 'package:homuino/routes.dart';
import 'features/auth/application/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    print('Auth state updated: ${authState.value}');

    return MaterialApp(
      title: 'Homuino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) {
          print('User state: a$user');
          return user != null ? HomeScreen(user: user) : const AuthScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      ),
      onGenerateRoute: (settings) => Routes.generateRoute(settings),
    );
  }
}