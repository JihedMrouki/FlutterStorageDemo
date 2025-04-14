import 'package:flutter/material.dart';
import 'storage/hive_storage.dart';
import 'storage/realm_storage.dart';
import 'storage/sqflite_storage.dart';
// import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //HttpOverrides.global = MyHttpOverrides();
  runApp(const StorageDemoApp());
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

class StorageDemoApp extends StatelessWidget {
  const StorageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StorageDemoScreen(),
    );
  }
}

class StorageDemoScreen extends StatefulWidget {
  const StorageDemoScreen({super.key});

  @override
  State<StorageDemoScreen> createState() => _StorageDemoScreenState();
}

class _StorageDemoScreenState extends State<StorageDemoScreen> {
  final TextEditingController _hiveController = TextEditingController();
  final TextEditingController _realmController = TextEditingController();
  final TextEditingController _sqfliteController = TextEditingController();

  String _hiveValue = '';
  final String _realmValue = '';
  String _sqfliteValue = '';

  late final HiveStorage _hiveStorage;
  // late final RealmStorage _realmStorage;
  late final SQLiteStorage _sqfliteStorage;

  @override
  void initState() {
    super.initState();
    _initializeStorages();
  }

  Future<void> _initializeStorages() async {
    _hiveStorage = HiveStorage();
    // _realmStorage = RealmStorage();
    _sqfliteStorage = SQLiteStorage();
    await _hiveStorage.initialize();
  }

  @override
  void dispose() {
    _hiveController.dispose();
    _realmController.dispose();
    _sqfliteController.dispose();
    // _realmStorage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Solutions Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildStorageSection(
              controller: _hiveController,
              saveLabel: 'Save with Hive',
              readLabel: 'Read Hive Value',
              onSave: () async {
                await _hiveStorage.saveText('demo', _hiveController.text);
                _hiveController.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Saved to Hive!')));
              },
              onRead: () async {
                final value = await _hiveStorage.getText('demo');
                setState(() => _hiveValue = value ?? 'No value found');
              },
              value: _hiveValue,
            ),
            const SizedBox(height: 20),
            // _buildStorageSection(
            //   controller: _realmController,
            //   saveLabel: 'Save with Realm',
            //   readLabel: 'Read Realm Value',
            //   onSave: () async {
            //     await _realmStorage.saveText('demo', _realmController.text);
            //     _realmController.clear();
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Saved to Realm!')),
            //     );
            //   },
            //   onRead: () async {
            //     final value = await _realmStorage.getText('demo');
            //     setState(() => _realmValue = value ?? 'No value found');
            //   },
            //   value: _realmValue,
            // ),
            const SizedBox(height: 20),
            _buildStorageSection(
              controller: _sqfliteController,
              saveLabel: 'Save with SQLite',
              readLabel: 'Read SQLite Value',
              onSave: () async {
                await _sqfliteStorage.saveText('demo', _sqfliteController.text);
                _sqfliteController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to SQLite!')),
                );
              },
              onRead: () async {
                final value = await _sqfliteStorage.getText('demo');
                setState(() => _sqfliteValue = value ?? 'No value found');
              },
              value: _sqfliteValue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection({
    required TextEditingController controller,
    required String saveLabel,
    required String readLabel,
    required VoidCallback onSave,
    required VoidCallback onRead,
    required String value,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelText: 'Enter text to save',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onSave, child: Text(saveLabel)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRead, child: Text(readLabel)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 1.5),

                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                value.isEmpty ? 'No value loaded' : value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
