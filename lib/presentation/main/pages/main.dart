import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/core/models/member_profile_model.dart';
import 'package:kaih_7_xirpl2/core/usecase/use_usecase.dart';
import 'package:kaih_7_xirpl2/presentation/anggota/pages/anggota.dart';
import 'package:kaih_7_xirpl2/presentation/dashboard/pages/dashboard_page.dart';
import 'package:kaih_7_xirpl2/presentation/settings/pages/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final UserUseCase _userUseCase = UserUseCase();
  UserModel? _currentUser; 

  static const List<Widget> _pages = [
    DashboardPage(),
    AnggotaPage(),
    SettingsPage(),
  ];

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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _pages[_selectedIndex],
            ),
            bottomNavigationBar: _buildMobileNav(theme, isDark),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(theme, isDark), 
                const VerticalDivider(thickness: 1, width: 1),
                Expanded( 
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

 
  Widget _buildMobileNav(ThemeData theme, bool isDark) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt_rounded), label: 'Anggota'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    );
  }

  Widget _buildSidebar(ThemeData theme, bool isDark) {
    return Container(
      width: 260, // Lebar sidebar
      height: double.infinity,
      color: isDark ? const Color(0xFF161618) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _currentUser == null
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  _currentUser!.organizationName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          const SizedBox(height: 30),

          _currentUser == null
              ? const Center(child: Text("Memuat profil..."))
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      backgroundImage: _currentUser!.photoUrl != null
                          ? NetworkImage(_currentUser!.photoUrl!)
                          : null,
                      child: _currentUser!.photoUrl == null
                          ? Text(
                              _currentUser!.name.isNotEmpty ? _currentUser!.name[0].toUpperCase() : 'U',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentUser!.role.isNotEmpty ? _currentUser!.role[0].toUpperCase() + _currentUser!.role.substring(1) : 'Anggota',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(icon: Icons.dashboard_rounded, label: "Dashboard", index: 0, theme: theme),
                _buildSidebarItem(icon: Icons.people_alt_rounded, label: "Anggota", index: 1, theme: theme),
                _buildSidebarItem(icon: Icons.settings_rounded, label: "Settings", index: 2, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String label, required int index, required ThemeData theme}) {
    final bool selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? theme.primaryColor : Colors.grey[500]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? theme.primaryColor : (theme.brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}