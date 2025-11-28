import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/leaderboard/member_data_table.dart';
import 'package:kaih_7_xirpl2/core/models/leaderboard_entry_model.dart';
import 'package:kaih_7_xirpl2/core/usecase/habit_usecase.dart';
import 'package:kaih_7_xirpl2/core/usecase/use_usecase.dart';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final HabitUseCase _habitUseCase = HabitUseCase();
  final UserUseCase _userUseCase = UserUseCase();
  String? _organizationId;
  String _organizationName = '...';
  bool _isRefreshing = false;

  Stream<MemberPageInfo>? _infoStream;
  Stream<List<LeaderboardEntry>>? _fullLeaderboardStream;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final user = await _userUseCase.getCurrentUserData();
      if (user == null || !mounted) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      final orgId = userDoc.data()?['organizationId'] as String?;

      if (mounted) {
        setState(() {
          _organizationName = user.organizationName;
          _organizationId = orgId;
          if (_organizationId != null) {
            _infoStream = _habitUseCase.getMemberPageInfoStream(organizationId: _organizationId!);
            _fullLeaderboardStream = _habitUseCase.getFullLeaderboardStream(organizationId: _organizationId!);
          }
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFD),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: theme.primaryColor,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        child: CustomScrollView(
          slivers: [
            // App Bar Section
            SliverAppBar(
              expandedHeight: 120,
              collapsedHeight: 80,
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggota $_organizationName',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lihat semua anggota dari organisasimu',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    onPressed: _isRefreshing ? null : _refreshData,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: theme.primaryColor,
                          ),
                    tooltip: 'Refresh Data',
                  ),
                ),
              ],
            ),

            // Content Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Info Cards Section - RESPONSIVE
                    StreamBuilder<MemberPageInfo>(
                      stream: _infoStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildInfoCardsLoading();
                        }
                        if (snapshot.hasError) {
                          return _buildErrorCard(snapshot.error.toString(), theme, isDark);
                        }
                        if (!snapshot.hasData) {
                          return _buildEmptyInfoCards();
                        }
                        final info = snapshot.data!;
                        return _buildResponsiveInfoCards(info, theme, isDark);
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Leaderboard Section
                    _buildLeaderboardSection(theme, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BARU: Responsive Info Cards
  Widget _buildResponsiveInfoCards(MemberPageInfo info, ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // Breakpoints untuk responsive design
        if (screenWidth > 1200) {
          // Desktop besar - 4 cards dalam 1 baris
          return _buildInfoCardsGrid(info, theme, isDark, crossAxisCount: 4, childAspectRatio: 1.2);
        } else if (screenWidth > 800) {
          // Tablet landscape - 4 cards dalam 1 baris dengan aspect ratio lebih kecil
          return _buildInfoCardsGrid(info, theme, isDark, crossAxisCount: 4, childAspectRatio: 1.0);
        } else if (screenWidth > 600) {
          // Tablet portrait - 2x2 grid
          return _buildInfoCardsGrid(info, theme, isDark, crossAxisCount: 2, childAspectRatio: 1.4);
        } else if (screenWidth > 400) {
          // Mobile landscape - 2x2 grid lebih compact
          return _buildInfoCardsGrid(info, theme, isDark, crossAxisCount: 2, childAspectRatio: 1.3);
        } else {
          // Mobile portrait kecil - 2x2 grid lebih kecil
          return _buildInfoCardsGrid(info, theme, isDark, crossAxisCount: 2, childAspectRatio: 1.2);
        }
      },
    );
  }

  // WIDGET BARU: Grid builder dengan parameter
  Widget _buildInfoCardsGrid(MemberPageInfo info, ThemeData theme, bool isDark, 
    {required int crossAxisCount, required double childAspectRatio}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: [
        _InfoCard(
          title: 'Total Anggota',
          value: info.totalMembers.toString(),
          subtitle: '${info.totalMembers} anggota aktif',
          color: const Color(0xFF6366F1),
          icon: Icons.people_alt_rounded,
          theme: theme,
          isDark: isDark,
          isCompact: crossAxisCount == 4, // Compact mode untuk desktop
        ),
        _InfoCard(
          title: 'Streak Kamu',
          value: '${info.currentUserStreak}',
          subtitle: 'hari berturut-turut',
          color: const Color(0xFF10B981),
          icon: Icons.local_fire_department_rounded,
          theme: theme,
          isDark: isDark,
          isCompact: crossAxisCount == 4,
        ),
        _InfoCard(
          title: 'Peringkat 1', 
          value: _getShortName(info.topMember?.userName ?? '-'),
          subtitle: info.topMember?.userName ?? 'Top contributor',
          color: const Color(0xFFF59E0B),
          icon: Icons.emoji_events_rounded,
          theme: theme,
          isDark: isDark,
          isUserCard: true,
          isCompact: crossAxisCount == 4,
        ),
        _InfoCard(
          title: 'Peringkat Kamu', 
          value: info.currentUserRank?.toString() ?? '-',
          subtitle: info.currentUserRank != null 
              ? 'dari ${info.totalMembers} anggota' 
              : 'Belum ada peringkat',
          color: const Color(0xFF8B5CF6),
          icon: Icons.person_rounded,
          theme: theme,
          isDark: isDark,
          isUserCard: true,
          isCompact: crossAxisCount == 4,
        ),
      ],
    );
  }

  // Helper function untuk mempersingkat nama di mode compact
  String _getShortName(String fullName) {
    if (fullName.length <= 8) return fullName;
    return '${fullName.substring(0, 7)}...';
  }

  Widget _buildInfoCardsLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 800 ? 4 : 2;
        final childAspectRatio = screenWidth > 800 ? 1.0 : 1.4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: List.generate(4, (index) => _buildShimmerCard()),
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String error, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInfoCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data anggota',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data akan muncul setelah organisasi memiliki anggota',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.leaderboard_rounded,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Leaderboard Anggota',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<LeaderboardEntry>>(
          stream: _fullLeaderboardStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLeaderboardLoading();
            }
            if (snapshot.hasError) {
              return _buildLeaderboardError(snapshot.error.toString(), theme, isDark);
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildLeaderboardEmpty(theme, isDark);
            }
            
            return MemberDataTable(data: snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLeaderboardError(String error, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat leaderboard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEmpty(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada data leaderboard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data akan muncul setelah anggota mulai mencatat kebiasaan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final ThemeData theme;
  final bool isDark;
  final bool isUserCard;
  final bool isCompact; // NEW: Parameter untuk mode compact

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.theme,
    required this.isDark,
    this.isUserCard = false,
    this.isCompact = false, // NEW: Default false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isCompact ? const EdgeInsets.all(12) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: isCompact ? const EdgeInsets.all(4) : const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon, 
                  color: Colors.white, 
                  size: isCompact ? 14 : 18
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Content - berbeda antara user card dan regular card
          if (isUserCard)
            Row(
              children: [
                Container(
                  width: isCompact ? 24 : 32,
                  height: isCompact ? 24 : 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    color: Colors.white, 
                    size: isCompact ? 12 : 18
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 20 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isCompact ? 10 : 11,
            ),
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}