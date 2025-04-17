import 'package:flutter/material.dart';
import 'package:realm_hive_sqflite/models/task_person.dart';
import '../storage/realm_storage.dart';

class RealmScreen extends StatefulWidget {
  const RealmScreen({super.key});

  @override
  State<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends State<RealmScreen> {
  final _realmStorage = RealmStorage();
  final _taskController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personAgeController = TextEditingController();

  @override
  void dispose() {
    _realmStorage.close();
    _taskController.dispose();
    _personNameController.dispose();
    _personAgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _realmStorage.getAllTasks();
    final people = _realmStorage.getAllPeople();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realm Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tasks Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('📝 Tasks'),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTask,
                        ),
                      ),
                    ),
                    ...tasks.map(
                      (task) => ListTile(
                        title: Text(task.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(task),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // People Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('👥 People'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _personNameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _personAgeController,
                            decoration: const InputDecoration(labelText: 'Age'),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _addPerson,
                      child: const Text('Add Person'),
                    ),
                    ...people.map(
                      (person) => ListTile(
                        title: Text(person.name),
                        subtitle: Text('Tasks: ${person.tasks.length}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('⚙️ Actions'),
                    ElevatedButton(
                      onPressed: _realmStorage.runSampleTransaction,
                      child: const Text('Run Transaction'),
                    ),
                    ElevatedButton(
                      onPressed: _showStats,
                      child: const Text('Show Stats'),
                    ),
                    ElevatedButton(
                      onPressed: _realmStorage.clearAllData,
                      child: const Text('Clear All'),
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
    if (_taskController.text.isNotEmpty) {
      _realmStorage.addTask(_taskController.text);
      _taskController.clear();
      setState(() {});
    }
  }

  void _deleteTask(Task task) {
    _realmStorage.deleteTask(task);
    setState(() {});
  }

  void _addPerson() {
    final age = int.tryParse(_personAgeController.text);
    if (_personNameController.text.isNotEmpty && age != null) {
      _realmStorage.addPerson(_personNameController.text, age);
      _personNameController.clear();
      _personAgeController.clear();
      setState(() {});
    }
  }

  void _showStats() {
    final stats = _realmStorage.getStats();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('📊 Stats'),
            content: Column(
              children: [
                Text('People: ${stats['peopleCount']}'),
                Text('Avg Age: ${stats['avgAge']}'),
                Text('Tasks: ${stats['tasksCount']}'),
              ],
            ),
          ),
    );
  }
}
