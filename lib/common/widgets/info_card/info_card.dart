import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final bool showProgress; // NEW: Untuk menampilkan progress bar
  final double progressValue; // NEW: Nilai progress (0.0 - 1.0)

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = const Color.fromARGB(255, 222, 222, 222),
    this.textColor = const Color.fromARGB(255, 227, 227, 227),
    this.showProgress = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.9),
            backgroundColor.withOpacity(0.7),
            backgroundColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon dan title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              // Optional: Add more actions here if needed
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main Value - lebih prominent
          Text(
            value,
            style: TextStyle(
              fontSize: _getValueFontSize(value),
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 0.9,
              letterSpacing: -1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Subtitle dengan progress bar (jika ada)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              if (showProgress) ...[
                const SizedBox(height: 8),
                // Progress Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Progress
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        height: 4,
                        width: MediaQuery.of(context).size.width * 0.3 * progressValue,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              textColor.withOpacity(0.8),
                              textColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Helper function untuk menentukan font size berdasarkan panjang value
  double _getValueFontSize(String value) {
    if (value.length <= 3) return 36.0;
    if (value.length <= 5) return 28.0;
    if (value.length <= 7) return 24.0;
    return 20.0;
  }
}