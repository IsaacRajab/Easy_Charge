import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserDataRepository {
  static const String collectionPath =
      'users'; // Replace with your collection path in Firestore
  final CollectionReference _stationOwnerCollection =
  FirebaseFirestore.instance.collection('station_owner');
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addUser(UserDataModel userData) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users');
      await userRef.doc(userData.uId).set(userData.toJson());
    } catch (error) {
      throw Exception('Failed to add user: $error');
    }
  }
  Future<void> addStationOwner(UserDataModel userData) async {
    try {
      await _stationOwnerCollection.doc(userData.uId).set(userData.toJson());
    } catch (error) {
      throw Exception('Failed to add station owner: $error');
    }
  }

  Future<UserDataModel?> getUserByEmail(String email) async {
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection(collectionPath)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return UserDataModel.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>?);
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Failed to get user: $e');
      rethrow;
    }
    return null; // Return null if user not found or any errors occur
  }
}
