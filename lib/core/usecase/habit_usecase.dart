import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaih_7_xirpl2/core/configs/habit/habit_config.dart';
import 'package:kaih_7_xirpl2/core/models/leaderboard_entry_model.dart'; 

class DailyContribution {
  final DateTime date;
  final int count;

  DailyContribution({required this.date, required this.count});
}

class UserHabitStatus {
  final String habitName;
  final bool isCompletedToday;
  final DateTime? completionTimestamp; 

  UserHabitStatus({
    required this.habitName,
    required this.isCompletedToday,
    this.completionTimestamp,
  });
}

class MemberPageInfo {
  final int totalMembers;
  final int currentUserStreak;
  final LeaderboardEntry? topMember;
  final int? currentUserRank;

  MemberPageInfo({
    required this.totalMembers,
    required this.currentUserStreak,
    this.topMember,
    this.currentUserRank,
  });
}

class HabitUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  // --- FUNGSI ASLI (TIDAK DIUBAH) ---
  Future<String?> submitHabitEntry({
    required String habitName,
    required String description,
    required String organizationId,
    XFile? pickedImage, 
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return "Pengguna tidak terautentikasi.";
    }

    String? photoUrl;

    if (pickedImage != null) {
      try {
        final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('submission_proofs/$fileName');

        if (kIsWeb) {
          await ref.putData(await pickedImage.readAsBytes());
        } else {
          await ref.putFile(File(pickedImage.path));
        }

        photoUrl = await ref.getDownloadURL();

      } catch (e) {
        return "Gagal mengunggah gambar: $e";
      }
    }

    try {
      await _firestore.collection('submissions').add({
        'userId': user.uid,
        'userName': user.displayName ?? user.email,
        'organizationId': organizationId,
        'habitName': habitName,
        'description': description,
        'photoUrl': photoUrl,
        'timestamp': Timestamp.now(),
      });
      return null;
    } catch (e) {
      return "Gagal mengirim data: $e";
    }
  }

  // --- FUNGSI BARU YANG DITAMBAHKAN ---
  // Gunakan fungsi ini di dalam HabitPopupWidget Anda
  Future<String?> submitHabitEntryWithTimeCheck({
    required String habitName,
    required String description,
    required String organizationId,
    required bool isMultiEntry,
    XFile? pickedImage,
    TimeOfDay? submissionTime,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return "Pengguna tidak terautentikasi.";
    }

    try {
      // Cek jika kebiasaan ini hanya boleh diisi sekali sehari
      if (!isMultiEntry) {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = startOfToday.add(const Duration(days: 1));

        final existingSubmission = await _firestore
            .collection('submissions')
            .where('userId', isEqualTo: user.uid)
            .where('habitName', isEqualTo: habitName)
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
            .where('timestamp', isLessThan: endOfToday)
            .limit(1)
            .get();

        if (existingSubmission.docs.isNotEmpty) {
          return "Anda sudah menyelesaikan kebiasaan '$habitName' hari ini.";
        }
      }

      // Proses upload gambar (sama seperti fungsi asli)
      String? photoUrl;
      if (pickedImage != null) {
        final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('submission_proofs/$fileName');
        if (kIsWeb) {
          await ref.putData(await pickedImage.readAsBytes());
        } else {
          await ref.putFile(File(pickedImage.path));
        }
        photoUrl = await ref.getDownloadURL();
      }

      // Buat timestamp berdasarkan waktu yang dipilih pengguna
      final now = DateTime.now();
      final submissionDateTime = submissionTime != null
          ? DateTime(now.year, now.month, now.day, submissionTime.hour, submissionTime.minute)
          : now;

      // Kirim data ke Firestore
      await _firestore.collection('submissions').add({
        'userId': user.uid,
        'userName': user.displayName ?? user.email,
        'organizationId': organizationId,
        'habitName': habitName,
        'description': description,
        'photoUrl': photoUrl,
        'timestamp': Timestamp.fromDate(submissionDateTime),
      });

      return null; // Sukses
    } on FirebaseException catch (e) {
      return "Gagal mengirim data: ${e.message}";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

 
  Stream<List<DailyContribution>> getDailyContributionsStream({
    required String organizationId,
  }) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final startOfPeriod = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    final query = _firestore
        .collection('submissions')
        .where('organizationId', isEqualTo: organizationId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod));


    return query.snapshots().map((snapshot) {
      final Map<String, int> dailyCounts = {};

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        dailyCounts[dateKey] = 0;
      }

      for (var doc in snapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        final dateKey = "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
        
        if (dailyCounts.containsKey(dateKey)) {
          dailyCounts[dateKey] = dailyCounts[dateKey]! + 1;
        }
      }

      final result = dailyCounts.entries.map((entry) {
        return DailyContribution(date: DateTime.parse(entry.key), count: entry.value);
      }).toList();

      result.sort((a, b) => a.date.compareTo(b.date));

      return result;
    });
  }


  Stream<int> getMemberCountStream({required String organizationId}) {
    return _firestore
        .collection('users')
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length); 
  }


  Stream<int> getUserTodayProgressStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0); 

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return _firestore
        .collection('submissions')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .where('timestamp', isLessThan: endOfToday)
        .snapshots()
        .map((snapshot) {
          final uniqueHabits = snapshot.docs.map((doc) => doc['habitName'] as String).toSet();
          return uniqueHabits.length;
        });
  }
  

  Stream<List<LeaderboardEntry>> getLeaderboardStream({required String organizationId}) {
    return _firestore
        .collection('submissions')
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((snapshot) {
      
      final Map<String, Map<String, dynamic>> userStats = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final userName = data['userName'] as String? ?? 'Tanpa Nama';
        final habitName = data['habitName'] as String;

        if (!userStats.containsKey(userId)) {
          userStats[userId] = {
            'userName': userName,
            'total': 0,
            'habits': <String, int>{},
          };
        }

        userStats[userId]!['total'] = (userStats[userId]!['total'] as int) + 1;
        
        final habitMap = userStats[userId]!['habits'] as Map<String, int>;
        habitMap[habitName] = (habitMap[habitName] ?? 0) + 1;
      }

      final leaderboardEntries = userStats.entries.map((entry) {
        final userId = entry.key;
        final stats = entry.value;
        return LeaderboardEntry(
          userId: userId,
          userName: stats['userName'] as String,
          totalSubmissions: stats['total'] as int,
          habitCounts: stats['habits'] as Map<String, int>,
        );
      }).toList();


      leaderboardEntries.sort((a, b) => b.totalSubmissions.compareTo(a.totalSubmissions));


      return leaderboardEntries.take(3).toList();
    });
  }

  Stream<List<LeaderboardEntry>> getFullLeaderboardStream({required String organizationId}) {
    return _firestore
        .collection('submissions')
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((snapshot) {
      final Map<String, Map<String, dynamic>> userStats = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final userName = data['userName'] as String? ?? 'Tanpa Nama';
        final habitName = data['habitName'] as String;

        if (!userStats.containsKey(userId)) {
          userStats[userId] = {'userName': userName, 'total': 0, 'habits': <String, int>{}};
        }
        userStats[userId]!['total'] = (userStats[userId]!['total'] as int) + 1;
        final habitMap = userStats[userId]!['habits'] as Map<String, int>;
        habitMap[habitName] = (habitMap[habitName] ?? 0) + 1;
      }
      final leaderboardEntries = userStats.entries.map((entry) {
        return LeaderboardEntry(
            userId: entry.key,
            userName: entry.value['userName'] as String,
            totalSubmissions: entry.value['total'] as int,
            habitCounts: entry.value['habits'] as Map<String, int>);
      }).toList();
      leaderboardEntries.sort((a, b) => b.totalSubmissions.compareTo(a.totalSubmissions));

      return leaderboardEntries;
    });
  }

  Stream<MemberPageInfo> getMemberPageInfoStream({required String organizationId}) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(MemberPageInfo(totalMembers: 0, currentUserStreak: 0));

    return getFullLeaderboardStream(organizationId: organizationId).asyncMap((leaderboard) async {
      final streak = await _calculateUserStreak(currentUser.uid);

      if (leaderboard.isEmpty) {
        return MemberPageInfo(totalMembers: 0, currentUserStreak: streak, topMember: null, currentUserRank: null);
      }

      final userRankIndex = leaderboard.indexWhere((entry) => entry.userId == currentUser.uid);
      final userRank = userRankIndex != -1 ? userRankIndex + 1 : null;

      return MemberPageInfo(
        totalMembers: leaderboard.length,
        currentUserStreak: streak,
        topMember: leaderboard.first,
        currentUserRank: userRank,
      );
    });
  }

  Future<int> _calculateUserStreak(String userId) async {
    final query = await _firestore
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    if (query.docs.isEmpty) return 0;

    final submissionDates = SplayTreeSet<DateTime>((a, b) => b.compareTo(a));
    for (var doc in query.docs) {
      final dt = (doc['timestamp'] as Timestamp).toDate();
      submissionDates.add(DateTime(dt.year, dt.month, dt.day));
    }

    int streak = 0;
    var today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);

    if (submissionDates.contains(checkDate)) {
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    while (submissionDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<String?> markHabitAsCompleted({
    required String organizationId,
    required String habitName,
    required String userId, 
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    try {
      final docRef = _firestore
          .collection('submissions')
          .doc(); 
      final submissionId = docRef.id;
      final submissionDocPath = 'submissions/$submissionId'; 

      await _firestore.collection('submissions').doc(submissionId).set({
        'userId': userId,
        'organizationId': organizationId,
        'habitName': habitName,
        'isCompletedToday': true, 
        'completionTimestamp': Timestamp.now(),
        'description': 'Tandai selesai', 
      });
      return null; 
    } catch (e) {
      return "Gagal menandai kebiasaan: $e";
    }
  }

 Stream<List<UserHabitStatus>> getUserHabitStatusStream({required String userId}) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return _firestore
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .where('timestamp', isLessThan: endOfToday)
        .snapshots()
        .map((snapshot) {
          final completedHabitsToday = snapshot.docs.map((doc) => doc['habitName'] as String).toSet();
          
          return HabitConfig.sevenHabits.map((habit) {
            return UserHabitStatus(
              habitName: habit.name,
              isCompletedToday: completedHabitsToday.contains(habit.name),
            );
          }).toList();
        });
  }
}