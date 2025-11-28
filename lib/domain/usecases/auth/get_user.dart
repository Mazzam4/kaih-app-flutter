
import 'package:dartz/dartz.dart';
import 'package:kaih_7_xirpl2/core/usecase/usecase.dart';
import 'package:kaih_7_xirpl2/domain/repository/auth/auth.dart';
import 'package:kaih_7_xirpl2/service_locator.dart';

class GetUserUseCase implements UseCase<Either,dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<AuthRepository>().getUser();
  }

}