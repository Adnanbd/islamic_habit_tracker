import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String? title;
  final bool isCompleted;
  final Map<String, bool> completionHistory;
  final DateTime createdDate;
  final DateTime? reminderTime;


  Habit({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completionHistory = const {},
    required this.createdDate,
    this.reminderTime,
  });

  Habit copyWith({bool? isCompleted, String? title, Map<String, bool>? completionHistory, DateTime? createdDate, DateTime? reminderTime}) {
    return Habit(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completionHistory: completionHistory ?? this.completionHistory,
      createdDate: createdDate ?? this.createdDate,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
