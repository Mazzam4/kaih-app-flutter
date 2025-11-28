import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kaih_7_xirpl2/common/widgets/chart/chart_kontribusi.dart';
import 'package:kaih_7_xirpl2/common/widgets/habitcard/habit_card.dart';
import 'package:kaih_7_xirpl2/common/widgets/habitcard/habit_confirmation_popup.dart';
import 'package:kaih_7_xirpl2/common/widgets/habitcard/habit_dropdown_popup.dart';
import 'package:kaih_7_xirpl2/common/widgets/habitcard/habit_popup_widget.dart';
import 'package:kaih_7_xirpl2/common/widgets/info_card/info_card.dart';
import 'package:kaih_7_xirpl2/common/widgets/leaderboard/leaderboard_widget.dart';
import 'package:kaih_7_xirpl2/core/configs/habit/habit_config.dart';
import 'package:kaih_7_xirpl2/core/models/leaderboard_entry_model.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final HabitUseCase _habitUseCase = HabitUseCase();
  String? _organizationId;
  String? _userId;
  String? _userName;
  bool _isLoading = true;

  // --- DATA STREAMS ---
  Stream<List<DailyContribution>>? _chartStream;
  Stream<int>? _memberCountStream;
  Stream<int>? _progressStream;
  Stream<List<LeaderboardEntry>>? _leaderboardStream;
  Stream<List<UserHabitStatus>>? _habitStatusStream;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    setStateIfMounted(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setStateIfMounted(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final orgId = data['organizationId'] as String?;
        final name = data['name'] as String? ?? user.displayName ?? 'User';
        
        if (orgId != null) {
          setStateIfMounted(() {
            _organizationId = orgId;
            _userId = user.uid;
            _userName = name;
            
            // Inisialisasi semua stream
            _chartStream = _habitUseCase.getDailyContributionsStream(organizationId: orgId);
            _memberCountStream = _habitUseCase.getMemberCountStream(organizationId: orgId);
            _progressStream = _habitUseCase.getUserTodayProgressStream();
            _leaderboardStream = _habitUseCase.getLeaderboardStream(organizationId: orgId);
            _habitStatusStream = _habitUseCase.getUserHabitStatusStream(userId: _userId!);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading organization data: $e');
    } finally {
      setStateIfMounted(() => _isLoading = false);
    }
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // Di dalam file dashboard_page.dart

void _showHabitPopup(BuildContext context, habit) {
  if (_organizationId == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data organisasi belum siap.')));
    return;
  }

  Widget popupToShow; 

  switch (habit.name) {
    case 'BangunPagi':
    case 'TidurCepat':
      popupToShow = HabitConfirmationPopup(
        habitName: habit.name,
        habitDescription: habit.description,
        organizationId: _organizationId!,
        isMultiEntry: habit.isMultiEntry,
      );
      break;

    case 'Beribadah':
      popupToShow = HabitDropdownPopup(
        habitName: habit.name,
        habitDescription: habit.description,
        organizationId: _organizationId!,
        isMultiEntry: habit.isMultiEntry,
        dropdownItems: const ['Sholat Shubuh', 'Sholat Dzuhur', 'Sholat Ashar', 'Sholat Maghrib', 'Sholat Isya', 'Lainnya'],
        showTextFieldOnLainnya: true, 
      );
      break;

    case 'MakanSehat':
      popupToShow = HabitDropdownPopup(
        habitName: habit.name,
        habitDescription: habit.description,
        organizationId: _organizationId!,
        isMultiEntry: habit.isMultiEntry,
        dropdownItems: const ['Makan Pagi', 'Makan Siang', 'Makan Malam'],
      );
      break;

    default: 
      popupToShow = HabitPopupWidget(
        habitName: habit.name,
        habitDescription: habit.description,
        iconPath: habit.iconPath, 
        organizationId: _organizationId!,
        isMultiEntry: habit.isMultiEntry,
      );
  }

  showDialog(
    context: context,
    builder: (context) => popupToShow,
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FE), // Kembali ke background awal
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(theme, isDark),
            const SizedBox(height: 24),
            
            if (_isLoading)
              _buildOrganizationLoading(theme)
            else if (_organizationId == null)
              _buildNoOrganizationSection(theme, isDark)
            else
              Column(
                children: [
                  _buildWelcomeSection(theme, isDark),
                  const SizedBox(height: 24),
                  _buildHabitInputSection(context),
                  const SizedBox(height: 24),
                  _buildMainContentSection(theme, isDark),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan aktivitas organisasimu',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _isLoading ? null : _loadOrganizationData,
            icon: _isLoading
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  )
                : Icon(Icons.refresh_rounded, color: theme.primaryColor),
            tooltip: 'Refresh Data',
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white, // Solid color instead of gradient
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor, 
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${_userName ?? 'User'}! 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang kembali! Mari lanjutkan kebiasaan baik hari ini.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitInputSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader(
        title: 'Catat Kebiasaanmu',
        subtitle: 'Pilih kebiasaan yang sudah kamu lakukan hari ini',
        icon: Icons.add_task_rounded,
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 180,
        child: StreamBuilder<List<UserHabitStatus>>(
          stream: _habitStatusStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
              return _buildHabitCardsLoading();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Muat data kebiasaan...'));
            }

            final habitStatuses = snapshot.data!;

            final statusMap = {for (var status in habitStatuses) status.habitName: status};

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: HabitConfig.sevenHabits.length,
              itemBuilder: (context, index) {
                final habit = HabitConfig.sevenHabits[index];
                

                final status = statusMap[habit.name];
                final isCompleted = status?.isCompletedToday ?? false;

                final bool isCardDisabled = isCompleted && !habit.isMultiEntry;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == HabitConfig.sevenHabits.length - 1 ? 0 : 12,
                  ),
                  child: HabitCard(
                    habit: habit,
                    status: status,
                    // Gunakan logika isCardDisabled yang sudah benar
                    onTap: isCardDisabled ? null : () => _showHabitPopup(context, habit),
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

  Widget _buildHabitCardsLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index == 3 ? 0 : 12),
          child: Container(
            width: 130,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildMainContentSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildChartSection(theme)),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildInfoCardsColumn(isDark)),
                    ],
                  )
                : Column(
                    children: [
                      _buildChartSection(theme),
                      const SizedBox(height: 20),
                      _buildInfoCardsColumn(isDark),
                    ],
                  );
          },
        ),
        const SizedBox(height: 24),
        _buildLeaderboardSection(theme),
      ],
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    if (_chartStream == null) {
      return _buildChartLoading();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Statistik 7 Hari Terakhir', 
          subtitle: 'Total entri dari semua anggota',
          icon: Icons.insights_rounded,
        ),
        const SizedBox(height: 16),
        DailyContributionChart(dataStream: _chartStream!),
      ],
    );
  }

  Widget _buildChartLoading() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInfoCardsColumn(bool isDark) {
    return Column(
      children: [
        StreamBuilder<int>(
          stream: _memberCountStream,
          builder: (context, snapshot) {
            final memberCount = snapshot.data ?? 0;
            return InfoCardWidget(
              title: 'Total Anggota',
              value: memberCount.toString(),
              subtitle: '$memberCount anggota aktif',
              icon: Icons.people_alt_rounded,
              backgroundColor: isDark ? const Color(0xFF3D2C24) : const Color(0xFFF7D488),
              textColor: isDark ? const Color(0xFFF7D488) : const Color(0xFF5D4037),
              iconColor: isDark ? const Color(0xFFF7D488) : const Color(0xFF5D4037),
            );
          },
        ),
        const SizedBox(height: 16),
        
        StreamBuilder<int>(
          stream: _progressStream,
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0;
            final progressPercentage = progress / 7;
            
            return InfoCardWidget(
              title: 'Pengisian Hari Ini',
              value: '${snapshot.data ?? 0}/7',
              subtitle: 'Kebiasaan unik telah diisi',
              icon: Icons.check_circle_outline_rounded,
              backgroundColor: isDark ? const Color(0xFF1C3A3A) : const Color(0xFF80CBC4),
              textColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF004D40),
              iconColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF004D40),
              showProgress: true,
              progressValue: progressPercentage,
            );
          },
        ),
        const SizedBox(height: 16),
        
        InfoCardWidget(
          title: 'Hari Ini',
          value: DateFormat('d MMM').format(DateTime.now()),
          subtitle: DateFormat('EEEE, yyyy').format(DateTime.now()),
          icon: Icons.calendar_today_outlined,
          backgroundColor: isDark ? const Color(0xFF3C273B) : const Color(0xFFF48FB1),
          textColor: isDark ? const Color(0xFFF48FB1) : const Color(0xFF880E4F),
          iconColor: isDark ? const Color(0xFFF48FB1) : const Color(0xFF880E4F),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection(ThemeData theme) {
    if (_leaderboardStream == null) {
      return _buildLeaderboardLoading();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Peringkat Teratas', 
          subtitle: 'Anggota dengan kontribusi terbanyak',
          icon: Icons.emoji_events_rounded,
        ),
        const SizedBox(height: 16),
        LeaderboardWidget(dataStream: _leaderboardStream!),
      ],
    );
  }

  Widget _buildLeaderboardLoading() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOrganizationLoading(ThemeData theme) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor)),
            const SizedBox(height: 16),
            Text(
              'Memuat data organisasi...',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadOrganizationData,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrganizationSection(ThemeData theme, bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_work_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Bergabung dengan Organisasi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Bergabunglah dengan organisasi untuk mulai mencatat kebiasaan dan melihat progress bersama',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to join organization page
              },
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Gabung Organisasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, String? subtitle, required IconData icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }
}