import 'package:hive/hive.dart';
import 'package:realm_hive_sqflite/screens/hive_screen.dart';

class BeeAdapter extends TypeAdapter<Bee> {
  @override
  final int typeId = 1;

  @override
  Bee read(BinaryReader reader) {
    final fields = reader.readMap();
    return Bee(name: fields['name'] as String, role: fields['role'] as String);
  }

  @override
  void write(BinaryWriter writer, Bee obj) {
    writer.writeMap({'name': obj.name, 'role': obj.role});
  }
}
