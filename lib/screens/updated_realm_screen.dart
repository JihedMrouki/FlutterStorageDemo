import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../models/task_person.dart';

class RealmScreen extends StatefulWidget {
  const RealmScreen({super.key});

  @override
  State<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends State<RealmScreen> {
  late Realm realm;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _personAgeController = TextEditingController();

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
        title: const Text('📁 Realm Database Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Basic CRUD Operations
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '✅ Basic Task Operations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Add new task',
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
                          onChanged: (value) => _toggleTask(task),
                        ),
                        title: Text(task.description),
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

            // 2. Object Relationships
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '👥 People & Relationships',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Person'),
                      onPressed: _addPerson,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...people.map(
                      (person) => ExpansionTile(
                        leading: const Icon(Icons.person),
                        title: Text('${person.name} (${person.age})'),
                        subtitle: Text('Tasks: ${person.tasks.length}'),
                        children: [
                          if (person.tasks.isNotEmpty)
                            ...person.tasks.map(
                              (task) => ListTile(
                                leading: const Icon(Icons.task),
                                title: Text(task.description),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed:
                                      () => _removeTaskFromPerson(person, task),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.link),
                              label: const Text('Assign Random Task'),
                              onPressed: () => _assignRandomTask(person),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple[200],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Advanced Features
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '⚡ Advanced Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Text('🔍'),
                          label: const Text('Filter Tasks'),
                          onPressed: _showFilteredTasks,
                        ),
                        ElevatedButton.icon(
                          icon: const Text('🔄'),
                          label: const Text('Transactions'),
                          onPressed: _runTransaction,
                        ),
                        ElevatedButton.icon(
                          icon: const Text('📊'),
                          label: const Text('Aggregations'),
                          onPressed: _showAggregations,
                        ),
                        ElevatedButton.icon(
                          icon: const Text('🧹'),
                          label: const Text('Cleanup'),
                          onPressed: _cleanupDatabase,
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
    if (_taskController.text.isEmpty) return;

    realm.write(() {
      realm.add(Task(_taskController.text));
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
    if (_personNameController.text.isEmpty || _personAgeController.text.isEmpty)
      return;

    realm.write(() {
      realm.add(
        Person(
          _personNameController.text,
          int.parse(_personAgeController.text),
        ),
      );
    });

    _personNameController.clear();
    _personAgeController.clear();
    setState(() {});
  }

  void _assignRandomTask(Person person) {
    final tasks = realm.all<Task>();
    if (tasks.isEmpty) return;

    final randomTask =
        tasks.toList()[DateTime.now().millisecond % tasks.length];

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

  void _showFilteredTasks() {
    final completedTasks = realm.all<Task>().query('isComplete == true');
    final highPriorityTasks = realm.all<Task>().query(
      'priority > 5 SORT(priority DESC)',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🔍 Filtered Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Completed Tasks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...completedTasks
                    .map((t) => Text('- ${t.description}'))
                    .toList(),
                const SizedBox(height: 16),
                const Text(
                  '🔝 High Priority Tasks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...highPriorityTasks
                    .map((t) => Text('- ${t.description} (${t.priority})'))
                    .toList(),
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

  void _runTransaction() {
    try {
      realm.write(() {
        // Create multiple objects in a single transaction
        final person = Person('Transaction User', 30);
        realm.add(person);

        final task1 = Task('Transaction Task 1');
        final task2 = Task('Transaction Task 2');
        realm.addAll([task1, task2]);

        person.tasks.add(task1);
        person.tasks.add(task2);

        // Uncomment to test rollback
        // throw RealmException('Intentional error for rollback demo');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Transaction completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Transaction failed: $e')));
    }
    setState(() {});
  }

  void _showAggregations() {
    final people = realm.all<Person>();
    final tasks = realm.all<Task>();

    final avgAge =
        people.isEmpty
            ? 0
            : people.map((p) => p.age).reduce((a, b) => a + b) / people.length;
    final completedCount = tasks.where((t) => t.isComplete).length;
    final highPriorityCount = tasks.where((t) => t.priority > 5).length;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('📊 Database Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👥 People count: ${people.length}'),
                Text('📊 Average age: ${avgAge.toStringAsFixed(1)}'),
                const SizedBox(height: 16),
                Text('✅ Tasks count: ${tasks.length}'),
                Text('✔ Completed tasks: $completedCount'),
                Text('🔝 High priority tasks: $highPriorityCount'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🧹 Database cleared successfully')),
    );
  }
}
