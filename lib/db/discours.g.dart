// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discours.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscoursAdapter extends TypeAdapter<Discours> {
  @override
  final int typeId = 0;

  @override
  Discours read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discours(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Discours obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.dialogEn)
      ..writeByte(2)
      ..write(obj.dialogFr)
      ..writeByte(3)
      ..write(obj.author);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoursAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
