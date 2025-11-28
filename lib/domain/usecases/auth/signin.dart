import 'package:dartz/dartz.dart';
import 'package:kaih_7_xirpl2/core/usecase/usecase.dart';
import 'package:kaih_7_xirpl2/data/models/auth/signinsuser.dart';
import 'package:kaih_7_xirpl2/domain/repository/auth/auth.dart';
import 'package:kaih_7_xirpl2/service_locator.dart';

class SigninUseCase implements UseCase<Either<String, String>, SigninUserReq> {
  @override
  Future<Either<String, String>> call({SigninUserReq? params}) async {
    if (params == null) {
      return const Left('Params tidak boleh kosong');
    }
    return sl<AuthRepository>().signin(params);
  }
}
