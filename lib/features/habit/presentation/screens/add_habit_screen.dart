import 'package:flutter/material.dart';
import 'package:islamic_habit_tracker/core/constants/app_strings.dart';
import 'package:islamic_habit_tracker/features/habit/domain/entities/habit.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/provider/habit_form_provider.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/provider/habit_provider.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/screens/helpers/add_salat_habit_view.dart';
import 'package:islamic_habit_tracker/features/notification/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddHabitScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final HabitType habitType;

  AddHabitScreen({super.key, required this.habitType});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitFormProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              habitType == HabitType.salat
                  ? AddSalatHabitView(formKey: _formKey,)
                  : Column(
                    children: [
                      // Title field
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Habit Title'),
                        onChanged: provider.setTitle,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 20),

                      // Time Picker
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          provider.reminderTime != null
                              ? TimeOfDay.fromDateTime(provider.reminderTime!).format(context)
                              : 'Select Reminder Time',
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (picked != null) {
                            provider.setReminderTime(picked);
                          }
                        },
                      ),

                      const Spacer(),

                      // Submit button
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newHabit = Habit(
                              id: const Uuid().v4(),
                              title: provider.title,
                              reminderTime: provider.reminderTime,
                              isCompleted: false,
                              completionHistory: {},
                              createdDate: DateTime.now(),
                            );

                            await NotificationService.scheduleDailyNotification(
                              id: Uuid().hashCode,
                              title: 'Daily Habit Reminder',
                              body: 'You have a reminder for ${provider.title}',
                              time: provider.reminderTime ?? DateTime.now(),
                            );

                            // save with Provider or use case call
                            // habitProvider.addHabit(newHabit);
                            await Provider.of<HabitProvider>(context, listen: false).addHabit(newHabit);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Habit'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
