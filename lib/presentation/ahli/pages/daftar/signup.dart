import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/appbar/appbar.dart';
import 'package:kaih_7_xirpl2/common/widgets/basic_button.dart';
import 'package:kaih_7_xirpl2/data/models/auth/create_user.dart';
import 'package:kaih_7_xirpl2/domain/usecases/auth/signup.dart';
import 'package:kaih_7_xirpl2/presentation/ahli/pages/maasuk/signin.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/org_selection_page.dart';
import 'package:kaih_7_xirpl2/service_locator.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signinText(context),
      appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _fullNameField(context),
            const SizedBox(height: 20),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 30),
            BasicAppButton(
              title: 'Buat Akun',
              color: const Color(0xff4C763B),
              onPressed: () async {

                if (_fullName.text.isEmpty ||
                    _email.text.isEmpty ||
                    _password.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua field harus diisi"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }


                var result = await sl<SignupUseCase>().call(
                  params: CreateUserReq(
                    fullName: _fullName.text.trim(),
                    email: _email.text.trim(),
                    password: _password.text.trim(),
                  ),
                );

 
                result.fold(
                  (l) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  (r) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pendaftaran berhasil!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Tunggu sebentar biar SnackBar muncul
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const OrgSelectionPage(),
                        ),
                        (route) => false,
                      );
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Daftar',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(hintText: 'Nama Lengkap')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Masukkan Email')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      decoration: const InputDecoration(hintText: 'Password')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Apakah Kamu Punya Akun? ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Signin()),
              );
            },
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }
}
