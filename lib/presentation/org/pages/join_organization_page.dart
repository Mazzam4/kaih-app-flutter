import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/cust_text.dart';
import 'package:kaih_7_xirpl2/common/widgets/primary_button.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_colors.dart';
import 'package:kaih_7_xirpl2/presentation/main/pages/main.dart';

class JoinOrganizationPage extends StatefulWidget {
  const JoinOrganizationPage({super.key});

  @override
  State<JoinOrganizationPage> createState() => _JoinOrganizationPageState();
}

class _JoinOrganizationPageState extends State<JoinOrganizationPage> {
  final TextEditingController _orgNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> joinOrganization() async {
    final name = _orgNameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar("Nama organisasi tidak boleh kosong!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: name) 
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("Organisasi dengan nama tersebut tidak ditemukan!", isError: true);
        return;
      }

      final orgDoc = querySnapshot.docs.first;
      final orgId = orgDoc.id; 
      
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showSnackBar("Sesi Anda telah berakhir. Silakan login kembali.", isError: true);
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'organizationId': orgId,
        'role': 'member',
      }, SetOptions(merge: true));

      _showSnackBar("Berhasil bergabung ke organisasi!");

      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainPage()), (route) => false);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _orgNameController.dispose();
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
                    'Masuk ke dalam Organisasi',
                    style: textTheme.titleLarge?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Masukkan nama organisasi Anda untuk bergabung dan mulai berkolaborasi dengan tim Anda.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _orgNameController,
                    hintText: 'Masukkan Nama Organisasi',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'GABUNG',
                    isLoading: _isLoading,
                    onPressed: joinOrganization,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/create');
                    },
                    child: const Text('Mau Buat organisasi? Buat Organisasi Baru'),
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