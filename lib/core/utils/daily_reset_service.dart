// lib/core/utils/daily_reset_service.dart

import 'package:hive/hive.dart';
import '../../features/habit/domain/repositories/habit_repository.dart';

class DailyResetService {
  final HabitRepository repository;

  DailyResetService(this.repository);

  Future<void> resetHabitsIfNeeded() async {
    final box = Hive.box('settingsBox'); // Box to store the last reset date
    final lastResetDate = box.get('lastResetDate') as String?;
    final today = DateTime.now().toIso8601String().substring(0, 10); // Get today's date

    // If the habits haven't been reset today, reset them
    if (lastResetDate != today) {
      await repository.resetCompletedHabits(); // Reset all completed habits
      box.put('lastResetDate', today); // Save today's date as the last reset date
    }
  }
}
