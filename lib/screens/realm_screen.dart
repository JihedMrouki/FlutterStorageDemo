import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../models/task_person.dart'; // Assuming realm_models.dart is properly set up

class RealmScreen extends StatefulWidget {
  const RealmScreen({super.key});

  @override
  State<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends State<RealmScreen> {
  late Realm realm;
  final _taskController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final config = Configuration.local([Task.schema, Person.schema]);
    realm = Realm(config);
  }

  @override
  void dispose() {
    realm.close();
    _taskController.dispose();
    _personNameController.dispose();
    _personAgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = realm.all<Task>();
    final people = realm.all<Person>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realm Demo (Simplified)'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Task Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '📝 Tasks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'New Task Description',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTask,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tasks.map(
                      (task) => ListTile(
                        leading: Checkbox(
                          value: task.isComplete,
                          onChanged: (_) => _toggleTask(task),
                        ),
                        title: Text(
                          '${task.description} (Priority: ${task.priority})',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // People Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '👥 People & Their Tasks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _personNameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _personAgeController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Person'),
                      onPressed: _addPerson,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...people.map(
                      (person) => ExpansionTile(
                        title: Text('${person.name} (Age: ${person.age})'),
                        subtitle: Text('Tasks: ${person.tasks.length}'),
                        children: [
                          ...person.tasks.map(
                            (task) => ListTile(
                              title: Text(task.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed:
                                    () => _removeTaskFromPerson(person, task),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.link),
                            label: const Text('Assign Random Task'),
                            onPressed: () => _assignRandomTask(person),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '⚙️ Extras',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: _runTransaction,
                          child: const Text('Run Transaction'),
                        ),
                        ElevatedButton(
                          onPressed: _showStats,
                          child: const Text('Show Stats'),
                        ),
                        ElevatedButton(
                          onPressed: _cleanupDatabase,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    realm.write(() {
      final task = Task(_taskController.text.trim());
      task.priority = 1; // default priority
      realm.add(task);
    });

    _taskController.clear();
    setState(() {});
  }

  void _toggleTask(Task task) {
    realm.write(() {
      task.isComplete = !task.isComplete;
    });
    setState(() {});
  }

  void _deleteTask(Task task) {
    realm.write(() {
      realm.delete(task);
    });
    setState(() {});
  }

  void _addPerson() {
    final name = _personNameController.text.trim();
    final ageStr = _personAgeController.text.trim();

    if (name.isEmpty || ageStr.isEmpty) return;

    final age = int.tryParse(ageStr);
    if (age == null) return;

    realm.write(() {
      realm.add(Person(name, age));
    });

    _personNameController.clear();
    _personAgeController.clear();
    setState(() {});
  }

  void _assignRandomTask(Person person) {
    final tasks = realm.all<Task>().toList();
    if (tasks.isEmpty) return;

    final randomTask = tasks[DateTime.now().millisecond % tasks.length];
    realm.write(() {
      person.tasks.add(randomTask);
    });
    setState(() {});
  }

  void _removeTaskFromPerson(Person person, Task task) {
    realm.write(() {
      person.tasks.remove(task);
    });
    setState(() {});
  }

  void _runTransaction() {
    try {
      realm.write(() {
        final person = Person('Test User', 28);
        final task1 = Task('Learn Realm');
        task1.priority = 8;

        final task2 = Task('Test Realm Transaction');
        task2.priority = 5;

        realm.addAll([person, task1, task2]);

        person.tasks.addAll([task1, task2]);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Transaction complete')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Transaction failed: $e')));
    }
    setState(() {});
  }

  void _showStats() {
    final people = realm.all<Person>();
    final tasks = realm.all<Task>();

    final avgAge =
        people.isEmpty
            ? 0
            : people.map((p) => p.age).reduce((a, b) => a + b) / people.length;
    final completed = tasks.where((t) => t.isComplete).length;
    final highPriority = tasks.where((t) => t.priority > 5).length;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('📊 Stats'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('People: ${people.length}'),
                Text('Avg. Age: ${avgAge.toStringAsFixed(1)}'),
                const SizedBox(height: 10),
                Text('Tasks: ${tasks.length}'),
                Text('Completed: $completed'),
                Text('High Priority: $highPriority'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _cleanupDatabase() {
    realm.write(() {
      realm.deleteAll<Task>();
      realm.deleteAll<Person>();
    });
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🧹 Database cleared')));
  }
}
