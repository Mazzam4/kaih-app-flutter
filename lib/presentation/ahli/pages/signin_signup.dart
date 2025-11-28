import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/appbar/appbar.dart';
import 'package:kaih_7_xirpl2/common/widgets/basic_button.dart';
import 'package:kaih_7_xirpl2/core/configs/assets/app_images.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_colors.dart';
import 'package:kaih_7_xirpl2/presentation/ahli/pages/daftar/signup.dart';
import 'package:kaih_7_xirpl2/presentation/ahli/pages/maasuk/signin.dart';


class SigninSignup extends StatelessWidget {
  const SigninSignup({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          const BasicAppbar(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SingleChildScrollView( 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppImages.logo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 55),

                    const Text(
                      'Anak Sehat disayangi Mama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 21),

                    const Text(
                      'Anak sehat, rajin, pintar, pasti disayang mama, anak jahat disayang hercules',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: BasicAppButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Signup(),
                                ),
                              );
                            },
                            title: 'Daftar',
                            color: Color(0xff4C763B),
                          ),
                        ),

                        const SizedBox(width: 20),

                        
                        Expanded(
                          flex: 1,
                          child: BasicAppButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Signin(),
                                ),
                              );
                            },
                            title: 'Masuk',
                            color: AppColors.Primary,
                          ),
                        ),

                          
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
