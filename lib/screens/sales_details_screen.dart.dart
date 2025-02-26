import 'package:flutter/material.dart';
import 'package:gst_profit_app/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SalesDetailsScreen extends StatefulWidget {
  final DateTime date;
  final double purchaseValue;
  final double gstPercentage;
  final double freightCharge;
  final double totalCost;
  
  const SalesDetailsScreen({
    Key? key,
    required this.date,
    required this.purchaseValue,
    required this.gstPercentage,
    required this.freightCharge,
    required this.totalCost,
  }) : super(key: key);

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  
  double _salePrice = 0.0;
  double _margin = 0.0;
  double _gstExpense = 0.0;
  double _netProfit = 0.0;
  
  @override
  void initState() {
    super.initState();
    _salePriceController.addListener(_calculateProfitMetrics);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }
  
  void _calculateProfitMetrics() {
    setState(() {
      _salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
      
      if (widget.totalCost > 0 && _salePrice > 0) {
        // Calculate margin as a percentage
        _margin = ((_salePrice - widget.totalCost) / widget.totalCost) * 100;
        
        // Calculate GST expense
        _gstExpense = widget.purchaseValue * widget.gstPercentage / 100;
        
        // Calculate net profit
        _netProfit = _salePrice - widget.totalCost;
      } else {
        _margin = 0.0;
        _gstExpense = 0.0;
        _netProfit = 0.0;
      }
    });
  }
  
  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        date: widget.date,
        purchaseValue: widget.purchaseValue,
        gstPercentage: widget.gstPercentage,
        freightCharge: widget.freightCharge,
        totalCost: widget.totalCost,
        salePrice: _salePrice,
        margin: _margin,
        gstExpense: _gstExpense,
        netProfit: _netProfit,
      );
      
      Hive.box<Item>('items').add(item);
      
      // Navigate back to list screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Details'),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Cost Display
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${widget.totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
),
                SizedBox(height: 24),
                
                // Item Name (Optional)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter item description',
                  ),
                ),
                SizedBox(height: 16),
                
                // Sale Price
                TextFormField(
                  controller: _salePriceController,
                  decoration: InputDecoration(
                    labelText: 'Sale Price',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter sale price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                // Results section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculated Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 8),
                        
                        // Margin
                        _resultRow(
                          label: 'Margin',
                          value: '${_margin.toStringAsFixed(2)}%',
                          color: _margin >= 0 ? Colors.green : Colors.red,
                        ),
                        SizedBox(height: 12),
                        
                        // GST Expense
                        _resultRow(
                          label: 'GST Expense',
                          value: '₹${_gstExpense.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 12),
                        
                        // Net Profit
                        _resultRow(
                          label: 'Net Profit',
                          value: '₹${_netProfit.toStringAsFixed(2)}',
                          color: _netProfit >= 0 ? Colors.green : Colors.red,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveItem,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Save Item',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
  
  Widget _resultRow({
    required String label,
    required String value,
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}