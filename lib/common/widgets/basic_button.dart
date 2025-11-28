import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final Color? color; 

  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor, 
        foregroundColor: AppColors.thirdColor, 
        minimumSize: Size.fromHeight(height ?? 80),
      ),
      child: Text(title),
    );
  }
}
