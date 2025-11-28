import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaih_7_xirpl2/core/configs/appConfig/app_config.dart';

class OrganizationUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createOrganization({required String orgName}) async {
    final user = _auth.currentUser;

    if (user == null) {
      return "Sesi Anda telah berakhir. Silakan login kembali.";
    }
    if (user.email != AppConfig.adminEmail) {
      return 'Otorisasi gagal: Hanya admin yang dapat membuat organisasi.';
    }
    if (!user.emailVerified) {
      return 'Email Anda belum diverifikasi! Silakan verifikasi terlebih dahulu.';
    }
    if (orgName.trim().isEmpty) {
      return 'Nama organisasi tidak boleh kosong.';
    }

    try {
      final orgRef = await _firestore.collection('organizations').add({
        'name': orgName.trim(),
        'ownerId': user.uid,
        'createdAt': Timestamp.now(),
      });

      final userName = user.displayName ?? user.email?.split('@')[0] ?? 'Pengguna Baru';

      await _firestore.collection('users').doc(user.uid).set({
          'organizationId': orgRef.id,
          'role': 'admin',
          'name': userName,
          'email': user.email,
          'photoUrl': user.photoURL
        }, SetOptions(merge: true));
        
        return null; 
      } catch (e) {
        return 'Terjadi kesalahan saat membuat organisasi: $e';
    }
  }


  Future<String?> sendEmailVerification() async {
    final user = _auth.currentUser;
    
    if (user == null) {
      return "Sesi Anda telah berakhir. Silakan login kembali.";
    }
    
    if (user.emailVerified) {
      return "Email Anda sudah terverifikasi.";
    }

    try {
      await user.sendEmailVerification();
      return null; 
    } on FirebaseAuthException catch (e) {
      return "Gagal mengirim email verifikasi: ${e.message}";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }


  Future<bool> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}