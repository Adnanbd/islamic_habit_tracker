import '../../domain/entities/habit.dart';
import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  Map<String, bool>? completionHistory;

  @HiveField(4)
  DateTime? createdDate;

  @HiveField(5)
  DateTime? reminderTime;

  HabitModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.completionHistory = const {},
    required this.createdDate,
    this.reminderTime,
  });

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title ?? '',
      isCompleted: habit.isCompleted,
      completionHistory: habit.completionHistory,
      createdDate: habit.createdDate,
      reminderTime: habit.reminderTime,
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      isCompleted: isCompleted,
      completionHistory: completionHistory ?? {},
      createdDate: createdDate ?? DateTime.now(),
      reminderTime: reminderTime,
    );
  }
}
