import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabitsForToday {
  final HabitRepository repository;

  GetHabitsForToday(this.repository);

  Future<List<Habit>> call() {
    return repository.getHabitsForToday();
  }
}
