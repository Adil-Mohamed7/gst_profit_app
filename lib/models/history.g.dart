// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationHistoryAdapter extends TypeAdapter<CalculationHistory> {
  @override
  final int typeId = 1;

  @override
  CalculationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationHistory(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      purchaseValue: fields[2] as double,
      gstPercentage: fields[3] as double,
      freightCharge: fields[4] as double,
      salePriceWithGst: fields[5] as double,
      salePriceWithoutGst: fields[6] as double,
      loadingCharges: fields[7] as double,
      margin: fields[8] as double,
      gstExpense: fields[9] as double,
      netProfit: fields[10] as double,
      totalCost: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationHistory obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.purchaseValue)
      ..writeByte(3)
      ..write(obj.gstPercentage)
      ..writeByte(4)
      ..write(obj.freightCharge)
      ..writeByte(5)
      ..write(obj.salePriceWithGst)
      ..writeByte(6)
      ..write(obj.salePriceWithoutGst)
      ..writeByte(7)
      ..write(obj.loadingCharges)
      ..writeByte(8)
      ..write(obj.margin)
      ..writeByte(9)
      ..write(obj.gstExpense)
      ..writeByte(10)
      ..write(obj.netProfit)
      ..writeByte(11)
      ..write(obj.totalCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
