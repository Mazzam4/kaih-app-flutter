import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/core/configs/habit/habit_config.dart';
import 'package:kaih_7_xirpl2/core/models/leaderboard_entry_model.dart';

class MemberDataTable extends StatelessWidget {
  final List<LeaderboardEntry> data;

  const MemberDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView( // Hanya butuh scroll horizontal
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          columns: _buildColumns(theme, isDark),
          rows: _buildRows(data, theme, isDark, currentUserId),
          columnSpacing: 28,
          horizontalMargin: 8,
          headingRowHeight: 56,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 56,
          headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[700]),
          headingRowColor: WidgetStateProperty.all(isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
          border: TableBorder(horizontalInside: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        ),
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

  List<DataRow> _buildRows(List<LeaderboardEntry> data, ThemeData theme, bool isDark, String? currentUserId) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final userEntry = entry.value;
      final isCurrentUser = userEntry.userId == currentUserId;

      return DataRow(
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          if (isCurrentUser) return theme.primaryColor.withOpacity(0.15);
          return null; 
        }),
        cells: [
          DataCell(Center(child: Text((index + 1).toString()))),
          DataCell(
            Text(
              userEntry.userName,
              style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600), 
              overflow: TextOverflow.ellipsis,
            )
          ),
          ...HabitConfig.sevenHabits.map((habit) {
            final count = userEntry.habitCounts[habit.name] ?? 0;
            return DataCell(Center(child: Text(count.toString())));
          }),
          DataCell(
            Center(child: Text(userEntry.totalSubmissions.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      );
    }).toList();
  }
}