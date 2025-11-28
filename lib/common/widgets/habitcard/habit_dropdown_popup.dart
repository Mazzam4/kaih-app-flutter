// File: lib/common/widgets/habitcard/habit_dropdown_popup.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';

class HabitDropdownPopup extends StatefulWidget {
  final String habitName;
  final String habitDescription;
  final String organizationId;
  final bool isMultiEntry;
  final List<String> dropdownItems;
  final bool showTextFieldOnLainnya;

  const HabitDropdownPopup({
    super.key,
    required this.habitName,
    required this.habitDescription,
    required this.organizationId,
    required this.isMultiEntry,
    required this.dropdownItems,
    this.showTextFieldOnLainnya = false,
  });

  @override
  State<HabitDropdownPopup> createState() => _HabitDropdownPopupState();
}

class _HabitDropdownPopupState extends State<HabitDropdownPopup> {
  final HabitUseCase _habitUseCase = HabitUseCase();
  bool _isUploading = false;
  late final TimeOfDay _submissionTime;
  
  String? _selectedDropdownValue;
  final TextEditingController _lainnyaController = TextEditingController();
  
  XFile? _pickedImage;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _submissionTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _lainnyaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() { _pickedImage = picked; });
      if (kIsWeb) {
        _imageBytes = await picked.readAsBytes();
        setState(() {});
      }
    }
  }

  Future<void> _submitData() async {
    // Validasi Input
    if (_selectedDropdownValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih salah satu kategori.')));
      return;
    }
    if (widget.showTextFieldOnLainnya && _selectedDropdownValue == 'Lainnya' && _lainnyaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi keterangan untuk opsi "Lainnya".')));
      return;
    }

    setState(() => _isUploading = true);

    // Gabungkan deskripsi dari dropdown dan text field
    String finalDescription = _selectedDropdownValue!;
    if (widget.showTextFieldOnLainnya && _selectedDropdownValue == 'Lainnya') {
      finalDescription = _lainnyaController.text.trim();
    }

    final result = await _habitUseCase.submitHabitEntryWithTimeCheck(
      habitName: widget.habitName,
      description: finalDescription,
      organizationId: widget.organizationId,
      pickedImage: _pickedImage,
      submissionTime: _submissionTime,
      isMultiEntry: widget.isMultiEntry,
    );
    
    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aktivitas berhasil dicatat!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
      setState(() => _isUploading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage == null) return const SizedBox.shrink();
    if (kIsWeb) {
      if (_imageBytes != null) {
        return Image.memory(_imageBytes!, height: 150, width: double.infinity, fit: BoxFit.cover);
      }
      return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
    } else {
      return Image.file(File(_pickedImage!.path), height: 150, width: double.infinity, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER (DARI HABITPOPUPWIDGET) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.flag_outlined, size: 40, color: theme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.habitName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.habitDescription,
                style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // --- BAGIAN INPUT DROPDOWN & TEXTFIELD ---
              Text(
                'Pilih Kategori',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDropdownValue,
                hint: const Text('Pilih Opsi'),
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() { _selectedDropdownValue = newValue; });
                },
                items: widget.dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              if (widget.showTextFieldOnLainnya && _selectedDropdownValue == 'Lainnya')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: _lainnyaController,
                    decoration: InputDecoration(
                      labelText: 'Tuliskan Keterangan Lainnya',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              // --- TAMPILAN WAKTU (DARI HABITPOPUPWIDGET) ---
              _buildTimeDisplay(context),
              
              const SizedBox(height: 20),

              // --- BAGIAN UPLOAD GAMBAR (DARI HABITPOPUPWIDGET) ---
              Text(
                'Upload Bukti (Opsional)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              _pickedImage == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _uploadOption(Icons.camera_alt_rounded, 'Kamera', Colors.blue, () => _pickImage(ImageSource.camera)),
                        _uploadOption(Icons.photo_library_rounded, 'Galeri', Colors.green, () => _pickImage(ImageSource.gallery)),
                      ],
                    )
                  : Column(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImagePreview()),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() { _pickedImage = null; _imageBytes = null; }),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                child: const Text('Hapus Foto'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                style: OutlinedButton.styleFrom(foregroundColor: theme.primaryColor, side: BorderSide(color: theme.primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                child: const Text('Ganti Foto'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // --- TOMBOL KIRIM (DARI HABITPOPUPWIDGET) ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitData,
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
                  child: _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim Bukti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waktu Pengiriman', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
              Text(
                _submissionTime.format(context),
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8)),
              ),
              Icon(Icons.access_time_filled, color: theme.primaryColor.withOpacity(0.7)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _uploadOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: color),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}