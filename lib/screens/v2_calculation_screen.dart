import 'package:flutter/material.dart';
import 'package:gst_profit_app/constants/app_colors.dart';
import 'package:gst_profit_app/constants/app_values.dart';
import 'package:gst_profit_app/models/item.dart';
import 'package:gst_profit_app/models/history.dart';
import 'package:gst_profit_app/screens/history_screen.dart';
import 'package:gst_profit_app/services/database_service.dart';
import 'package:gst_profit_app/services/settings_service.dart';

import '../constants/app_strings.dart';

class CalculationScreenV2 extends StatefulWidget {
  final Item? item;

  const CalculationScreenV2({Key? key, this.item}) : super(key: key);

  @override
  State<CalculationScreenV2> createState() => _CalculationScreenV2State();
}

class _CalculationScreenV2State extends State<CalculationScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Purchase Details
  double _purchaseValueWithGst = 0.0;
  double _basePurchaseValue = 0.0;
  double _gstPercentage = AppValues.defaultGst1;
  double _freightCharge = 0.0;
  double _totalCost = 0.0;
  List<double> _gstOptions = [AppValues.defaultGst1, AppValues.defaultGst2];

  // Sales Details
  double _salePriceWithGst = 0.0;
  double _baseSalePrice = 0.0;
  double _loadingCharges = 0.0;
  double _margin = 0.0;
  double _gstExpense = 0.0;
  double _netProfit = 0.0;

  // Controllers
  final TextEditingController _purchaseController = TextEditingController();
  final TextEditingController _freightController = TextEditingController();
  final TextEditingController _customGstController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _salePriceWithoutGstController =
      TextEditingController();
  final TextEditingController _loadingChargesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomGstValues();

    if (widget.item != null) {
      _gstPercentage = widget.item!.gstPercentage;
      _purchaseValueWithGst =
          widget.item!.purchaseValue * (1 + (_gstPercentage / 100));
      _purchaseController.text = _purchaseValueWithGst.toStringAsFixed(2);
      _freightController.text = widget.item!.freightCharge.toString();
      _salePriceController.text = widget.item!.salePrice.toStringAsFixed(2);
      if (widget.item!.salePriceWithoutGst != null) {
        _salePriceWithoutGstController.text =
            widget.item!.salePriceWithoutGst!.toStringAsFixed(2);
      }

      _calculateTotal();
      _calculateProfitMetrics();
    }

    _purchaseController.addListener(_calculateTotal);
    _freightController.addListener(_calculateTotal);
    _salePriceController.addListener(_calculateProfitMetrics);
    _salePriceWithoutGstController.addListener(_calculateProfitMetrics);
    _loadingChargesController.addListener(_calculateProfitMetrics);
  }

  void _loadCustomGstValues() {
    final customGstValues = DatabaseService.getCustomGstValues();
    if (customGstValues.isNotEmpty) {
      setState(() {
        _gstOptions = [
          AppValues.defaultGst1,
          AppValues.defaultGst2,
          ...customGstValues
        ];
      });
    }
  }

  void _addCustomGst() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(AppValues.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Custom GST',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppValues.paddingMedium),
                TextField(
                  controller: _customGstController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'GST Percentage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppValues.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        double? value =
                            double.tryParse(_customGstController.text);
                        if (value != null && value > 0) {
                          if (!_gstOptions.contains(value)) {
                            setState(() {
                              _gstOptions.add(value);
                              _gstPercentage = value;
                              _customGstController.clear();
                              DatabaseService.addCustomGst(value.toString());
                            });
                            _calculateTotal();
                            _calculateProfitMetrics();
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculateTotal() {
    setState(() {
      _purchaseValueWithGst = double.tryParse(_purchaseController.text) ?? 0.0;
      _freightCharge = double.tryParse(_freightController.text) ?? 0.0;
      _basePurchaseValue =
          _purchaseValueWithGst / (1 + (_gstPercentage / 100));
      _totalCost = _purchaseValueWithGst + _freightCharge;
    });
    // Recalculate profit metrics when total cost changes
    _calculateProfitMetrics();
  }

  void _calculateProfitMetrics() {
    setState(() {
      _salePriceWithGst = double.tryParse(_salePriceController.text) ?? 0.0;
      _loadingCharges = double.tryParse(_loadingChargesController.text) ?? 0.0;

      if (_salePriceWithGst > 0) {
        _baseSalePrice =
            _salePriceWithGst / (1 + (_gstPercentage / 100));

        // Calculate margin based on optional salePriceWithoutGst
        // If optional salePriceWithoutGst is provided, use it for margin calculation
        // Otherwise, use the default logic (total selling price - total cost price)
        double? salePriceWithoutGst =
            double.tryParse(_salePriceWithoutGstController.text);
        if (salePriceWithoutGst != null && salePriceWithoutGst > 0) {
          _margin = salePriceWithoutGst - _totalCost + _loadingCharges;
        } else {
          _margin = _salePriceWithGst - _totalCost + _loadingCharges;
        }

        // Calculate GST in sale price
        double gstInSalePrice = _salePriceWithGst - _baseSalePrice;

        // Calculate GST in purchase price
        double gstInPurchasePrice =
            _basePurchaseValue * (_gstPercentage / 100);

        // Calculate GST expense (GST in sale price - GST in purchase price)
        _gstExpense = gstInSalePrice - gstInPurchasePrice;

        // Calculate net profit (margin - GST expense)
        _netProfit = _margin - _gstExpense;
      } else {
        _baseSalePrice = 0.0;
        _margin = 0.0;
        _gstExpense = 0.0;
        _netProfit = 0.0;
      }
    });
  }

  void _clearForm() {
    setState(() {
      _purchaseController.clear();
      _freightController.clear();
      _salePriceController.clear();
      _salePriceWithoutGstController.clear();
      _gstPercentage = AppValues.defaultGst1;
      _purchaseValueWithGst = 0.0;
      _basePurchaseValue = 0.0;
      _freightCharge = 0.0;
      _totalCost = 0.0;
      _salePriceWithGst = 0.0;
      _baseSalePrice = 0.0;
      _margin = 0.0;
      _gstExpense = 0.0;
      _netProfit = 0.0;
    });
  }

  void _toggleDarkMode() {
    final isDarkMode = SettingsService.getDarkMode();
    SettingsService.setDarkMode(!isDarkMode);
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          onHistorySelect: _populateFromHistory,
        ),
      ),
    );
  }

  void _populateFromHistory(CalculationHistory history) {
    setState(() {
      _purchaseValueWithGst = history.purchaseValue;
      _basePurchaseValue =
          history.purchaseValue / (1 + (history.gstPercentage / 100));
      _gstPercentage = history.gstPercentage;
      _freightCharge = history.freightCharge;
      _totalCost = history.totalCost;
      _salePriceWithGst = history.salePriceWithGst;
      _baseSalePrice = history.salePriceWithoutGst;
      _loadingCharges = history.loadingCharges;
      _margin = history.margin;
      _gstExpense = history.gstExpense;
      _netProfit = history.netProfit;

      // Update controllers
      _purchaseController.text = _purchaseValueWithGst.toStringAsFixed(2);
      _freightController.text = _freightCharge.toStringAsFixed(2);
      _salePriceController.text = _salePriceWithGst.toStringAsFixed(2);
      _salePriceWithoutGstController.text =
          _baseSalePrice.toStringAsFixed(2);
      _loadingChargesController.text = _loadingCharges.toStringAsFixed(2);
    });

    // Scroll to top to show the values
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation loaded from history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveToHistory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_salePriceWithGst <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all sale price details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      purchaseValue: _purchaseValueWithGst,
      gstPercentage: _gstPercentage,
      freightCharge: _freightCharge,
      salePriceWithGst: _salePriceWithGst,
      salePriceWithoutGst: _baseSalePrice,
      loadingCharges: _loadingCharges,
      margin: _margin,
      gstExpense: _gstExpense,
      netProfit: _netProfit,
      totalCost: _totalCost,
    );

    DatabaseService.saveCalculationToHistory(history);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation saved to history'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _purchaseController.dispose();
    _freightController.dispose();
    _customGstController.dispose();
    _salePriceController.dispose();
    _salePriceWithoutGstController.dispose();
    _loadingChargesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SettingsService.getDarkMode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit Calculator'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'View History',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppValues.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Purchase Details Card
              _buildPurchaseDetailsCard(),
              const SizedBox(height: AppValues.paddingLarge),

              // Purchase Breakdown
              _buildPurchaseBreakdownCard(),
              const SizedBox(height: AppValues.paddingLarge),

              // Sales Details Card
              _buildSalesDetailsCard(),
              const SizedBox(height: AppValues.paddingLarge),

              // Sales Breakdown
              _buildSalesBreakdownCard(),
              const SizedBox(height: AppValues.paddingLarge),

              // Results Card
              _buildResultsCard(),
              const SizedBox(height: AppValues.paddingLarge),

              // Clear Button Only
              _buildActionButtons(),
              const SizedBox(height: AppValues.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: AppValues.paddingMedium),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                '💰 Purchase Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingLarge),

            // Purchase Value with helper text
            TextFormField(
              controller: _purchaseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Purchase Value (with GST)',
                helperText: 'Amount including tax',
                prefixIcon: const Icon(Icons.shopping_bag, color: AppColors.primary),
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Purchase value is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppValues.paddingLarge),

           // GST Percentage
                const Text(
                  AppStrings.gstPercentageLabel,
                  style: TextStyle(
                    fontSize: AppValues.fontSizeMedium,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppValues.paddingMedium),
                Wrap(
                  spacing: AppValues.paddingSmall,
                  children: [
                    ..._gstOptions.map((option) {
                      final decimalPlaces =
                          option.truncateToDouble() == option ? 0 : 1;
                      return ChoiceChip(
                        label: Text(
                            '${option.toStringAsFixed(decimalPlaces)}%'),
                        selected: _gstPercentage == option,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _gstPercentage = option;
                            });
                            _calculateTotal();
                          }
                        },
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Custom'),
                      onPressed: _addCustomGst,
                    ),
                  ],
                ),
            const SizedBox(height: AppValues.paddingLarge),

            // Freight Charge with helper text
            TextFormField(
              controller: _freightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Freight Charge (Optional)',
                helperText: 'Shipping and handling costs',
                prefixIcon: const Icon(Icons.local_shipping, color: AppColors.primary),
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: AppValues.paddingSmall),
              child: Text(
                '📋 Purchase Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingMedium),
            _buildDetailRow('Base Cost', _basePurchaseValue, fontSize: 15),
            const SizedBox(height: AppValues.paddingSmall),
            _buildDetailRow(
              'GST @ ${_gstPercentage.toStringAsFixed(_gstPercentage.truncateToDouble() == _gstPercentage ? 0 : 1)}%',
              _purchaseValueWithGst - _basePurchaseValue,
              fontSize: 15,
            ),
            const SizedBox(height: AppValues.paddingSmall),
            const Divider(height: 16),
            _buildDetailRow(
              'Purchase Total',
              _purchaseValueWithGst,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            const SizedBox(height: AppValues.paddingSmall),
            _buildDetailRow('Freight', _freightCharge, fontSize: 15),
            const SizedBox(height: AppValues.paddingSmall),
            const Divider(height: 16),
              _buildDetailRow(
              'Total Cost',
              _totalCost,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: AppValues.paddingMedium),
              decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '📊 Sales Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.primary,
                  ),
                ),
            ),
            const SizedBox(height: AppValues.paddingLarge),

            // Sale Price with helper text
            TextFormField(
              controller: _salePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Sale Price (with GST)',
                helperText: 'Amount including tax',
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sale price is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppValues.paddingLarge),

            // Sale Price Without GST (Optional)
            TextFormField(
              controller: _salePriceWithoutGstController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Sale Price Without GST (Optional)',
                helperText: 'For custom margin calculation',
                prefixIcon: const Icon(Icons.money_off, color: AppColors.primary),
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: AppValues.paddingLarge),

            // Loading Charges (Optional)
            TextFormField(
              controller: _loadingChargesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Loading Charges (Optional)',
                helperText: 'Additional costs added to margin',
                prefixIcon: const Icon(Icons.inventory_2, color: AppColors.primary),
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesBreakdownCard() {
    if (_salePriceWithGst <= 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: AppValues.paddingSmall),
              child: Text(
                '📋 Sales Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingMedium),
            _buildDetailRow('Base Price', _baseSalePrice, fontSize: 15),
            const SizedBox(height: AppValues.paddingSmall),
            _buildDetailRow(
              'GST @ ${_gstPercentage.toStringAsFixed(_gstPercentage.truncateToDouble() == _gstPercentage ? 0 : 1)}%',
              _salePriceWithGst - _baseSalePrice,
              fontSize: 15,
            ),
            const SizedBox(height: AppValues.paddingSmall),
            const Divider(height: 16),
            _buildDetailRow(
              'Sale Total',
              _salePriceWithGst,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final profitColor = _netProfit >= 0 ? AppColors.success : AppColors.error;

    if (_salePriceWithGst <= 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: profitColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: AppValues.paddingMedium),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: profitColor,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _netProfit >= 0 ? '🎉 Profit Analysis' : '⚠️ Loss Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                ),
              ),
            ),
            const SizedBox(height: AppValues.paddingLarge),
            _buildDetailRow(
              'Margin',
              _margin,
              color: _margin >= 0 ? AppColors.success : AppColors.error,
              fontSize: 15,
            ),
            const SizedBox(height: AppValues.paddingMedium),
            _buildDetailRow(
              'GST Expense',
              _gstExpense,
              color: _gstExpense > 0 ? AppColors.error : AppColors.success,
              fontSize: 15,
            ),
            const SizedBox(height: AppValues.paddingMedium),
            const Divider(height: 24),
            _buildDetailRow(
              'Net Profit',
              _netProfit,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: profitColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    double value, {
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 16,
  }) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              'Save to History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: AppValues.paddingMedium),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Clear All Fields',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
