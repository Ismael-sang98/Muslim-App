// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerCacheModelAdapter extends TypeAdapter<PrayerCacheModel> {
  @override
  final int typeId = 2;

  @override
  PrayerCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerCacheModel()
      ..moisAnnee = fields[0] as String
      ..villeId = fields[1] as String
      ..horairesMensuels = (fields[2] as List).cast<HorairesJourModel>()
      ..cachedAt = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, PrayerCacheModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.moisAnnee)
      ..writeByte(1)
      ..write(obj.villeId)
      ..writeByte(2)
      ..write(obj.horairesMensuels)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
