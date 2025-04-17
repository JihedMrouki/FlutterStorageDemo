import 'package:realm/realm.dart';
import '../models/task_person.dart';

class RealmStorage {
  late final Realm _realm;

  RealmStorage() {
    final config = Configuration.local([Task.schema, Person.schema]);
    _realm = Realm(config);
  }

  // ==================== TASK OPERATIONS ====================
  List<Task> getAllTasks() {
    return _realm.all<Task>().toList();
  }

  Task addTask(String description, {int priority = 1}) {
    return _realm.write(() {
      final task = Task(description);
      task.priority = priority;
      return _realm.add(task);
    });
  }

  void toggleTaskCompletion(Task task) {
    _realm.write(() {
      task.isComplete = !task.isComplete;
    });
  }

  void deleteTask(Task task) {
    _realm.write(() {
      _realm.delete(task);
    });
  }

  // ==================== PERSON OPERATIONS ====================
  List<Person> getAllPeople() {
    return _realm.all<Person>().toList();
  }

  Person addPerson(String name, int age) {
    return _realm.write(() {
      return _realm.add(Person(name, age));
    });
  }

  void assignTaskToPerson(Person person, Task task) {
    _realm.write(() {
      person.tasks.add(task);
    });
  }

  void removeTaskFromPerson(Person person, Task task) {
    _realm.write(() {
      person.tasks.remove(task);
    });
  }

  // ==================== TRANSACTIONS ====================
  void runSampleTransaction() {
    _realm.write(() {
      final person = Person('Test User', 28);
      final task1 = Task('Learn Realm')..priority = 8;
      final task2 = Task('Test Realm Transaction')..priority = 5;

      _realm.addAll([person, task1, task2]);
      person.tasks.addAll([task1, task2]);
    });
  }

  // ==================== STATS ====================
  Map<String, dynamic> getStats() {
    final people = _realm.all<Person>();
    final tasks = _realm.all<Task>();

    final avgAge =
        people.isEmpty
            ? 0
            : people.map((p) => p.age).reduce((a, b) => a + b) / people.length;
    final completed = tasks.where((t) => t.isComplete).length;
    final highPriority = tasks.where((t) => t.priority > 5).length;

    return {
      'peopleCount': people.length,
      'avgAge': avgAge,
      'tasksCount': tasks.length,
      'completedTasks': completed,
      'highPriorityTasks': highPriority,
    };
  }

  // ==================== CLEANUP ====================
  void clearAllData() {
    _realm.write(() {
      _realm.deleteAll<Task>();
      _realm.deleteAll<Person>();
    });
  }

  void close() {
    _realm.close();
  }
}
