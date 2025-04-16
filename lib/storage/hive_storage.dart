import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveStorage {
  static const boxName = 'text_storage_box';

  Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await Hive.openBox(boxName);
  }

  Future<String?> getText(String key) async {
    final box = await Hive.openBox(boxName);
    return box.get(key);
  }

  Future<void> saveText(String key, String text) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, text);
  }

  Future<void> deleteText(String key) async {
    // Hive implementation
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }
}
