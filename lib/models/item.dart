import 'package:hive_flutter/hive_flutter.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late double purchaseValue;

  @HiveField(4)
  late double gstPercentage;

  @HiveField(5)
  late double freightCharge;

  @HiveField(6)
  late double totalCost;

  @HiveField(7)
  late double salePrice;

  @HiveField(8)
  late double margin;

  @HiveField(9)
  late double gstExpense;

  @HiveField(10)
  late double netProfit;

  @HiveField(11)
  double? salePriceWithoutGst;

  Item({
    required this.id,
    this.name,
    required DateTime date,
    required double purchaseValue,
    required double gstPercentage,
    required double freightCharge,
    required double totalCost,
    required double salePrice,
    required double margin,
    required double gstExpense,
    required double netProfit,
    this.salePriceWithoutGst,
  }) {
    this.date = date;
    this.purchaseValue = purchaseValue;
    this.gstPercentage = gstPercentage;
    this.freightCharge = freightCharge;
    this.totalCost = totalCost;
    this.salePrice = salePrice;
    this.margin = margin;
    this.gstExpense = gstExpense;
    this.netProfit = netProfit;
  }
}
