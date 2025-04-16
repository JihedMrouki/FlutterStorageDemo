import 'package:realm/realm.dart';

part 'task_person.realm.dart';

@RealmModel()
class _Task {
  late String description;
  bool isComplete = false;
  int priority = 0;
}

@RealmModel()
class _Person {
  late String name;
  late int age;
  late List<_Task> tasks;
}
