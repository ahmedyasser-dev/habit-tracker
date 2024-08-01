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
      await isar.writeTxn(
        () => isar.appSettings.put(settings),
        //todo 4:18:40
      );
    }
  }

  // get first date of app startup (for the heatmap)

  /*

  C R U D X O P E R A T I O N

  */

  // List of habits

  // C R E A T E - add a new habit to db
  // R E A D - read saved habits from db
  // U P D A T E - check habit on and off in db
  // U P D A T E - edit habit name in db
  // D E L E T E - delete habits from db
}
