import 'package:flutter/material.dart';
import 'package:gst_profit_app/screens/sales_details_screen.dart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  const PurchaseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  double _purchaseValueWithGst = 0.0;
  double _basePurchaseValue = 0.0;
  double _gstPercentage = 18.0;
  double _freightCharge = 0.0;
  double _totalCost = 0.0;
  
  final TextEditingController _purchaseController = TextEditingController();
  final TextEditingController _freightController = TextEditingController();
  final TextEditingController _customGstController = TextEditingController();
  
  List<double> _gstOptions = [18.0, 24.0];
  
  @override
  void initState() {
    super.initState();
    _loadCustomGstValues();
    
    _purchaseController.addListener(_calculateTotal);
    _freightController.addListener(_calculateTotal);
  }
  
  @override
  void dispose() {
    _purchaseController.dispose();
    _freightController.dispose();
    _customGstController.dispose();
    super.dispose();
  }
  
  void _loadCustomGstValues() async {
    final box = Hive.box<String>('customGstValues');
    if (box.isNotEmpty) {
      setState(() {
        _gstOptions = [
          18.0, 
          24.0, 
          ...box.values.map((value) => double.parse(value)).toList()
        ];
      });
    }
  }
  
  void _calculateTotal() {
    setState(() {
      _purchaseValueWithGst = double.tryParse(_purchaseController.text) ?? 0.0;
      _freightCharge = double.tryParse(_freightController.text) ?? 0.0;
      
      // Calculate base purchase value by removing GST
      _basePurchaseValue = _purchaseValueWithGst / (1 + (_gstPercentage / 100));
      
      // Total cost is now the GST-inclusive purchase value plus freight
      _totalCost = _purchaseValueWithGst + _freightCharge;
    });
  }
  
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _addCustomGst() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Custom GST'),
          content: TextField(
            controller: _customGstController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'GST Percentage',
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? value = double.tryParse(_customGstController.text);
                if (value != null && value > 0) {
                  setState(() {
                    if (!_gstOptions.contains(value)) {
                      _gstOptions.add(value);
                      _gstPercentage = value;
                      
                      // Save to persistent storage
                      Hive.box<String>('customGstValues').add(value.toString());
                    }
                  });
                  _calculateTotal();
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Details'),
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
                // Date picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Purchase Value (now with GST included)
                TextFormField(
                  controller: _purchaseController,
                  decoration: InputDecoration(
                    labelText: 'Purchase Value (GST included)',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                    helperText: 'Enter the total amount including GST',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter purchase value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // GST Percentage
                Text(
                  'GST Percentage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._gstOptions.map((option) => 
                      ChoiceChip(
                        label: Text('${option.toStringAsFixed(option.truncateToDouble() == option ? 0 : 1)}%'),
                        selected: _gstPercentage == option,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _gstPercentage = option;
                            });
                            _calculateTotal();
                          }
                        },
                      ),
                    ),
                    ActionChip(
                      avatar: Icon(Icons.add),
                      label: Text('Custom'),
                      onPressed: _addCustomGst,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Breakdown container
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purchase Breakdown:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Base Value:'),
                          Text('₹${_basePurchaseValue.toStringAsFixed(2)}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GST (${_gstPercentage.toStringAsFixed(_gstPercentage.truncateToDouble() == _gstPercentage ? 0 : 1)}%):'),
                          Text('₹${(_purchaseValueWithGst - _basePurchaseValue).toStringAsFixed(2)}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Purchase Value (with GST):'),
                          Text('₹${_purchaseValueWithGst.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Freight Charge
                TextFormField(
                  controller: _freightController,
                  decoration: InputDecoration(
                    labelText: 'Freight Charge',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                // Total Cost
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
                        '₹${_totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Navigate to next screen with calculated values
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesDetailsScreen(
                    date: _selectedDate,
                    purchaseValue: _basePurchaseValue, // Pass the base value (without GST)
                    gstPercentage: _gstPercentage,
                    freightCharge: _freightCharge,
                    totalCost: _totalCost,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Next: Sales Details',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}