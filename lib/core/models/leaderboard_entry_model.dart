class LeaderboardEntry {
  final String userId;
  final String userName;
  final Map<String, int> habitCounts; 
  final int totalSubmissions;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.habitCounts,
    required this.totalSubmissions,
  });
}

