import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl(this.localDataSource);

  @override
  Future<void> markHabitCompleted(String id) {
    return localDataSource.markHabitCompleted(id);
  }

  @override
  Future<List<Habit>> getHabitsForToday() async {
    final models = await localDataSource.getHabitsForToday();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addHabit(Habit habit) {
    return localDataSource.addHabit(habit);
  }

  @override
  Future<void> deleteHabit(String id) => localDataSource.deleteHabit(id);

  @override
  Future<void> updateHabit(Habit habit) => localDataSource.updateHabit(habit);

  @override
  Future<void> resetCompletedHabits() async {
    final habits = await getHabitsForToday();
    for (var habit in habits) {
      if (habit.isCompleted) {
        // Mark the habit as incomplete at the start of each day
        final updatedHabit = habit.copyWith(isCompleted: false);
        await updateHabit(updatedHabit); // Update habit in Hive
      }
    }
  }

  @override
  Future<Habit> getHabitById(String id) async {
    return await localDataSource.getHabitById(id); // Fetch habit from local data source
  }
}
