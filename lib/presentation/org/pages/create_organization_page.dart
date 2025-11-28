import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaih_7_xirpl2/common/widgets/cust_text.dart';
import 'package:kaih_7_xirpl2/common/widgets/primary_button.dart';
import 'package:kaih_7_xirpl2/core/usecase/organization_usecase.dart';
import 'package:kaih_7_xirpl2/presentation/main/pages/main.dart';

class CreateOrganizationPage extends StatefulWidget {
  const CreateOrganizationPage({super.key});

  @override
  State<CreateOrganizationPage> createState() => _CreateOrganizationPageState();
}

class _CreateOrganizationPageState extends State<CreateOrganizationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingVerification = false;
  bool _isEmailVerified = false;

  final OrganizationUseCase _organizationUseCase = OrganizationUseCase();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _checkEmailVerificationStatus();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _checkEmailVerificationStatus() async {
    final isVerified = await _organizationUseCase.checkEmailVerification();
    if (mounted) {
      setState(() {
        _isEmailVerified = isVerified;
      });
    }
    return isVerified;
  }

  Future<void> _sendVerificationEmail() async {
    if (_isSendingVerification) return;

    setState(() => _isSendingVerification = true);

    final result = await _organizationUseCase.sendEmailVerification();

    if (result == null) {
      _showSnackBar("Email verifikasi telah dikirim! Silakan cek inbox Anda.");
    } else {
      _showSnackBar(result, isError: true);
    }

    if (mounted) {
      setState(() => _isSendingVerification = false);
    }
  }

  Future<void> _createOrganization() async {
    final bool isNowVerified = await _checkEmailVerificationStatus();

    if (!isNowVerified) {
      _showSnackBar(
        "Email belum terverifikasi. Silakan verifikasi email Anda terlebih dahulu.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _organizationUseCase.createOrganization(
      orgName: _nameController.text,
    );

    if (result == null) {
      _showSnackBar("Organisasi berhasil dibuat!");
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainPage()), (route) => false);
        
      }
    } else {
      _showSnackBar(result, isError: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Widget ini tidak lagi membuat container dengan background, hanya menampilkan kontennya.
  Widget _buildVerificationContent() {
    // Jika sudah terverifikasi, tampilkan pesan sukses
    if (_isEmailVerified) {
       return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Email telah terverifikasi',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Jika belum terverifikasi, kembalikan widget-widget yang dibutuhkan tanpa background
    return Column(
      children: [
        const SizedBox(height: 24), // Memberi jarak dari tombol "BUAT DAN MASUK"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Email belum terverifikasi',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: _isSendingVerification ? 'MENGIRIM...' : 'KIRIM VERIFIKASI EMAIL',
          isLoading: _isSendingVerification,
          onPressed: _sendVerificationEmail,
        ),
        const SizedBox(height: 4),
        Text(
          'Setelah verifikasi, tekan tombol refresh di bawah',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _checkEmailVerificationStatus,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh Status Verifikasi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Buat Organisasi Baru',
                    style: textTheme.titleLarge?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tampilkan status verifikasi jika email sudah terverifikasi
                  if (_isEmailVerified) ...[
                    _buildVerificationContent(),
                    const SizedBox(height: 24),
                  ],

                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Nama Organisasi',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'BUAT DAN MASUK',
                    isLoading: _isLoading,
                    // Tombol dinonaktifkan jika email belum diverifikasi
                    onPressed: _isEmailVerified ? _createOrganization : null,
                  ),
                  
                  // Tampilkan konten verifikasi (tombol, teks, dll) jika email BELUM terverifikasi
                  if (!_isEmailVerified) _buildVerificationContent(),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/join');
                    },
                    child: const Text('Sudah punya kode? Gabung Organisasi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}