// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      name: fields[1] as String?,
      date: fields[2] as DateTime,
      purchaseValue: fields[3] as double,
      gstPercentage: fields[4] as double,
      freightCharge: fields[5] as double,
      totalCost: fields[6] as double,
      salePrice: fields[7] as double,
      margin: fields[8] as double,
      gstExpense: fields[9] as double,
      netProfit: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.purchaseValue)
      ..writeByte(4)
      ..write(obj.gstPercentage)
      ..writeByte(5)
      ..write(obj.freightCharge)
      ..writeByte(6)
      ..write(obj.totalCost)
      ..writeByte(7)
      ..write(obj.salePrice)
      ..writeByte(8)
      ..write(obj.margin)
      ..writeByte(9)
      ..write(obj.gstExpense)
      ..writeByte(10)
      ..write(obj.netProfit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
