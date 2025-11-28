import 'package:get_it/get_it.dart';
import 'package:kaih_7_xirpl2/data/repository/auth/auth_repo_imp.dart';
import 'package:kaih_7_xirpl2/data/sources/auth/auth_firebase_service.dart';
import 'package:kaih_7_xirpl2/domain/repository/auth/auth.dart';
import 'package:kaih_7_xirpl2/domain/usecases/auth/signin.dart';
import 'package:kaih_7_xirpl2/domain/usecases/auth/signup.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());


  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthFirebaseService>()),
  );

  sl.registerSingleton<SignupUseCase>(
    SignupUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<SigninUseCase>(
  SigninUseCase(),
);

}
