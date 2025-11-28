import 'package:dartz/dartz.dart';
import 'package:kaih_7_xirpl2/data/models/auth/create_user.dart';
import 'package:kaih_7_xirpl2/data/models/auth/signinsuser.dart';
import 'package:kaih_7_xirpl2/data/sources/auth/auth_firebase_service.dart';
import 'package:kaih_7_xirpl2/domain/entities/auth/user.dart';
import 'package:kaih_7_xirpl2/domain/repository/auth/auth.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthFirebaseService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<Either<String, String>> signup(CreateUserReq createUserReq) {
    return _service.signup(createUserReq);
  }
  @override
    Future<Either<String, String>> signin(SigninUserReq signinUserReq) {
      return _service.signin(signinUserReq);
  }


  @override
  Future<Either<String, UserEntity>> getUser() {
    return _service.getUser();
  }
}