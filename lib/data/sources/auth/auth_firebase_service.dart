import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaih_7_xirpl2/data/models/auth/create_user.dart';
import 'package:kaih_7_xirpl2/data/models/auth/signinsuser.dart';
import 'package:kaih_7_xirpl2/data/models/auth/user.dart';
import 'package:kaih_7_xirpl2/domain/entities/auth/user.dart';

abstract class AuthFirebaseService {
  Future<Either<String, String>> signup(CreateUserReq createUserReq);
  Future<Either<String, String>> signin(SigninUserReq signinUserReq);
  Future<Either<String, UserEntity>> getUser();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either<String, String>> signin(SigninUserReq signinUserReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email,
        password: signinUserReq.password,
      );
      return const Right('Login berhasil!');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Pengguna dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        message = 'Password yang Anda masukkan salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else {
        message = 'Login gagal: ${e.message}';
      }
      return Left(message);
    }
  }

  @override
  Future<Either<String, String>> signup(CreateUserReq createUserReq) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateProfile(displayName: createUserReq.fullName);

        await user.sendEmailVerification();
      }

      await FirebaseFirestore.instance
          .collection('users') 
          .doc(userCredential.user?.uid)
          .set({
        'name': createUserReq.fullName,
        'email': userCredential.user?.email,
        'uid': userCredential.user?.uid, 
        'createdAt': FieldValue.serverTimestamp(), 
      });

      return const Right('Pendaftaran berhasil! Silakan periksa email Anda untuk verifikasi.');
      
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah, harap gunakan minimal 6 karakter.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Akun dengan alamat email ini sudah terdaftar.';
      } else {
        message = 'Pendaftaran gagal: ${e.message}';
      }
      return Left(message);
    } catch(e) {
      return Left('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      if (firebaseAuth.currentUser == null) {
        return const Left('Tidak ada pengguna yang sedang login.');
      }

      var userDoc = await firebaseFirestore
          .collection('users') // Pastikan ini juga menggunakan 'users' (huruf kecil)
          .doc(firebaseAuth.currentUser?.uid)
          .get();
      
      if (userDoc.exists && userDoc.data() != null) {
        UserModel userModel = UserModel.fromJson(userDoc.data()!);
        UserEntity userEntity = userModel.toEntity();
        return Right(userEntity);
      } else {
        return const Left('Dokumen pengguna tidak ditemukan di database.');
      }

    } catch (e) {
      return Left('Terjadi kesalahan saat mengambil data pengguna: ${e.toString()}');
    }
  }
}