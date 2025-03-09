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
  String _searchCategory = 'all'; // Default search category
  
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.text = _filterText;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Item> _getSortedAndFilteredItems(Box<Item> box) {
    List<Item> items = box.values.toList();
    
    // Filter
    if (_filterText.isNotEmpty) {
      items = items.where((item) {
        switch (_searchCategory) {
          case 'name':
            return (item.name?.toLowerCase() ?? '').contains(_filterText.toLowerCase());
          case 'purchaseValue':
            return item.totalCost.toString().contains(_filterText);
          case 'salePrice':
            return item.salePrice.toString().contains(_filterText);
          case 'all':
          default:
            return (item.name?.toLowerCase() ?? '').contains(_filterText.toLowerCase()) ||
                   item.purchaseValue.toString().contains(_filterText) ||
                   item.salePrice.toString().contains(_filterText) ||
                   item.totalCost.toString().contains(_filterText);
        }
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
    final settings = Hive.box('settings');
    final double fontSizeMultiplier = settings.get('fontSizeMultiplier', defaultValue: 1.0);
    
    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
         builder: (context, settings, child) {
        final double fontSizeMultiplier = settings.get('fontSizeMultiplier', defaultValue: 1.0);

      return  Scaffold(
        appBar: AppBar(
          title: Text('Items List',style: TextStyle(color: Colors.white),),
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
              icon: Icon(Icons.sort,color: Colors.white,),
              tooltip: 'Sort items',
              onPressed: () {
                _showSortDialog();
              },
            ),
            IconButton(
              icon: Icon(Icons.settings,color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                          style: TextStyle(fontSize: 16 * fontSizeMultiplier),
                          onChanged: (value) {
                            setState(() {
                              _filterText = value;
                            });
                          },
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        tooltip: 'Select search category',
                        onSelected: (String value) {
                          setState(() {
                            _searchCategory = value;
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'all',
                            child: Text('All Fields'),
                          ),
                          PopupMenuItem<String>(
                            value: 'name',
                            child: Text('Name'),
                          ),
                          PopupMenuItem<String>(
                            value: 'purchaseValue',
                            child: Text('Cost Price'),
                          ),
                          PopupMenuItem<String>(
                            value: 'salePrice',
                            child: Text('Sale Price'),
                          ),
                        ],
                      ),
                      if (_filterText.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear),
                          tooltip: 'Clear search',
                          onPressed: () {
                            setState(() {
                              _filterText = '';
                              _searchController.clear();
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Items list
            Expanded(
              child: ValueListenableBuilder(
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
                              fontSize: 18 * fontSizeMultiplier,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to add your first item',
                            style: TextStyle(
                              fontSize: 14 * fontSizeMultiplier,
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
                      // Calculate dynamic card height based on font size
                      final double cardHeight = 80.0 * fontSizeMultiplier;
                      
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: SizedBox(
                          height: cardHeight,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0 * fontSizeMultiplier,
                            ),
                            title: Text(
                              item.name ?? 'Unnamed Item',
                              style: TextStyle(
                                fontSize: 16 * fontSizeMultiplier,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(item.date),
                                  style: TextStyle(
                                    fontSize: 14 * fontSizeMultiplier,
                                  ),
                                ),
                                Text(
                                  'Cost: ₹${item.totalCost.toStringAsFixed(2)} | Sale: ₹${item.salePrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14 * fontSizeMultiplier,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${item.netProfit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: item.netProfit >= 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16 * fontSizeMultiplier,
                                    ),
                                  ),
                                  Text(
                                    'Margin: ${item.margin.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 14 * fontSizeMultiplier,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              _showItemDetails(item, fontSizeMultiplier);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
          child: Icon(Icons.add, color: Colors.white,),
        ),
      );
         }
    );
  }
  
  void _showSortDialog() {
    // Store current value to use in dialog
    String tempSortCriteria = _sortCriteria;
    bool tempAscending = _ascending;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage state inside the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              // Remove fixed width constraint to allow dialog to adapt to content
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400), // Maximum width but can be smaller
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Important to make dialog wrap content
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sort),
                          SizedBox(width: 8),
                          Text(
                            'Sort By',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Radio buttons for sort criteria
                      RadioListTile<String>(
                        title: Text('Date'),
                        value: 'date',
                        groupValue: tempSortCriteria,
                        onChanged: (value) {
                          // Use setState from StatefulBuilder
                          setState(() {
                            tempSortCriteria = value!;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      RadioListTile<String>(
                        title: Text('Name'),
                        value: 'name',
                        groupValue: tempSortCriteria,
                        onChanged: (value) {
                          setState(() {
                            tempSortCriteria = value!;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      RadioListTile<String>(
                        title: Text('Cost Price'),
                        value: 'totalCost', // Changed from 'purchaseValue' to 'totalCost'
                        groupValue: tempSortCriteria,
                        onChanged: (value) {
                          setState(() {
                            tempSortCriteria = value!;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      RadioListTile<String>(
                        title: Text('Sale Price'),
                        value: 'salePrice', // Added 'salePrice' as sorting option
                        groupValue: tempSortCriteria,
                        onChanged: (value) {
                          setState(() {
                            tempSortCriteria = value!;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      RadioListTile<String>(
                        title: Text('Net Profit'),
                        value: 'profit',
                        groupValue: tempSortCriteria,
                        onChanged: (value) {
                          setState(() {
                            tempSortCriteria = value!;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      Divider(),
                      SwitchListTile(
                        title: Row(
                          children: [
                            Icon(tempAscending ? Icons.arrow_upward : Icons.arrow_downward),
                            SizedBox(width: 8),
                            Text(tempAscending ? 'Ascending' : 'Descending'),
                          ],
                        ),
                        value: tempAscending,
                        onChanged: (value) {
                          setState(() {
                            tempAscending = value;
                          });
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Apply changes to main state when user confirms
                              this.setState(() {
                                _sortCriteria = tempSortCriteria;
                                _ascending = tempAscending;
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
  
  void _showItemDetails(Item item, double fontSizeMultiplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            item.name ?? 'Item Details', 
            style: TextStyle(fontSize: 18 * fontSizeMultiplier),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Date', 
                  DateFormat('dd/MM/yyyy').format(item.date),
                ),
                _detailRow(
                  'Purchase Value', 
                  '₹${item.purchaseValue.toStringAsFixed(2)}',
                ),
                _detailRow(
                  'GST', 
                  '${item.gstPercentage.toStringAsFixed(2)}%',
                ),
                _detailRow(
                  'Freight Charge', 
                  '₹${item.freightCharge.toStringAsFixed(2)}',
                ),
                _detailRow(
                  'Total Cost', 
                  '₹${item.totalCost.toStringAsFixed(2)}',
                ),
                Divider(),
                _detailRow(
                  'Sale Price', 
                  '₹${item.salePrice.toStringAsFixed(2)}',
                ),
                _detailRow(
                  'Margin', 
                  '${item.margin.toStringAsFixed(2)}%',
                ),
                _detailRow(
                  'GST Expense', 
                  '₹${item.gstExpense.toStringAsFixed(2)}',
                ),
                _detailRow(
                  'Net Profit', 
                  '₹${item.netProfit.toStringAsFixed(2)}',
                  textColor: item.netProfit >= 0 ? Colors.green : Colors.red,
                ),
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
              child: Text('Delete', style: TextStyle(fontSize: 14 * fontSizeMultiplier)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close', style: TextStyle(fontSize: 14 * fontSizeMultiplier)),
            ),
          ],
        );
      },
    );
  }
  
  Widget _detailRow(String label, String value, {Color? textColor}) {
     final settings = Hive.box('settings');
    final double fontSizeMultiplier = settings.get('fontSizeMultiplier', defaultValue: 1.0);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0 * fontSizeMultiplier),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14 * fontSizeMultiplier,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14 * fontSizeMultiplier,
            ),
          ),
        ],
      ),
    );
  }
}