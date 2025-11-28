import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';

class DailyContributionChart extends StatelessWidget {
  final Stream<List<DailyContribution>> dataStream;

  const DailyContributionChart({super.key, required this.dataStream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<DailyContribution>>(
      stream: dataStream,
      builder: (context, snapshot) {
        // =================== STATE: LOADING ===================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(
            context,
            isDark,
            theme,
            icon: Icons.hourglass_bottom,
            text: "Memuat data...",
          );
        }

        // =================== STATE: ERROR ===================
        if (snapshot.hasError) {
          return _buildPlaceholder(
            context,
            isDark,
            theme,
            icon: Icons.error_outline,
            text: "Terjadi kesalahan. Silakan coba lagi.",
          );
        }

        // =================== STATE: EMPTY ===================
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildPlaceholder(
            context,
            isDark,
            theme,
            icon: Icons.bar_chart_rounded,
            text: "Belum ada data kontribusi",
            subText: "Mulai kebiasaan baik untuk melihat grafik",
          );
        }

        // =================== STATE: DATA READY ===================
        final chartData = snapshot.data!;
        final maxY = chartData.map((d) => d.count).reduce((a, b) => a > b ? a : b).toDouble();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 HEADER
              Row(
                children: [
                  Icon(Icons.insights_rounded, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Statistik Harian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Progress kebiasaan baik dalam 7 hari terakhir',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 CHART
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: 200,
                    width: constraints.maxWidth,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY == 0 ? 5 : maxY * 1.2,
                        minY: 0,
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: false),

                        // Border
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),

                        // Grid
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY == 0 ? 1 : (maxY / 4).ceilToDouble(),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),

                        // Titles (Axis)
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: maxY == 0 ? 1 : (maxY / 4).ceilToDouble(),
                              getTitlesWidget: (value, meta) {
                                if (value == meta.min || value >= meta.max) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= chartData.length) return const SizedBox.shrink();
                                final date = chartData[index].date;
                                return FittedBox( // 🔹 Mencegah overflow
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('d').format(date),
                                        style: TextStyle(
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('EEE').format(date),
                                        style: TextStyle(
                                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Data batang
                        barGroups: List.generate(chartData.length, (index) {
                          final data = chartData[index];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data.count.toDouble(),
                                color: theme.primaryColor,
                                gradient: _createGradient(theme.primaryColor),
                                width: 18,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY == 0 ? 5 : maxY * 1.2,
                                  color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 400), // 🔹 smooth
                      swapAnimationCurve: Curves.easeOutCubic,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 🔹 LEGEND
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: _createGradient(theme.primaryColor),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jumlah Kebiasaan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Placeholder Widget Reusable
  Widget _buildPlaceholder(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required IconData icon,
    required String text,
    String? subText,
  }) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subText != null) ...[
              const SizedBox(height: 4),
              Text(
                subText,
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }

  /// 🔹 Gradient batang
  LinearGradient _createGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.9),
        baseColor,
      ],
    );
  }
}
