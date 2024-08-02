import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  //creating Isar object
  static late Isar isar;

  /*

  S E T U P

  */

  //I N I T I A L I Z E - D A T A B A S E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // save first date of app startup (for the heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup (for the heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

  C R U D X O P E R A T I O N

  */

  // List of habits
  final List<Habit> currentHabits = [];
  // C R E A T E - add a new habit to db
  Future<void> addHabit(String habitName) async {
    //create a new habit
    final newHabit = Habit()..name = habitName;
    //save it to db
    await isar.writeTxn(
      () => isar.habits.put(newHabit),
    );
    //re-read from db
    readHabits();
  }

  // R E A D - read saved habits from db
  Future<void> readHabits() async {
    //fetch all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    //update the ui
    notifyListeners();
  }

  // U P D A T E - check habit completion in db
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit
    final habit = await isar.habits.get(id);
    //update completion state
    if (habit != null) {
      await isar.writeTxn(
        () async {
          //if the habit is completed -> add the current date to the completedDays list
          if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
            //today
            final today = DateTime.now();
            //add the current date if its not already on the list
            habit.completedDays.add(
              DateTime(
                today.year,
                today.month,
                today.day,
              ),
            );
          }

          //if habit is not completed -> remove the current date from the list
          else {
            //remove the current date if the habit is marked as not completed
            habit.completedDays.removeWhere(
              (date) =>
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day,
            );
          }

          //save the updated habits back to db
          await isar.habits.put(habit);
        },
      );
    }

    //re-read from db
    readHabits();
  }

  // U P D A T E - edit habit name in db
  Future<void> updateHabitName(int id, String newName) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    //update habit name
    if (habit != null) {
      //update name
      await isar.writeTxn(
        () async {
          habit.name = newName;

          //save update back to db
          await isar.habits.put(habit);

          //re-read from db
          readHabits();
        },
      );
    }
  }

  // D E L E T E - delete habits from db
  Future<void> deleteHabit(int id) async {
    //delete habit from db
    await isar.writeTxn(
      () async {
        await isar.habits.delete(id);
      },
    );

    //re-read from db
    readHabits();
  }
}
