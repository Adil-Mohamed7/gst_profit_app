import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gst_profit_app/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() async {
    final settings = await Hive.openBox('settings');
    setState(() {
      _isDarkMode = settings.get('darkMode', defaultValue: false);
      _fontSizeMultiplier = settings.get('fontSizeMultiplier', defaultValue: 1.0);
    });
  }
  
  void _clearGstValues() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clear Custom GST Values',
            style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
          ),
          content: Text(
            'This will remove all custom GST values you have added. The default GST values (18% and 24%) will remain. Continue?',
            style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
              ),
            ),
            TextButton(
              onPressed: () {
                final box = Hive.box<String>('customGstValues');
                box.clear();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Custom GST values cleared',
                      style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                    ),
                  ),
                );
              },
              child: Text(
                'Clear',
                style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
              ),
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
          title: Text(
            'Reset All Data',
            style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
          ),
          content: Text(
            'This will delete all items and custom GST values. This action cannot be undone. Continue?',
            style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Clear all data boxes
                await Hive.box<Item>('items').clear();
                await Hive.box<String>('customGstValues').clear();
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All data has been reset',
                      style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Reset All',
                style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
              ),
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
  
  void _changeFontSize(double value) async {
    final settings = await Hive.openBox('settings');
    await settings.put('fontSizeMultiplier', value);
    
    setState(() {
      _fontSizeMultiplier = value;
    });
  }
  
  void _exportData() async {
  try {
    final box = Hive.box<Item>('items');
    final items = box.values.toList();
    
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No items to export',
            style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
          ),
        ),
      );
      return;
    }
    
    // Create Excel document
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Item Data'];
    
    // Add headers
    final headers = [
      'Name', 
      'Date', 
      'Purchase Value (₹)', 
      'GST (%)', 
      'Freight Charge (₹)', 
      'Total Cost (₹)', 
      'Sale Price (₹)', 
      'Margin (%)', 
      'GST Expense (₹)', 
      'Net Profit (₹)'
    ];
    
    // Add header row with styling
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#C0C0C0",
        horizontalAlign: HorizontalAlign.Center,
      );
    }
    
    // Add item data rows
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final row = i + 1; // +1 because row 0 is headers
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = item.name ?? 'Unnamed Item';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DateFormat('yyyy-MM-dd').format(item.date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = item.purchaseValue;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = item.gstPercentage;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = item.freightCharge;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = item.totalCost;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = item.salePrice;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = item.margin;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = item.gstExpense;
      
      // Add profit cell with conditional formatting
      final netProfitCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row));
      netProfitCell.value = item.netProfit;
      netProfitCell.cellStyle = CellStyle(
        fontColorHex: item.netProfit >= 0 ? "#008000" : "#FF0000", // Green for profit, Red for loss
      );
    }
    
    // Auto-size columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColAutoFit(i);
    }
    
    // Get the Downloads directory
   Directory? directory;
    if (Platform.isAndroid) {
      // Use a reliable path for downloads
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fall back to external storage
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    if (directory == null) {
      throw Exception('Could not access storage directory');
    }
    
    final String fileName = 'shop_profit_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    // Simplified permission handling
    if (Platform.isAndroid) {
      // Request both permissions regardless of version
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }
      
      // We'll try to request this permission, but the app will still function
      // even if it's not granted on Android 11+
      try {
        var manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      } catch (e) {
        // Ignore errors related to this permission
        print('Note: manageExternalStorage permission may not be available: $e');
      }
    }
    
    // Save the Excel file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excel file saved to: $filePath',
            style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } else {
      throw Exception('Failed to encode Excel file');
    }
  } catch (e) {
    print('Export error: $e'); // Add this for debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to export data: $e',
          style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 6),
      ),
    );
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20 * _fontSizeMultiplier, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            title: Text(
              'Dark Mode',
              style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
            ),
            subtitle: Text(
              'Switch between light and dark themes',
              style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
            ),
            value: _isDarkMode,
            onChanged: _toggleTheme,
            secondary: Icon(Icons.dark_mode, size: 24 * _fontSizeMultiplier),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields, size: 24 * _fontSizeMultiplier),
                    SizedBox(width: 16),
                    Text(
                      'Font Size',
                      style: TextStyle(
                        fontSize: 18 * _fontSizeMultiplier,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Adjust text size for better readability',
                  style: TextStyle(
                    fontSize: 16 * _fontSizeMultiplier,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _fontSizeMultiplier,
                        min: 1.0,
                        max: 2.0,
                        divisions: 4,
                        label: _getFontSizeLabel(),
                        onChanged: _changeFontSize,
                      ),
                    ),
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    _getFontSizeLabel(),
                    style: TextStyle(
                      fontSize: 16 * _fontSizeMultiplier,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Sample text
                Container(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sample text with current font size',
                    style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.percent, size: 24 * _fontSizeMultiplier),
            title: Text(
              'Clear Custom GST Values',
              style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
            ),
            subtitle: Text(
              'Remove all custom GST values',
              style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
            ),
            onTap: _clearGstValues,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, size: 24 * _fontSizeMultiplier),
            title: Text(
              'Clear All Items',
              style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
            ),
            subtitle: Text(
              'Delete all saved items',
              style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
            ),
            onTap: _clearAllData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.file_download, size: 24 * _fontSizeMultiplier),
            title: Text(
              'Export Data',
              style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
            ),
            subtitle: Text(
              'Export as Excel file',
              style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
            ),
            onTap: _exportData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, size: 24 * _fontSizeMultiplier),
            title: Text(
              'About',
              style: TextStyle(fontSize: 18 * _fontSizeMultiplier),
            ),
            subtitle: Text(
              'Shop Profit Calculator v1.0.0',
              style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Shop Profit Calculator',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.store,
                  size: 48 * _fontSizeMultiplier,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  Text(
                    'A simple app to calculate shop profits and track inventory.',
                    style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _getFontSizeLabel() {
    if (_fontSizeMultiplier <= 1.0) {
      return 'Normal';
    } else if (_fontSizeMultiplier <= 1.25) {
      return 'Large';
    } else if (_fontSizeMultiplier <= 1.5) {
      return 'X-Large';
    } else if (_fontSizeMultiplier <= 1.75) {
      return 'XX-Large';
    } else {
      return 'XXX-Large';
    }
  }
}