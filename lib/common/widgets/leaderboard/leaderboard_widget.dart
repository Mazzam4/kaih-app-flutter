import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaih_7_xirpl2/core/configs/habit/habit_config.dart';
import 'package:kaih_7_xirpl2/core/models/leaderboard_entry_model.dart';

class LeaderboardWidget extends StatelessWidget {
  final Stream<List<LeaderboardEntry>> dataStream;

  const LeaderboardWidget({super.key, required this.dataStream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 450, 
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: StreamBuilder<List<LeaderboardEntry>>(
        stream: dataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(theme, isDark);
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString(), theme, isDark);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(theme, isDark);
          }

          final leaderboardData = snapshot.data!;

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Text('Peringkat Teratas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const BouncingScrollPhysics(), // Scroll terasa lebih natural
                  child: DataTable(
                    columns: _buildColumns(theme, isDark),
                    rows: _buildRows(leaderboardData, theme, isDark),
                    columnSpacing: 28,
                    horizontalMargin: 8,
                    headingRowHeight: 56,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                    dataTextStyle: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
                    headingRowColor: WidgetStateProperty.all(isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
                    border: TableBorder(horizontalInside: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PERBAIKAN BUG: Teks ini diubah agar tidak membingungkan.
                    // Sekarang menampilkan jumlah peringkat yang ditampilkan, bukan total anggota.
                    Text(
                      'Menampilkan ${leaderboardData.length} peringkat teratas',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      'Update: ${DateFormat('HH:mm').format(DateTime.now())}',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DataColumn> _buildColumns(ThemeData theme, bool isDark) {
    return [
      const DataColumn(label: Center(child: Text('Rank'))),
      const DataColumn(label: Text('Nama Anggota')),
      ...HabitConfig.sevenHabits.map((habit) => DataColumn(
        label: Center(child: Text(habit.name.split(' ').first, textAlign: TextAlign.center)),
        numeric: true,
      )),
      const DataColumn(label: Center(child: Text('Total')), numeric: true),
    ];
  }

  List<DataRow> _buildRows(List<LeaderboardEntry> data, ThemeData theme, bool isDark) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final userEntry = entry.value;
      final isTopThree = index < 3;

      return DataRow(
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          if (isTopThree) return _getRankColor(index, isDark).withOpacity(0.1);
          return null; 
        }),
        cells: [
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isTopThree) Icon(_getRankIcon(index), color: _getRankColor(index, isDark), size: 18),
                if (isTopThree) const SizedBox(width: 8),
                Text((index + 1).toString(), style: TextStyle(fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          DataCell(
            Text(userEntry.userName, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)
          ),
          ...HabitConfig.sevenHabits.map((habit) {
            final count = userEntry.habitCounts[habit.name] ?? 0;
            return DataCell(
              Center(child: Text(count.toString())),
            );
          }),
          DataCell(
            Center(child: Text(userEntry.totalSubmissions.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor))),
          ),
        ],
      );
    }).toList();
  }

  // Helper methods untuk styling
  IconData _getRankIcon(int index) {
    if (index == 0) return Icons.emoji_events;
    if (index == 1) return Icons.workspace_premium;
    return Icons.military_tech;
  }

  Color _getRankColor(int index, bool isDark) {
    if (index == 0) return const Color(0xFFFFD700); // Emas
    if (index == 1) return const Color(0xFFC0C0C0); // Perak
    return const Color(0xFFCD7F32); // Perunggu
  }

  // Widget untuk state loading, error, dan kosong
  Widget _buildLoadingState(ThemeData theme, bool isDark) => const Center(child: CircularProgressIndicator());
  Widget _buildErrorState(String error, ThemeData theme, bool isDark) => Center(child: Text('Error: $error'));
  Widget _buildEmptyState(ThemeData theme, bool isDark) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('Belum Ada Data Leaderboard'),
      ],
    ),
  );
}