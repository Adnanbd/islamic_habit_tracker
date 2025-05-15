import 'package:flutter/material.dart';
import 'package:islamic_habit_tracker/core/constants/app_strings.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/screens/add_habit_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Habits'), centerTitle: true),
      body: ListView.builder(
        itemCount: HabitType.values.length,
        itemBuilder: (context, index) {
          final habit = HabitType.values[index];
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(habit.displayName),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate or show detail if needed
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitScreen(habitType: habit,)));
            },
          );
        },
      ),
    );
  }
}
