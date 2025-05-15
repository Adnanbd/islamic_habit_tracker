import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_habit_tracker/core/utils/unique_int_id.dart';
import 'package:islamic_habit_tracker/features/habit/domain/entities/habit.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/provider/habit_form_provider.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/provider/habit_provider.dart';
import 'package:islamic_habit_tracker/features/notification/notification_service.dart';
import 'package:islamic_habit_tracker/main.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddSalatHabitView extends StatefulWidget {
  const AddSalatHabitView({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  State<AddSalatHabitView> createState() => _AddSalatHabitViewState();
}

class _AddSalatHabitViewState extends State<AddSalatHabitView> {
  bool notify = false;
  final List<String> salatOptions = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  final Set<String> alreadyAssigned = {'Dhuhr', 'Asr'};

  Future<void> _pickTime(BuildContext context, HabitFormProvider provider) async {
    final TimeOfDay selectedTime = TimeOfDay(
      hour: provider.reminderTime?.hour ?? 0,
      minute: provider.reminderTime?.minute ?? 0,
    );
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime ?? TimeOfDay.now());
    if (picked != null) {
      provider.setReminderTime(picked);
      // setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitFormProvider>(context);
    final TimeOfDay? selectedTime =
        provider.reminderTime == null
            ? null
            : TimeOfDay(hour: provider.reminderTime?.hour ?? 0, minute: provider.reminderTime?.minute ?? 0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select a Salat', border: OutlineInputBorder()),
            value: provider.title,
            items:
                salatOptions.map((habit) {
                  final isDisabled = alreadyAssigned.contains(habit);

                  return DropdownMenuItem<String>(
                    value: habit,
                    enabled: !isDisabled,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(habit, style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                        if (isDisabled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('Assigned', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null && !alreadyAssigned.contains(value)) {
                provider.setTitle(value);
              }
            },
            validator: (value) => value == null ? 'Please select a habit' : null,
          ),

          const SizedBox(height: 20),

          // Notification Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Enable Daily Notification'),
              Switch(
                value: notify,
                onChanged: (val) async {
                  final bool? granted =
                      await flutterLocalNotificationsPlugin
                          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                          ?.requestNotificationsPermission();
                  if (granted == true) {
                    setState(() => notify = val);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Time Picker if notify is true
          if (notify)
            FormField<TimeOfDay>(
              validator: (value) {
                if (notify && provider.reminderTime == null) {
                  return 'Please pick a time';
                }
                return null;
              },
              builder: (state) {
                return InkWell(
                  onTap: () => _pickTime(context, provider),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Notification Time',
                      border: const OutlineInputBorder(),
                      errorText: state.errorText,
                    ),
                    child: Text(selectedTime != null ? selectedTime.format(context) : 'Select Time'),
                  ),
                );
              },
            ),

          const SizedBox(height: 30),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                int idForHabit = generateUniqueIntId();
                if (widget.formKey.currentState!.validate()) {
                  final newHabit = Habit(
                    id: idForHabit.toString(),
                    title: provider.title,
                    reminderTime: provider.reminderTime,
                    isCompleted: false,
                    completionHistory: {},
                    createdDate: DateTime.now(),
                  );

                  await NotificationService.scheduleDailyNotification(
                    id: idForHabit,
                    title: 'Daily Reminder',
                    body: 'You have a reminder for ${provider.title} Salat!',
                    time: provider.reminderTime ?? DateTime.now(),
                  );

                  // save with Provider or use case call
                  // habitProvider.addHabit(newHabit);
                  await Provider.of<HabitProvider>(context, listen: false).addHabit(newHabit);
                  context.read<HabitFormProvider>().reset();
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ),
        ],
      ),
    );
  }
}
