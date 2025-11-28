import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaih_7_xirpl2/common/widgets/primary_button.dart';
import 'package:kaih_7_xirpl2/core/configs/assets/app_images.dart';
import 'package:kaih_7_xirpl2/core/configs/assets/app_vectors.dart';
import 'package:kaih_7_xirpl2/presentation/ahli/pages/signin_signup.dart';
import 'package:kaih_7_xirpl2/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseModePage extends StatefulWidget {
  const ChooseModePage({super.key});

  @override
  State<ChooseModePage> createState() => _ChooseModePageState();
}

class _ChooseModePageState extends State<ChooseModePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [
                        Color(0xFF1E2A32),
                        Color(0xFF121A21),
                        Color(0xFF0D1318),
                      ]
                    : [
                        Color.fromARGB(255, 142, 180, 213),
                        Color(0xFF5B83A6),
                        Color(0xff37648C),
                      ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Pilih Modemu!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'siang panas, malam dingin, bijak memiilih benar dijalan',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                      ),
                    ),
                  ],
                ),


                SizedBox(
                  height: 200,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: _isDarkMode
                        ? Image.asset(

                            AppImages.moon, 
                            key: ValueKey('dark'),
                            width: 150,
                            height: 150,
                          )
                        : Image.asset(

                            AppImages.sun,
                            key: ValueKey('light'),
                            width: 150,
                            height: 250,
                          ),
                  ),
                ),


                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        _buildModeButton(
                          context: context,
                          isSelected: !_isDarkMode,
                          label: 'Light',
                          onTap: () {
                            setState(() {
                              _isDarkMode = false;
                            });
                            context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                          },
                          isLight: true,
                        ),
                        SizedBox(width: 20),

                        _buildModeButton(
                          context: context,
                          isSelected: _isDarkMode,
                          label: 'Dark',
                          onTap: () {
                            setState(() {
                              _isDarkMode = true;
                            });
                            context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                          },
                          isLight: false,
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    PrimaryButton(
                    text: "Lanjut",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SigninSignup(),
                        ),
                      );
                    },
                  ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
    required bool isLight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff30393C).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      isLight ? AppVectors.sun : AppVectors.moon,
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}