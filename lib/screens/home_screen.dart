import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Storage Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStorageButton(
              context,
              title: 'Hive',
              color: Colors.orange,
              route: '/hive',
            ),
            const SizedBox(height: 20),
            _buildStorageButton(
              context,
              title: 'Realm',
              color: Colors.purple,
              route: '/realm',
            ),
            const SizedBox(height: 20),
            _buildStorageButton(
              context,
              title: 'SQLite',
              color: Colors.green,
              route: '/sqflite',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageButton(
    BuildContext context, {
    required String title,
    required Color color,
    required String route,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
