import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/core/models/habit_models.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final UserHabitStatus? status;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = status?.isCompletedToday ?? false;

    final bool isCardDisabled = isCompleted && !habit.isMultiEntry;

    return InkWell(
      // Gunakan variabel isCardDisabled sebagai satu-satunya sumber kebenaran
      onTap: isCardDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: theme.primaryColor.withOpacity(0.2),
      child: Container(
        width: 160,
        height: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          // Buat kartu menjadi abu-abu hanya jika nonaktif
          color: isCardDisabled ? Colors.grey.withOpacity(0.7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                habit.iconPath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon centang akan muncul jika sudah ada minimal 1 entri
                  if (isCompleted)
                    Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.9), size: 28),
                  
                  if (isCompleted) const SizedBox(height: 8),

                  Text(
                    habit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tombol 'Pilih' hanya akan tampil jika kartu TIDAK nonaktif
                  if (!isCardDisabled)
                    Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Pilih',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}