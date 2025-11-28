import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/basic_button.dart';
import 'package:kaih_7_xirpl2/core/configs/assets/app_images.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_colors.dart';
import 'package:kaih_7_xirpl2/presentation/choose_mode/pages/choose_mode.dart';

  class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          double fontSize = screenWidth * 0.015;
          if (fontSize < 14) fontSize = 14;

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 142, 180, 213),
                      Color(0xFF5B83A6),
                      Color(0xff37648C),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: screenWidth * 0.25,   
                bottom: screenHeight * 0.00, 
                child: Image.asset(
                  AppImages.sunfloower,
                  width: 650,  
                ),
              ),
            Align(
              alignment: const Alignment(0, -0.7), // 🔹 agak ke atas dari tengah
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '7 Kebiasaan Anak Hebat!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          color: AppColors.primarySecond,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tujuh Kebiasaan Anak Indonesia Hebat adalah program yang diluncurkan oleh Kemendikbudristek untuk memperkuat pendidikan karakter sejak dini. Kebiasaan-kebiasaan ini dirancang untuk membentuk pribadi anak yang sehat, cerdas, dan berkarakter mulia.',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: AppColors.thirdColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 100),
                      BasicAppButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>const ChooseModePage()
                          )
                          );
                        },
                        title: 'Mulai Sekarang',
                        color: const Color.fromARGB(255, 159, 195, 74),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

