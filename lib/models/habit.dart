import 'package:isar/isar.dart';
//run cmd to generate file: dart run build_runner build
part 'habit.g.dart';

@Collection()
class Habit {
  //habit ID
  Id id = Isar.autoIncrement;

  //Habit name
  late String name;

  //Completed days
  List<DateTime> completedDays = [];
}
