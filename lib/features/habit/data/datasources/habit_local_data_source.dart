import 'package:intl/intl.dart';
import 'package:islamic_habit_tracker/features/habit/domain/entities/habit.dart';

import '../models/habit_model.dart';
import 'package:hive/hive.dart';

class HabitLocalDataSource {
  final Box<HabitModel> box;

  HabitLocalDataSource(this.box);

  Future<void> markHabitCompleted(String id) async {
    final habit = box.get(id);
    if (habit != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      habit.isCompleted = true;

      // If completionHistory is null, initialize it as a new empty map.
      // If it already exists, make a modifiable copy before modifying.
      habit.completionHistory = Map<String, bool>.from(habit.completionHistory ?? {});

      habit.completionHistory?[today] = true;
      await habit.save();
    }
  }

  Future<List<HabitModel>> getHabitsForToday() async {
    return box.values.toList();
  }

  Future<void> addHabit(Habit habitNew) async {
    final habit = HabitModel.fromEntity(habitNew);
    box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await box.delete(id);
  }

  Future<void> updateHabit(Habit habitNew) async {
    final habit = HabitModel.fromEntity(habitNew);
    await box.put(habit.id, habit);
  }

  Future<Habit> getHabitById(String id) async {
    final habitModel = box.get(id);
    if (habitModel == null) {
      throw Exception('Habit not found');
    }
    return habitModel.toEntity();
  }
}
