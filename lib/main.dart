import 'package:flutter/material.dart';
import 'package:gst_profit_app/screens/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Main models
part 'main.g.dart'; // For Hive code generation

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String? name;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final double purchaseValue;
  
  @HiveField(4)
  final double gstPercentage;
  
  @HiveField(5)
  final double freightCharge;
  
  @HiveField(6)
  final double totalCost;
  
  @HiveField(7)
  final double salePrice;
  
  @HiveField(8)
  final double margin;
  
  @HiveField(9)
  final double gstExpense;
  
  @HiveField(10)
  final double netProfit;

  Item({
    required this.id,
    this.name,
    required this.date,
    required this.purchaseValue,
    required this.gstPercentage,
    required this.freightCharge,
    required this.totalCost,
    required this.salePrice,
    required this.margin,
    required this.gstExpense,
    required this.netProfit,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Item>('items');
  await Hive.openBox<String>('customGstValues');
   await Hive.openBox('settings');
   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, _) {
        final isDarkMode = box.get('darkMode', defaultValue: false) as bool;
        return MaterialApp(
          title: 'Shop Profit Calculator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              primary: Colors.purple,
              secondary: Colors.blue,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: Brightness.dark,
              primary: Colors.purple,
              secondary: Colors.blue,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}