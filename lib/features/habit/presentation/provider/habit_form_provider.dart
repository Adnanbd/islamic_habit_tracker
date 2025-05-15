import 'package:flutter/material.dart';

class HabitFormProvider with ChangeNotifier {
  String? _title;
  DateTime? _reminderTime;

  String? get title => _title;
  DateTime? get reminderTime => _reminderTime;

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    _reminderTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    notifyListeners();
  }

  void setReminderFromDateTime(DateTime? time) {
    _reminderTime = time;
    notifyListeners();
  }

  void reset() {
    _title = null;
    _reminderTime = null;
  }
}
