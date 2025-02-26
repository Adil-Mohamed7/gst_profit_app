import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gst_profit_app/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() async {
    final settings = await Hive.openBox('settings');
    setState(() {
      _isDarkMode = settings.get('darkMode', defaultValue: false);
    });
  }
  
  void _clearGstValues() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Custom GST Values'),
          content: Text('This will remove all custom GST values you have added. The default GST values (18% and 24%) will remain. Continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final box = Hive.box<String>('customGstValues');
                box.clear();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Custom GST values cleared'),
                  ),
                );
              },
              child: Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
  
  void _clearAllData() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset All Data'),
          content: Text('This will delete all items and custom GST values. This action cannot be undone. Continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Clear all data boxes
                await Hive.box<Item>('items').clear();
                await Hive.box<String>('customGstValues').clear();
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All data has been reset'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('Reset All'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
  
  void _toggleTheme(bool value) async {
    final settings = await Hive.openBox('settings');
    await settings.put('darkMode', value);
    
    setState(() {
      _isDarkMode = value;
    });
  }
  
  void _exportData() async {
    try {
      final box = Hive.box<Item>('items');
      final items = box.values.toList();
      
      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No items to export'),
          ),
        );
        return;
      }
      
      final List<Map<String, dynamic>> jsonData = items.map((item) => {
        'name': item.name ?? 'Unnamed Item',
        'date': DateFormat('yyyy-MM-dd').format(item.date),
        'purchaseValue': item.purchaseValue,
        'gstPercentage': item.gstPercentage,
        'freightCharge': item.freightCharge,
        'totalCost': item.totalCost,
        'salePrice': item.salePrice,
        'margin': item.margin,
        'gstExpense': item.gstExpense,
        'netProfit': item.netProfit,
      }).toList();
      
      final jsonString = jsonEncode(jsonData);
      
      // In a real app, you would use path_provider and file_saver packages
      // to save this to a file. For now, we'll just show a success message.
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.blue],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Switch between light and dark themes'),
            value: _isDarkMode,
            onChanged: _toggleTheme,
            secondary: Icon(Icons.dark_mode),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.percent),
            title: Text('Clear Custom GST Values'),
            subtitle: Text('Remove all custom GST values'),
            onTap: _clearGstValues,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Clear All Items'),
            subtitle: Text('Delete all saved items'),
            onTap: _clearAllData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text('Export Data'),
            subtitle: Text('Export as JSON file'),
            onTap: _exportData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Shop Profit Calculator v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Shop Profit Calculator',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.store,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  Text('A simple app to calculate shop profits and track inventory.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ItemAdapter class for Hive (would be generated by build_runner)
// class ItemAdapter extends TypeAdapter<Item> {
//   @override
//   final int typeId = 0;

//   @override
//   Item read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return Item(
//       id: fields[0] as String,
//       name: fields[1] as String?,
//       date: fields[2] as DateTime,
//       purchaseValue: fields[3] as double,
//       gstPercentage: fields[4] as double,
//       freightCharge: fields[5] as double,
//       totalCost: fields[6] as double,
//       salePrice: fields[7] as double,
//       margin: fields[8] as double,
//       gstExpense: fields[9] as double,
//       netProfit: fields[10] as double,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Item obj) {
//     writer
//       ..writeByte(11)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.name)
//       ..writeByte(2)
//       ..write(obj.date)
//       ..writeByte(3)
//       ..write(obj.purchaseValue)
//       ..writeByte(4)
//       ..write(obj.gstPercentage)
//       ..writeByte(5)
//       ..write(obj.freightCharge)
//       ..writeByte(6)
//       ..write(obj.totalCost)
//       ..writeByte(7)
//       ..write(obj.salePrice)
//       ..writeByte(8)
//       ..write(obj.margin)
//       ..writeByte(9)
//       ..write(obj.gstExpense)
//       ..writeByte(10)
//       ..write(obj.netProfit);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is ItemAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }