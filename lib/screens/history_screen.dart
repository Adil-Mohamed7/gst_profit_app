import 'package:flutter/material.dart';
import 'package:gst_profit_app/constants/app_colors.dart';
import 'package:gst_profit_app/constants/app_values.dart';
import 'package:gst_profit_app/models/history.dart';
import 'package:gst_profit_app/services/database_service.dart';
import 'package:gst_profit_app/widgets/gradient_app_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final Function(CalculationHistory) onHistorySelect;

  const HistoryScreen({
    Key? key,
    required this.onHistorySelect,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Set<int> _selectedIndices = {};
  late bool _isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: _isMultiSelectMode
            ? 'Selected ${_selectedIndices.length}'
            : 'Calculation History',
        // show a leading checkbox during multi-select to toggle select-all
        leading: _isMultiSelectMode
            ? Checkbox(
                value: _selectedIndices.length == DatabaseService.getAllHistory().length && DatabaseService.getAllHistory().isNotEmpty,
                onChanged: (_) => _toggleSelectAll(),
              )
            : null,
        backgroundColor: AppColors.primary,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Selected',
              onPressed: _deleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: _exitMultiSelectMode,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Clear History',
              onPressed: _showClearConfirmation,
            ),
        ],
      ),
      body: ValueListenableBuilder<Box<CalculationHistory>>(
        valueListenable: DatabaseService.getHistoryListenable(),
        builder: (context, box, _) {
          final history = DatabaseService.getAllHistory();

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No History Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your calculations will appear here',
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
            itemCount: history.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final record = history[index];
              final formattedDate = DateFormat('MMM dd, yyyy').format(record.timestamp);
              final formattedTime = DateFormat('hh:mm a').format(record.timestamp);
              final isProfitable = record.netProfit >= 0;
              final isSelected = _selectedIndices.contains(index);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                elevation: isSelected ? 4 : 2,
                color: isSelected
                  ? Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round())
                  : Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: _isMultiSelectMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(index),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isProfitable
                              ? AppColors.success.withAlpha((0.2 * 255).round())
                              : AppColors.error.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isProfitable
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isProfitable
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Purchase: ${AppValues.currencySymbol}${record.purchaseValue.toStringAsFixed(2)}'),
                            Text(
                                'Sale: ${AppValues.currencySymbol}${record.salePriceWithGst.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profit: ${AppValues.currencySymbol}${record.netProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isProfitable
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: !_isMultiSelectMode
                      ? const Icon(Icons.arrow_forward_ios, size: 16)
                      : null,
                  onTap: () {
                    if (_isMultiSelectMode) {
                      _toggleSelection(index);
                    } else {
                      widget.onHistorySelect(record);
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    if (!_isMultiSelectMode) {
                      setState(() {
                        _isMultiSelectMode = true;
                        _selectedIndices.add(index);
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _toggleSelectAll() {
    final history = DatabaseService.getAllHistory();
    setState(() {
      if (_selectedIndices.length == history.length) {
        _selectedIndices.clear();
        _isMultiSelectMode = false;
      } else {
        _selectedIndices = Set.from(List.generate(history.length, (i) => i));
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Selected'),
          content: Text(
              'Are you sure you want to delete ${_selectedIndices.length} item(s)? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDelete();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performDelete() {
    final history = DatabaseService.getAllHistory();
    // Delete in reverse order to avoid index offset issues
    final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      DatabaseService.deleteHistoryRecord(history[index]);
    }

    setState(() {
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sortedIndices.length} item(s) deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to delete all history? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                DatabaseService.clearAllHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
