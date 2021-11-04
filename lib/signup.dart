import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class Signup extends StatelessWidget {
  late Function _fetchData;
  late Function _setUser;
  User? _user;

  Signup(Function fetchData, Function setUser, User? user) {
    _fetchData = fetchData;
    _setUser = setUser;
    _user = user;
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  createUser(UserCredential userCredential) async {
    final uid = userCredential.user?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'email': userCredential.user?.email}, SetOptions(merge: true));
      await _fetchData();
    }
    _setUser(userCredential.user);
  }

  signIn() async {
    if ((defaultTargetPlatform == TargetPlatform.iOS) ||
        (defaultTargetPlatform == TargetPlatform.android)) {
      // Android / ios
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await createUser(result);
    } else {
      // Web
      UserCredential result = await signInWithGoogle();
      await createUser(result);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _setUser(null);
  }

  TextButton getTextButton() {
    if (_user == null) {
      return TextButton(
          onPressed: () => {signIn()}, child: const Text("Login with google"));
    }
    return TextButton(
        onPressed: () => {signOut()}, child: const Text("Logout"));
  }

  @override
  Widget build(BuildContext context) {
    return getTextButton();
  }
}
