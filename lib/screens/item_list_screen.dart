import 'package:flutter/material.dart';
import 'package:gst_profit_app/main.dart';
import 'package:gst_profit_app/screens/purchase_details_screen.dart';
import 'package:gst_profit_app/screens/settings_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  String _sortCriteria = 'date';
  bool _ascending = false;
  String _filterText = '';
  
  List<Item> _getSortedAndFilteredItems(Box<Item> box) {
    List<Item> items = box.values.toList();
    
    // Filter
    if (_filterText.isNotEmpty) {
      items = items.where((item) {
        return (item.name?.toLowerCase() ?? '').contains(_filterText.toLowerCase()) ||
               item.purchaseValue.toString().contains(_filterText) ||
               item.totalCost.toString().contains(_filterText);
      }).toList();
    }
    
    // Sort
    items.sort((a, b) {
      switch (_sortCriteria) {
        case 'date':
          return _ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
        case 'name':
          return _ascending 
              ? (a.name ?? '').compareTo(b.name ?? '') 
              : (b.name ?? '').compareTo(a.name ?? '');
        case 'purchaseValue':
          return _ascending 
              ? a.purchaseValue.compareTo(b.purchaseValue) 
              : b.purchaseValue.compareTo(a.purchaseValue);
        case 'totalCost':
          return _ascending 
              ? a.totalCost.compareTo(b.totalCost) 
              : b.totalCost.compareTo(a.totalCost);
        case 'profit':
          return _ascending 
              ? a.netProfit.compareTo(b.netProfit) 
              : b.netProfit.compareTo(a.netProfit);
        default:
          return _ascending 
              ? a.date.compareTo(b.date) 
              : b.date.compareTo(a.date);
      }
    });
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items List'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.blue],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Item>('items').listenable(),
        builder: (context, Box<Item> box, _) {
          final items = _getSortedAndFilteredItems(box);
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first item',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(item.name ?? 'Unnamed Item'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(item.date)),
                      Text('Cost: ₹${item.totalCost.toStringAsFixed(2)} | Sale: ₹${item.salePrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.netProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: item.netProfit >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Margin: ${item.margin.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showItemDetails(item);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => PurchaseDetailsScreen(),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Items'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Search by name, cost, etc.',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _filterText = value;
              });
            },
            controller: TextEditingController(text: _filterText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterText = '';
                });
                Navigator.pop(context);
              },
              child: Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Date'),
                value: 'date',
                groupValue: _sortCriteria,
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Name'),
                value: 'name',
                groupValue: _sortCriteria,
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Purchase Value'),
                value: 'purchaseValue',
                groupValue: _sortCriteria,
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Total Cost'),
                value: 'totalCost',
                groupValue: _sortCriteria,
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Net Profit'),
                value: 'profit',
                groupValue: _sortCriteria,
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                  });
                },
              ),
              SwitchListTile(
                title: Text(_ascending ? 'Ascending' : 'Descending'),
                value: _ascending,
                onChanged: (value) {
                  setState(() {
                    _ascending = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
  
  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.name ?? 'Item Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Date', DateFormat('dd/MM/yyyy').format(item.date)),
                _detailRow('Purchase Value', '₹${item.purchaseValue.toStringAsFixed(2)}'),
                _detailRow('GST', '${item.gstPercentage.toStringAsFixed(2)}%'),
                _detailRow('Freight Charge', '₹${item.freightCharge.toStringAsFixed(2)}'),
                _detailRow('Total Cost', '₹${item.totalCost.toStringAsFixed(2)}'),
                Divider(),
                _detailRow('Sale Price', '₹${item.salePrice.toStringAsFixed(2)}'),
                _detailRow('Margin', '${item.margin.toStringAsFixed(2)}%'),
                _detailRow('GST Expense', '₹${item.gstExpense.toStringAsFixed(2)}'),
                _detailRow('Net Profit', '₹${item.netProfit.toStringAsFixed(2)}', 
                  textColor: item.netProfit >= 0 ? Colors.green : Colors.red),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Hive.box<Item>('items').delete(item.key);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _detailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}