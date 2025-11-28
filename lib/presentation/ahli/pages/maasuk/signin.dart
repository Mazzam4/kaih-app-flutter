import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/appbar/appbar.dart';
import 'package:kaih_7_xirpl2/common/widgets/basic_button.dart';
import 'package:kaih_7_xirpl2/data/models/auth/signinsuser.dart';
import 'package:kaih_7_xirpl2/domain/usecases/auth/signin.dart';
import 'package:kaih_7_xirpl2/presentation/ahli/pages/daftar/signup.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/org_selection_page.dart';
import 'package:kaih_7_xirpl2/service_locator.dart';

class Signin extends StatelessWidget {
  Signin({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            const SizedBox(height: 50),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () async {
                var result = await sl<SigninUseCase>().call(
                  params: SigninUserReq(
                    email: _email.text.trim(),
                    password: _password.text.trim(),
                  ),
                );

                result.fold(
                  (l) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l), behavior: SnackBarBehavior.floating),
                    );
                  },
                  (r) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OrgSelectionPage()),
                    );
                  },
                );
              },
              title: 'Masuk',
              color: const Color(0xff4C763B),
            ),
                      ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Masuk',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Masukkan Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Masukkan Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Signup()),
              );
            },
            child: const Text('Buat Sekarang'),
          )
        ],
      ),
    );
  }
}
