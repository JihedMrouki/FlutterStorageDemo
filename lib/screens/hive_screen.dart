import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:realm_hive_sqflite/models/bee_adapter.dart';
import 'package:hive/hive.dart';
import 'dart:isolate';

class HiveScreen extends StatefulWidget {
  const HiveScreen({super.key});

  @override
  State<HiveScreen> createState() => _HiveScreenState();
}

@HiveType(typeId: 1)
class Bee extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String role;

  Bee({required this.name, required this.role});

  @override
  String toString() => '$name - $role';
}

class _HiveScreenState extends State<HiveScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _beeNameController = TextEditingController();
  final TextEditingController _beeRoleController = TextEditingController();

  late Box<String> _stringBox;
  late Box<Bee> _beeBox;
  String _storedValue = '';
  List<String> _listItems = [];
  List<Bee> _bees = [];

  String _txnValue1 = '';
  String _txnValue2 = '';

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BeeAdapter());

    _stringBox = await Hive.openBox<String>('strings_box');
    _beeBox = await Hive.openBox<Bee>('bees_box');

    _loadValues();
  }

  void _loadValues() {
    setState(() {
      _storedValue = _stringBox.get('demo', defaultValue: '') ?? '';
      _listItems = _stringBox.values.toList();
      _bees = _beeBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Advanced Demo'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Basic Key-Value Storage
            _buildSectionTitle('Basic Key-Value Storage'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter text to store',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text('Save'),
                            onPressed: _saveValue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete, size: 20),
                            label: const Text('Delete'),
                            onPressed: _deleteValue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stored Value: ${_storedValue.isEmpty ? 'None' : _storedValue}',
                    ),
                  ],
                ),
              ),
            ),

            // 2. Box as List Example
            _buildSectionTitle('Box as List'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Text('🌸', style: TextStyle(fontSize: 20)),
                      label: const Text('Add Random Flower'),
                      onPressed: _addToList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._listItems.map(
                      (item) => ListTile(
                        leading: const Text('🌷'),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeFromList(item),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Non-primitive Objects (Bees)
            _buildSectionTitle('Bee Objects'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _beeNameController,
                      decoration: const InputDecoration(labelText: 'Bee Name'),
                    ),
                    TextField(
                      controller: _beeRoleController,
                      decoration: const InputDecoration(labelText: 'Bee Role'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Text('🐝', style: TextStyle(fontSize: 20)),
                      label: const Text('Add Bee'),
                      onPressed: _addBee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._bees.map(
                      (bee) => ListTile(
                        leading: const Text('🐝'),
                        title: Text(bee.name),
                        subtitle: Text(bee.role),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeBee(bee),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Transactions
            // 4. Transactions
            _buildSectionTitle('Transactions'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      icon: const Text('💱', style: TextStyle(fontSize: 20)),
                      label: const Text('Run Transaction'),
                      onPressed: _runTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Latest Transaction Values:'),
                    Text('txn1: $_txnValue1'),
                    Text('txn2: $_txnValue2'),
                  ],
                ),
              ),
            ),

            // 5. Isolates
            _buildSectionTitle('Isolates'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Text('🧵', style: TextStyle(fontSize: 20)),
                      label: const Text('Process in Isolate 1'),
                      onPressed: () => _useIsolate(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Text('🧶', style: TextStyle(fontSize: 20)),
                      label: const Text('Process in Isolate 2'),
                      onPressed: () => _useIsolate(2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Debug Controls
            _buildDebugControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  // 1. Basic Operations
  Future<void> _saveValue() async {
    await _stringBox.put('demo', _controller.text);
    _controller.clear();
    _loadValues();
    debugPrint('Saved value: ${_controller.text}');
  }

  Future<void> _deleteValue() async {
    await _stringBox.delete('demo');
    _loadValues();
    debugPrint('Value deleted');
  }

  // 2. Box as List
  Future<void> _addToList() async {
    final flowers = ['Rose', 'Tulip', 'Daisy', 'Lily', 'Orchid'];
    final randomFlower = flowers[DateTime.now().millisecond % flowers.length];

    await _stringBox.add(randomFlower);
    _loadValues();
    debugPrint('Added flower at index ${_stringBox.length - 1}');
  }

  Future<void> _removeFromList(String item) async {
    final index = _listItems.indexOf(item);
    if (index != -1) {
      await _stringBox.deleteAt(index);
      _loadValues();
      debugPrint('Removed item at index $index');
    }
  }

  // 3. Non-primitive Objects
  Future<void> _addBee() async {
    final bee = Bee(
      name: _beeNameController.text,
      role: _beeRoleController.text,
    );
    await _beeBox.add(bee);
    _beeNameController.clear();
    _beeRoleController.clear();
    _loadValues();
    debugPrint('Added bee: ${bee.name}');
  }

  Future<void> _removeBee(Bee bee) async {
    await bee.delete();
    _loadValues();
    debugPrint('Removed bee: ${bee.name}');
  }

  // 4. Transactions
  Future<void> _runTransaction() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final value1 = 'Value 1 : $timestamp';
      final value2 = 'Value 2 : ${timestamp + 1}';

      await _stringBox.put('txn1', value1);
      await _stringBox.put('txn2', value2);

      setState(() {
        _txnValue1 = value1;
        _txnValue2 = value2;
      });

      debugPrint('Transaction stored: txn1 = $value1, txn2 = $value2');
    } catch (e) {
      debugPrint('Error during simulated transaction: $e');
    }
  }

  // 5. Isolates
  Future<void> _useIsolate(int isolateNumber) async {
    try {
      final result = await compute(_processInIsolate, {
        'value': _storedValue,
        'isolateNumber': isolateNumber,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isolate $isolateNumber result: $result')),
      );
      debugPrint('Isolate $isolateNumber processed: $result');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Isolate error: ${e.toString()}')));
      debugPrint('Isolate error: $e');
    }
    return;
  }

  static Future<String> _processInIsolate(Map<String, dynamic> params) async {
    final value = params['value'] as String;
    final isolateNumber = params['isolateNumber'] as int;

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    return value.isEmpty
        ? 'Empty from isolate $isolateNumber'
        : '${value.toUpperCase()} (isolate $isolateNumber)';
  }

  Widget _buildDebugControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Divider(),
            const Text(
              'Debug Controls:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print All Contents'),
              onPressed: () {
                debugPrint(
                  'String Box contents: ${_stringBox.values.toList()}',
                );
                debugPrint('Bee Box contents: ${_beeBox.values.toList()}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contents printed to console')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
