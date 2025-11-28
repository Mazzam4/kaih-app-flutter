import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/data/sources/auth/auth_firebase_service.dart';
import 'package:kaih_7_xirpl2/domain/entities/auth/user.dart';

class UserProvider with ChangeNotifier {
  final AuthFirebaseService _authService = AuthFirebaseServiceImpl();
  UserEntity? _user;

  UserEntity? get user => _user;

  Future<void> fetchUser() async {
    final result = await _authService.getUser();
    result.fold(
      (error) => debugPrint('Error fetching user: $error'),
      (userData) {
        _user = userData;
        notifyListeners();
      },
    );
  }
}
