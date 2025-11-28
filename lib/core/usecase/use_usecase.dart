import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaih_7_xirpl2/core/models/member_profile_model.dart' ;

class UserUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null; 
    }

    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        return null; 
      }

      final userData = userDoc.data()!;
      final organizationId = userData['organizationId'] as String?;
      String organizationName = 'Tanpa Organisasi';


      if (organizationId != null) {
        final orgDoc = await _firestore.collection('organizations').doc(organizationId).get();
        if (orgDoc.exists) {
          organizationName = orgDoc.data()!['name'] as String;
        }
      }


      return UserModel(
        uid: firebaseUser.uid,
        name: userData['name'] ?? firebaseUser.displayName ?? 'Tanpa Nama',
        email: firebaseUser.email ?? '',
        photoUrl: userData['photoUrl'] ?? firebaseUser.photoURL,
        role: userData['role'] ?? 'member',
        organizationName: organizationName,
      );

    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }
}