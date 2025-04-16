// import 'package:flutter/material.dart';
// import '../storage/realm_storage.dart';

// class RealmScreen extends StatefulWidget {
//   const RealmScreen({super.key});

//   @override
//   State<RealmScreen> createState() => _RealmScreenState();
// }

// class _RealmScreenState extends State<RealmScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final RealmStorage _storage = RealmStorage();
//   String _storedValue = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadValue();
//   }

//   @override
//   void dispose() {
//     _storage.close();
//     super.dispose();
//   }

//   Future<void> _loadValue() async {
//     final value = await _storage.getText('demo');
//     setState(() => _storedValue = value ?? '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Realm Demo'),
//         backgroundColor: Colors.purple,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: 'Enter text to store',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _saveValue,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: const Text('Save', style: TextStyle(color: Colors.white),),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _deleteValue,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text('Delete', style: TextStyle(color: Colors.white),),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Stored Value: ${_storedValue.isEmpty ? 'None' : _storedValue}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const Spacer(),
//             _buildAdvancedFeatures(),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _saveValue() async {
//     await _storage.saveText('demo', _controller.text);
//     _controller.clear();
//     _loadValue();
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Value saved!')));
//   }

//   Future<void> _deleteValue() async {
//     await _storage.deleteText('demo');
//     _loadValue();
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Value deleted!')));
//   }

//   Widget _buildAdvancedFeatures() {
//     return Column(
//       children: [
//         const Divider(),
//         const Text(
//           'Advanced Features:',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             // Add your Realm-specific advanced features here
//             debugPrint('Realm advanced feature triggered');
//           },
//           child: const Text('Realm Query'),
//         ),
//       ],
//     );
//   }
// }
