import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homuino/core/errors/exceptions.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(
    FirebaseAuth.instance,
    GoogleSignIn(),
  );
});

class GoogleAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService(this._auth, this._googleSignIn);

  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled');
        throw AuthException.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Sign-in successful: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Google Sign-In error: ${e.message}');
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}