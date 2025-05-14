import '../entities/habit.dart';

abstract class HabitRepository {
  Future<void> markHabitCompleted(String id);
  Future<List<Habit>> getHabitsForToday();
  Future<void> addHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> updateHabit(Habit habit);
  Future<void> resetCompletedHabits();
  Future<Habit> getHabitById(String id);
}
