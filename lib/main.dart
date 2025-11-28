import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_theme.dart';
import 'package:kaih_7_xirpl2/presentation/anggota/pages/authGate.dart';
import 'package:kaih_7_xirpl2/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:kaih_7_xirpl2/presentation/main/pages/main.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/create_organization_page.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/join_organization_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kaih_7_xirpl2/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDependencies();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          
          // PERUBAHAN UTAMA: Gunakan AuthGate sebagai halaman home
          home: const AuthGate(), 
          
          // Routes tetap berguna untuk navigasi internal seperti dari Join ke Create
          routes: {
            '/join': (context) => const JoinOrganizationPage(),
            '/create': (context) => const CreateOrganizationPage(),
            '/main': (context) => const MainPage(), // Tambahkan route untuk MainPage
          },
        ),
      ),
    );
  }
}