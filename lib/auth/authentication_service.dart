import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/models/user_model.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference _stationOwnerCollection =
  FirebaseFirestore.instance.collection('station_owner');

  Future<String?> login(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        final userSnapshot = await _userCollection.doc(user.uid).get();
        if (userSnapshot.exists) {
          return userSnapshot.get('userKind') as String?;
        }

        final stationOwnerSnapshot = await _stationOwnerCollection.doc(user.uid).get();
        if (stationOwnerSnapshot.exists) {
          return stationOwnerSnapshot.get('userKind') as String?;
        }
      }
    } catch (error) {
      print('Login Error: $error');
      throw Exception('Failed to login: $error');
    }

    return null;
  }

}
