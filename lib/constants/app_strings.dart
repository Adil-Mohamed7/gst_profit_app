/// App string constants
class AppStrings {
  // App name
  static const String appName = 'Shop Profit Calculator';
  static const String appVersion = '1.0.0';

  // Screen titles
  static const String itemsListTitle = 'Items List';
  static const String purchaseDetailsTitle = 'Purchase Details';
  static const String salesDetailsTitle = 'Sales Details';
  static const String settingsTitle = 'Settings';
  static const String splashTitle = 'Profit Calculator';

  // Button labels
  static const String nextSalesDetails = 'Next: Sales Details';
  static const String saveItem = 'Save Item';
  static const String save = 'Save';
  static const String apply = 'Apply';
  static const String cancel = 'Cancel';
  static const String clear = 'Clear';
  static const String delete = 'Delete';
  static const String close = 'Close';
  static const String resetAll = 'Reset All';

  // Dialog titles
  static const String filterItems = 'Filter Items';
  static const String sortBy = 'Sort By';
  static const String itemDetails = 'Item Details';
  static const String addCustomGst = 'Add Custom GST';
  static const String clearCustomGstValues = 'Clear Custom GST Values';
  static const String resetAllData = 'Reset All Data';

  // Labels and placeholders
  static const String itemName = 'Item Name (Optional)';
  static const String itemNameHint = 'Enter item description';
  static const String purchaseValue = 'Purchase Value (GST included)';
  static const String gstPercentage = 'GST Percentage';
  static const String freightCharge = 'Freight Charge';
  static const String salePrice = 'Sale Price (GST included)';
  static const String salePriceWithoutGst = 'Sale Price Without GST (Optional)';
  static const String searchByName = 'Search by name, cost, etc.';
  static const String gstPercentageLabel = 'GST Percentage';

  // Helper texts
  static const String purchaseValueHelper =
      'Enter the total amount including GST';
  static const String salePriceHelper = 'Enter the total sale price including GST';
  static const String salePriceWithoutGstHelper =
      'Optional: Used for margin calculation only, not for GST calculation';

  // Empty state
  static const String noItems = 'No items yet';
  static const String addFirstItem = 'Tap + to add your first item';
  static const String noItemsToExport = 'No items to export';

  // Messages
  static const String itemSavedSuccessfully = 'Item saved successfully!';
  static const String dataExportedSuccessfully = 'Data exported successfully';
  static const String customGstValuesCleared = 'Custom GST values cleared';
  static const String allDataReset = 'All data has been reset';

  // Help texts
  static const String customGstClearMessage =
      'This will remove all custom GST values you have added. The default GST values (18% and 24%) will remain. Continue?';
  static const String resetAllDataMessage =
      'This will delete all items and custom GST values. This action cannot be undone. Continue?';

  // Settings
  static const String darkMode = 'Dark Mode';
  static const String switchTheme = 'Switch between light and dark themes';
  static const String clearGstValues = 'Clear Custom GST Values';
  static const String clearGstValuesDesc = 'Remove all custom GST values';
  static const String clearAllItems = 'Clear All Items';
  static const String clearAllItemsDesc = 'Delete all saved items';
  static const String exportData = 'Export Data';
  static const String exportDataDesc = 'Export as JSON file';
  static const String about = 'About';
  static const String aboutVersion = 'Shop Profit Calculator v1.0.0';
  static const String aboutDescription =
      'A simple app to calculate shop profits and track inventory.';

  // Sort options
  static const String date = 'Date';
  static const String name = 'Name';
  static const String ascending = 'Ascending';
  static const String descending = 'Descending';

  // Results
  static const String margin = 'Margin (Sale Price - Total Cost)';
  static const String gstExpense = 'GST Expense (Sale GST - Purchase GST)';
  static const String netProfit = 'Net Profit (Margin - GST Expense)';

  // Breakdown
  static const String purchaseBreakdown = 'Purchase Breakdown:';
  static const String salePriceBreakdown = 'Sale Price Breakdown:';
  static const String baseValue = 'Base Value:';
  static const String basePrice = 'Base Price:';
  static const String totalCost = 'Total Cost:';
  static const String saleWithGst = 'Sale Price (with GST):';
  static const String purchaseWithGst = 'Purchase Value (with GST):';
}
