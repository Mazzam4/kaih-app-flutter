
import 'package:dartz/dartz.dart';
import 'package:kaih_7_xirpl2/data/models/auth/create_user.dart';
import 'package:kaih_7_xirpl2/data/models/auth/signinsuser.dart';
import 'package:kaih_7_xirpl2/domain/entities/auth/user.dart';

abstract class AuthRepository {
  Future<Either<String, String>> signup(CreateUserReq createUserReq);
  Future<Either<String, String>> signin(SigninUserReq signinUserReq);
  Future<Either<String, UserEntity>> getUser();
}
