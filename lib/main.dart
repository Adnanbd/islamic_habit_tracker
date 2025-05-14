import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_habit_tracker/core/utils/daily_reset_service.dart';
import 'package:islamic_habit_tracker/features/habit/presentation/provider/habit_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/habit/data/datasources/habit_local_data_source.dart';
import 'features/habit/data/models/habit_model.dart';
import 'features/habit/data/repositories/habit_repository_impl.dart';
import 'features/habit/domain/repositories/habit_repository.dart';
import 'features/habit/domain/usecases/mark_habit_completed.dart';
import 'features/habit/domain/usecases/get_habits_for_today.dart';
import 'features/habit/presentation/provider/habit_provider.dart';
import 'features/habit/presentation/screens/habit_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
  await Hive.initFlutter();

  // Register your adapters
  Hive.registerAdapter(HabitModelAdapter());

  // Open necessary boxes
  final habitBox = await Hive.openBox<HabitModel>('habitsBox');
  await Hive.openBox('settingsBox'); // Settings box to track the reset date
  // await Hive.deleteBoxFromDisk('habitsBox');

  // Create the repository and reset service instances
  final habitRepository = HabitRepositoryImpl(HabitLocalDataSource(habitBox));
  final resetService = DailyResetService(habitRepository);

  // Call reset service before app starts
  await resetService.resetHabitsIfNeeded(); // Perform daily reset logic

  // ✅ Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotificationStream.add,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(MyApp(habitBox: habitBox, resetService: resetService));
}

class MyApp extends StatefulWidget {
  final Box<HabitModel> habitBox;
  final DailyResetService resetService;

  const MyApp({super.key, required this.habitBox, required this.resetService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer when widget is disposed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // The app has resumed from the background, perform the reset check here
      widget.resetService.resetHabitsIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitFormProvider()),
        Provider<HabitRepository>(create: (_) => HabitRepositoryImpl(HabitLocalDataSource(widget.habitBox))),
        ChangeNotifierProvider(
          create:
              (context) => HabitProvider(
                getHabitsForToday: GetHabitsForToday(context.read<HabitRepository>()),
                markHabitCompleted: MarkHabitCompleted(context.read<HabitRepository>()),
                repository: context.read<HabitRepository>(),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Islamic Habit Tracker',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const HabitScreen(),
      ),
    );
  }
}
