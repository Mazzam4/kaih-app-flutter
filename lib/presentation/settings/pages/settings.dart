import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaih_7_xirpl2/core/models/member_profile_model.dart';
import 'package:kaih_7_xirpl2/core/usecase/use_usecase.dart';
import 'package:kaih_7_xirpl2/presentation/anggota/pages/authGate.dart';
import 'package:kaih_7_xirpl2/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/join_organization_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserUseCase _userUseCase = UserUseCase();
  UserModel? _currentUser;
  bool _isSignOutExpanded = false;
  bool _isChangeOrgExpanded = false;
  bool _isSecurityExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await _userUseCase.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _toggleSignOutExpanded() {
    setState(() {
      _isSignOutExpanded = !_isSignOutExpanded;
      _isChangeOrgExpanded = false;
      _isSecurityExpanded = false;
    });
  }

  void _toggleChangeOrgExpanded() {
    setState(() {
      _isChangeOrgExpanded = !_isChangeOrgExpanded;
      _isSignOutExpanded = false;
      _isSecurityExpanded = false;
    });
  }

  void _toggleSecurityExpanded() {
    setState(() {
      _isSecurityExpanded = !_isSecurityExpanded;
      _isSignOutExpanded = false;
      _isChangeOrgExpanded = false;
    });
  }

  void _collapseAll() {
    setState(() {
      _isSignOutExpanded = false;
      _isChangeOrgExpanded = false;
      _isSecurityExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: _currentUser == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  // --- Bagian Profil ---
                  _buildProfileSection(theme),
                  const SizedBox(height: 40),

                  // --- Bagian Tampilan ---
                  _buildSectionHeader('Tampilan'),
                  const SizedBox(height: 16),
                  _buildSettingsGroup(
                    isDark: isDark,
                    children: [
                      _buildDarkModeToggle(context, theme, isDark),
                      const SizedBox(height: 16),
                      _buildNotificationToggle(theme, isDark),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- Bagian Bantuan & Akun ---
                  _buildSectionHeader('Bantuan & Akun'),
                  const SizedBox(height: 16),
                  _buildSettingsGroup(
                    isDark: isDark,
                    children: [
                      _buildExpandableOptionItem(
                        icon: Icons.logout_rounded,
                        color: Colors.red.shade400,
                        text: 'Sign Out',
                        isExpanded: _isSignOutExpanded,
                        onTap: _toggleSignOutExpanded,
                        expandedContent: _buildSignOutConfirmation(),
                      ),
                      const SizedBox(height: 8),
                      _buildExpandableOptionItem(
                        icon: Icons.group_work_rounded,
                        color: Colors.purple.shade400,
                        text: 'Ganti Organisasi',
                        isExpanded: _isChangeOrgExpanded,
                        onTap: _toggleChangeOrgExpanded,
                        expandedContent: _buildChangeOrgConfirmation(),
                      ),
                      const SizedBox(height: 8),
                      _buildExpandableOptionItem(
                        icon: Icons.security_rounded,
                        color: Colors.blue.shade400,
                        text: 'Security',
                        isExpanded: _isSecurityExpanded,
                        onTap: _toggleSecurityExpanded,
                        expandedContent: _buildSecurityOptions(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            backgroundImage: _currentUser?.photoUrl != null
                ? NetworkImage(_currentUser!.photoUrl!)
                : null,
            child: _currentUser?.photoUrl == null
                ? Text(
                    _currentUser!.name.isNotEmpty ? _currentUser!.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 32,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mode Gelap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Ubah tampilan aplikasi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isDark,
          onChanged: (value) {
            context.read<ThemeCubit>().toggleTheme();
          },
          activeThumbColor: theme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Aktifkan pemberitahuan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: false,
          onChanged: (value) {
            // TODO: Implementasi logika notifikasi
          },
          activeThumbColor: theme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildExpandableOptionItem({
    required IconData icon,
    required Color color,
    required String text,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget expandedContent,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isExpanded ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          expandedContent,
        ],
      ],
    );
  }

  Widget _buildSignOutConfirmation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfirmasi Sign Out',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan keluar dari akun ini. Pastikan data sudah tersimpan.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _collapseAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeOrgConfirmation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ganti Organisasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan bergabung dengan organisasi baru. Data organisasi lama akan diganti.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _collapseAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _collapseAll();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JoinOrganizationPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Keamanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola pengaturan keamanan akun Anda',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _collapseAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _collapseAll();
                    // TODO: Navigasi ke halaman security
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Buka'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}