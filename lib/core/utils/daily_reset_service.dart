// lib/core/utils/daily_reset_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class DailyResetService {
  final HabitRepository repository;

  DailyResetService(this.repository);

  Future<void> resetHabitsIfNeeded() async {
    final box = Hive.box('settingsBox'); // Box to store the last reset date
    final lastResetDate = box.get('lastResetDate') as String?;
    final now = tz.TZDateTime.now(tz.local);
    final today = now.toIso8601String().substring(0, 10); // Get today's date

    // If the habits haven't been reset today, reset them
    debugPrint('lastResetDate: $lastResetDate, today: $today');
    if (lastResetDate != today) {
      await repository.resetCompletedHabits(); // Reset all completed habits
      box.put('lastResetDate', today); // Save today's date as the last reset date
    }
  }
}
