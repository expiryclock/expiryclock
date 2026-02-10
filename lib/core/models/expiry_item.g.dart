// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiry_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpiryItemAdapter extends TypeAdapter<ExpiryItem> {
  @override
  final int typeId = 0;

  @override
  ExpiryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpiryItem(
      id: fields[0] as String,
      images: (fields[1] as List).cast<String>(),
      name: fields[2] as String,
      category: fields[3] as String,
      expiryDateMillis: fields[4] as int,
      registeredAtMillis: fields[5] as int,
      notifyBeforeDays: fields[8] as int,
      memo: fields[6] as String?,
      quantity: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExpiryItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.images)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.expiryDateMillis)
      ..writeByte(5)
      ..write(obj.registeredAtMillis)
      ..writeByte(6)
      ..write(obj.memo)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.notifyBeforeDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpiryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
