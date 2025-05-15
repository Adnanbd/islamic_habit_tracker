import 'package:flutter/material.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/screens/habit_list_screen.dart';
import 'package:islamic_habit_tracker/main.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../provider/habit_provider.dart';
import '../../domain/entities/habit.dart';
import 'package:intl/intl.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<HabitProvider>(context, listen: false).loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final habits = provider.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Islamic Habits')),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : habits.isEmpty
              ? const Center(child: Text('No habits for today'))
              : ListView.builder(
                itemCount: provider.habits.length,
                itemBuilder: (context, index) {
                  final habit = provider.habits[index];
                  return Dismissible(
                    key: Key(habit.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.red.shade100,
                                  child: Icon(Icons.delete, color: Colors.red, size: 30),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Are you sure you want to delete "${habit.title}"?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                            // actionsAlignment: MainAxisAlignment.,
                          );
                        },
                      );
                      return confirm;
                    },
                    onDismissed: (_) async {
                      await provider.deleteHabit(habit.id);
                      await flutterLocalNotificationsPlugin.cancel(int.parse(habit.id));
                    },
                    child: ListTile(
                      leading: Checkbox(
                        value: habit.isCompleted,
                        onChanged: (value) {
                          if (value != null && value) {
                            provider.completeHabit(habit.id);
                          }
                        },
                      ),
                      subtitle: buildProgressBar(habit),
                      title: Text('${habit.title}'),
                      trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(context, habit)),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => _showAddHabitDialog(context),
        onPressed: () {
          // NotificationService.scheduleDailyNotification(id: 1, title: 'title', body: 'body', time: DateTime.now());
          Navigator.push(context, MaterialPageRoute(builder: (context) => HabitListScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildProgressBar(Habit habit) {
    final today = DateTime.now();

    return Row(
      children: List.generate(7, (i) {
        final date = today.subtract(Duration(days: 6 - i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        // Don't show before created date
        if (date.isBefore(habit.createdDate)) {
          return const SizedBox(); // gap
        }

        final done = habit.completionHistory[dateKey] ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 20,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? Colors.green : Colors.grey.shade300),
          ),
        );
      }),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Habit'),
            content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter habit name')),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final title = controller.text.trim();
                  if (title.isNotEmpty) {
                    final newHabit = Habit(
                      id: _uuid.v4(),
                      title: title,
                      isCompleted: false,
                      createdDate: DateTime.now(),
                    );
                    Provider.of<HabitProvider>(context, listen: false).addHabit(newHabit);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context, Habit habit) {
    final controller = TextEditingController(text: habit.title);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Habit'),
            content: TextField(controller: controller, decoration: InputDecoration(hintText: 'Enter habit')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () {
                  final newTitle = controller.text.trim();
                  if (newTitle.isNotEmpty) {
                    final updatedHabit = habit.copyWith(title: newTitle);
                    context.read<HabitProvider>().updateHabit(updatedHabit);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }
}
