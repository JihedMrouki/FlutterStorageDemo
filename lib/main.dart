import 'package:flutter/material.dart';
import 'package:realm_hive_sqflite/screens/hive_screen.dart';
import 'package:realm_hive_sqflite/screens/sqflite_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StorageDemoApp());
}

class StorageDemoApp extends StatelessWidget {
  const StorageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/hive': (context) => const HiveScreen(),
        // '/realm': (context) => const RealmScreen(),
        '/sqflite': (context) => const SQLiteScreen(),
      },
    );
  }
}
