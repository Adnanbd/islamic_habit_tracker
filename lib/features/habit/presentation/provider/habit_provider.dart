import 'package:flutter/foundation.dart';
import 'package:islamic_habit_tracker/features/habit/domain/repositories/habit_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/get_habits_for_today.dart';
import '../../domain/usecases/mark_habit_completed.dart';

class HabitProvider extends ChangeNotifier {
  final GetHabitsForToday getHabitsForToday;
  final MarkHabitCompleted markHabitCompleted;
  final HabitRepository _repository;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HabitProvider({
    required this.getHabitsForToday,
    required this.markHabitCompleted,
    required HabitRepository repository, // 👈 accept it in constructor
  }) : _repository = repository;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await getHabitsForToday();
    } catch (e) {
      // handle errors appropriately
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeHabit(String id) async {
    // Mark the habit completed in Hive
    await markHabitCompleted(id);

    // Fetch updated habit from Hive
    final updatedHabit = await _repository.getHabitById(id);

    // Update the habit in the provider list (trigger notifyListeners)
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = updatedHabit; // Replace with updated habit data
      notifyListeners(); // Ensure the UI is notified of the updated data
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    notifyListeners();
    await _repository.addHabit(habit);
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
    await _repository.deleteHabit(id); // we'll add this
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();
      await _repository.updateHabit(updatedHabit); // also add this
    }
  }
}
