// File: lib/common/widgets/habitcard/habit_confirmation_popup.dart

import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';

class HabitConfirmationPopup extends StatefulWidget {
  final String habitName;
  final String habitDescription;
  final String organizationId;
  final bool isMultiEntry;

  const HabitConfirmationPopup({
    super.key,
    required this.habitName,
    required this.habitDescription,
    required this.organizationId,
    required this.isMultiEntry,
  });

  @override
  State<HabitConfirmationPopup> createState() => _HabitConfirmationPopupState();
}

class _HabitConfirmationPopupState extends State<HabitConfirmationPopup> {
  final HabitUseCase _habitUseCase = HabitUseCase();
  bool _isUploading = false;
  late final TimeOfDay _submissionTime;

  @override
  void initState() {
    super.initState();
    _submissionTime = TimeOfDay.now();
  }

  Future<void> _submitData() async {
    setState(() => _isUploading = true);

    final result = await _habitUseCase.submitHabitEntryWithTimeCheck(
      habitName: widget.habitName,
      description: "Aktivitas dicatat pada ${_submissionTime.format(context)}", // Deskripsi otomatis
      organizationId: widget.organizationId,
      pickedImage: null, // Tidak ada gambar
      submissionTime: _submissionTime,
      isMultiEntry: widget.isMultiEntry,
    );

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktivitas berhasil dicatat!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(widget.habitName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.habitDescription, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            // Tampilan Waktu
            _buildTimeDisplay(context),
            const SizedBox(height: 24),
            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitData,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waktu Dicatat', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_submissionTime.format(context), style: theme.textTheme.bodyLarge),
              Icon(Icons.access_time_filled, color: theme.primaryColor.withOpacity(0.7)),
            ],
          ),
        ),
      ],
    );
  }
}