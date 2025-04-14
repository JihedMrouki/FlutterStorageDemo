// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'text_item.dart';

// // **************************************************************************
// // RealmObjectGenerator
// // **************************************************************************

// // ignore_for_file: type=lint
// class RealmText extends _RealmText
//     with RealmEntity, RealmObjectBase, RealmObject {
//   RealmText(
//     String id,
//     String value,
//   ) {
//     RealmObjectBase.set(this, 'id', id);
//     RealmObjectBase.set(this, 'value', value);
//   }

//   RealmText._();

//   @override
//   String get id => RealmObjectBase.get<String>(this, 'id') as String;
//   @override
//   set id(String value) => RealmObjectBase.set(this, 'id', value);

//   @override
//   String get value => RealmObjectBase.get<String>(this, 'value') as String;
//   @override
//   set value(String value) => RealmObjectBase.set(this, 'value', value);

//   @override
//   Stream<RealmObjectChanges<RealmText>> get changes =>
//       RealmObjectBase.getChanges<RealmText>(this);

//   @override
//   Stream<RealmObjectChanges<RealmText>> changesFor([List<String>? keyPaths]) =>
//       RealmObjectBase.getChangesFor<RealmText>(this, keyPaths);

//   @override
//   RealmText freeze() => RealmObjectBase.freezeObject<RealmText>(this);

//   EJsonValue toEJson() {
//     return <String, dynamic>{
//       'id': id.toEJson(),
//       'value': value.toEJson(),
//     };
//   }

//   static EJsonValue _toEJson(RealmText value) => value.toEJson();
//   static RealmText _fromEJson(EJsonValue ejson) {
//     if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
//     return switch (ejson) {
//       {
//         'id': EJsonValue id,
//         'value': EJsonValue value,
//       } =>
//         RealmText(
//           fromEJson(id),
//           fromEJson(value),
//         ),
//       _ => raiseInvalidEJson(ejson),
//     };
//   }

//   static final schema = () {
//     RealmObjectBase.registerFactory(RealmText._);
//     register(_toEJson, _fromEJson);
//     return const SchemaObject(ObjectType.realmObject, RealmText, 'RealmText', [
//       SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
//       SchemaProperty('value', RealmPropertyType.string),
//     ]);
//   }();

//   @override
//   SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
// }
