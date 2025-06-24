import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homuino/core/services/firebase_service.dart';
import 'package:homuino/core/services/google_auth_service.dart';
import 'package:homuino/core/errors/exceptions.dart';

final authControllerProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges()
    ..listen((user) {
      if (user != null) {
        print('User authenticated: ${user.uid}');
      } else {
        print('No user authenticated');
      }
    });
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await ref.read(firebaseServiceProvider)
          .createUserWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await ref.read(firebaseServiceProvider)
          .signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      return await ref.read(googleAuthServiceProvider).signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signOut() async {
    await ref.read(firebaseServiceProvider).signOut();
  }
}

final authControllerInstanceProvider = Provider((ref) {
  return AuthController(ref);
});