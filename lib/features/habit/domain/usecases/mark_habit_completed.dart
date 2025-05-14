import '../repositories/habit_repository.dart';

class MarkHabitCompleted {
  final HabitRepository repository;

  MarkHabitCompleted(this.repository);

  Future<void> call(String id) {
    return repository.markHabitCompleted(id);
  }
}
