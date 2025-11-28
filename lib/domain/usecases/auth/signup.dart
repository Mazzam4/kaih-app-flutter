import 'package:dartz/dartz.dart';
import 'package:kaih_7_xirpl2/core/usecase/usecase.dart';
import 'package:kaih_7_xirpl2/data/models/auth/create_user.dart';
import 'package:kaih_7_xirpl2/domain/repository/auth/auth.dart';

class SignupUseCase implements UseCase<Either, CreateUserReq> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either> call({CreateUserReq? params}) async {
    return await repository.signup(params!);
  }
}
