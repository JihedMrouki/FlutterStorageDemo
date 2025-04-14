// import 'package:realm/realm.dart';
// import '../models/text_item.dart';

// class RealmStorage {
//   late final Realm _realm;

//   RealmStorage() {
//     final config = Configuration.local([RealmText.schema]);
//     _realm = Realm(config);
//   }

//   Future<String?> getText(String key) async {
//     final item = _realm.find<RealmText>(key);
//     return item?.value;
//   }

//   Future<void> saveText(String key, String text) async {
//     _realm.write(() {
//       _realm.add(RealmText(key, text), update: true);
//     });
//   }

//   Future<void> deleteText(String key) async {
//     final item = _realm.find<RealmText>(key);
//     if (item != null) {
//       _realm.write(() {
//         _realm.delete(item);
//       });
//     }
//   }

//   void close() {
//     _realm.close();
//   }
// }
