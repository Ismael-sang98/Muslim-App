// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horaires_jour_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorairesJourModelAdapter extends TypeAdapter<HorairesJourModel> {
  @override
  final int typeId = 1;

  @override
  HorairesJourModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HorairesJourModel()
      ..date = fields[0] as String
      ..dateHijri = fields[1] as String
      ..imsak = fields[2] as String
      ..gunes = fields[3] as String
      ..ogle = fields[4] as String
      ..ikindi = fields[5] as String
      ..aksam = fields[6] as String
      ..yatsi = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, HorairesJourModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.dateHijri)
      ..writeByte(2)
      ..write(obj.imsak)
      ..writeByte(3)
      ..write(obj.gunes)
      ..writeByte(4)
      ..write(obj.ogle)
      ..writeByte(5)
      ..write(obj.ikindi)
      ..writeByte(6)
      ..write(obj.aksam)
      ..writeByte(7)
      ..write(obj.yatsi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorairesJourModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
