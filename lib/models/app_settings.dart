import 'package:isar/isar.dart';
//run cmd to generate file: dart run build_runner build
part 'app_settings.g.dart';

@Collection()
class AppSettings {
  //ID
  Id id = Isar.autoIncrement;

  //first time launch datetime
  DateTime? firstLaunchDate;
}
