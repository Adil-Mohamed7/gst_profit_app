import 'package:hive_flutter/hive_flutter.dart';

part 'history.g.dart';

@HiveType(typeId: 1)
class CalculationHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double purchaseValue;

  @HiveField(3)
  final double gstPercentage;

  @HiveField(4)
  final double freightCharge;

  @HiveField(5)
  final double salePriceWithGst;

  @HiveField(6)
  final double salePriceWithoutGst;

  @HiveField(7)
  final double loadingCharges;

  @HiveField(8)
  final double margin;

  @HiveField(9)
  final double gstExpense;

  @HiveField(10)
  final double netProfit;

  @HiveField(11)
  final double totalCost;

  CalculationHistory({
    required this.id,
    required this.timestamp,
    required this.purchaseValue,
    required this.gstPercentage,
    required this.freightCharge,
    required this.salePriceWithGst,
    required this.salePriceWithoutGst,
    required this.loadingCharges,
    required this.margin,
    required this.gstExpense,
    required this.netProfit,
    required this.totalCost,
  });
}
