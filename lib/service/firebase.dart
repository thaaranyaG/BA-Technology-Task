import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// sign up function
  Future<User?> signUpUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing up: $e');
    }
    return null;
  }

  ///  login function
  Future<User?> logInUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing Im: $e');
    }
    return null;
  }
}
