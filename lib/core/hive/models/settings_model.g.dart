// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 0;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel()
      ..villeId = fields[0] as String
      ..villeNom = fields[1] as String
      ..langue = fields[2] as String
      ..themeMode = fields[3] as String
      ..notificationsRaw = (fields[4] as Map).cast<dynamic, dynamic>()
      ..minutesAvantRappel = fields[5] as int
      ..villeProvinceNom = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.villeId)
      ..writeByte(1)
      ..write(obj.villeNom)
      ..writeByte(2)
      ..write(obj.langue)
      ..writeByte(3)
      ..write(obj.themeMode)
      ..writeByte(4)
      ..write(obj.notificationsRaw)
      ..writeByte(5)
      ..write(obj.minutesAvantRappel)
      ..writeByte(6)
      ..write(obj.villeProvinceNom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
