import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'data_model/all_models.dart';

class AccountStorage {
  static final AccountStorage _instance = AccountStorage._internal();

  factory AccountStorage() => _instance;

  AccountStorage._internal();

  List<Customer> customers = [];
  List<Part> parts = [];
  List<Invoice> invoices = [];
  List<Expense> expenses = [];
  AccountingSettings settings = AccountingSettings.defaultSettings();

  // ---------------------------
  // Files
  // ---------------------------
  Future<File> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  Future<File> _invoiceFile() => _file('invoices.json');

  Future<File> _expenseFile() => _file('expenses.json');

  Future<File> _settingsFile() => _file('settings.json');

  Future<File> _customersFile() => _file('customers.json');

  Future<File> _partsFile() => _file('parts.json');

  // ---------------------------
  // SAVE
  // ---------------------------
  Future<void> saveInvoices() async {
    final f = await _invoiceFile();
    await f.writeAsString(jsonEncode(invoices.map((i) => i.toJson()).toList()));
  }

  Future<void> saveExpenses() async {
    final f = await _expenseFile();
    await f.writeAsString(jsonEncode(expenses.map((e) => e.toJson()).toList()));
  }

  Future<void> saveSettings() async {
    final f = await _settingsFile();
    await f.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<void> saveCustomers() async {
    final f = await _customersFile();
    await f
        .writeAsString(jsonEncode(customers.map((c) => c.toJson()).toList()));
  }

  Future<void> saveParts() async {
    final f = await _partsFile();
    await f.writeAsString(jsonEncode(parts.map((p) => p.toJson()).toList()));
  }

  // ---------------------------
  // LOAD
  // ---------------------------
  Future<void> load() async {
    await _loadSettings();
    await _loadCustomers();
    await _loadParts();
    await _loadInvoices();
    await _loadExpenses();
  }

  Future<void> _loadSettings() async {
    try {
      final f = await _settingsFile();
      if (await f.exists()) {
        settings =
            AccountingSettings.fromJson(jsonDecode(await f.readAsString()));
      } else {
        settings = AccountingSettings.defaultSettings();
      }
    } catch (_) {
      settings = AccountingSettings.defaultSettings();
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final f = await _customersFile();
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString());
        customers = (data as List).map((c) => Customer.fromJson(c)).toList();
      }
    } catch (_) {}
  }

  Future<void> _loadParts() async {
    try {
      final f = await _partsFile();
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString());
        parts = (data as List).map((p) => Part.fromJson(p)).toList();
      }
    } catch (_) {}
  }

  Future<void> _loadInvoices() async {
    try {
      final f = await _invoiceFile();
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString());
        invoices = (data as List).map((i) => Invoice.fromJson(i)).toList();
      }
    } catch (_) {}
  }

  Future<void> _loadExpenses() async {
    try {
      final f = await _expenseFile();
      if (await f.exists()) {
        final data = jsonDecode(await f.readAsString());
        expenses = (data as List).map((e) => Expense.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  // ---------------------------
  // Numbers
  // ---------------------------
  Future<String> nextInvoiceNumber() async {
    final number =
        "${settings.invoicePrefix}-${settings.nextInvoiceNumber.toString().padLeft(4, '0')}";
    settings = AccountingSettings(
        businessName: settings.businessName,
        engineerName: settings.engineerName,
        businessAddress: settings.businessAddress,
        businessEmail: settings.businessEmail,
        businessPhone: settings.businessPhone,
        vatRegistered: settings.vatRegistered,
        vatNumber: settings.vatNumber,
        invoicePrefix: settings.invoicePrefix,
        nextInvoiceNumber: settings.nextInvoiceNumber + 1,
        nextApiInvoiceNumber: settings.nextApiInvoiceNumber,
        nextEstimateNumber: settings.nextEstimateNumber,
        nextApiBillNumber: settings.nextApiBillNumber,
        logoPath: settings.logoPath != number ? settings.logoPath : "",
        gasSafeNumber: settings.gasSafeNumber,
        postalCode: settings.postalCode,
        paymentDetails: settings.paymentDetails);
    await saveSettings();
    return number;
  }

  Future<String> nextApiInvoiceNumber() async {
    final number =
        "${settings.invoicePrefix}-${settings.nextApiInvoiceNumber.toString().padLeft(4, '0')}";
    settings = AccountingSettings(
        businessName: settings.businessName,
        engineerName: settings.engineerName,
        businessAddress: settings.businessAddress,
        businessEmail: settings.businessEmail,
        businessPhone: settings.businessPhone,
        vatRegistered: settings.vatRegistered,
        vatNumber: settings.vatNumber,
        invoicePrefix: settings.invoicePrefix,
        nextInvoiceNumber: settings.nextInvoiceNumber,
        nextApiInvoiceNumber: settings.nextApiInvoiceNumber,
        nextApiBillNumber: settings.nextApiBillNumber,
        nextEstimateNumber: settings.nextEstimateNumber,
        logoPath: settings.logoPath != null ? settings.logoPath : "",
        gasSafeNumber: settings.gasSafeNumber,
        postalCode: settings.postalCode,
        paymentDetails: settings.paymentDetails
    );
    await saveSettings();
    return number;
  }

  Future<String> nextBillNumber() async {
    final number =
        "BL-${settings.nextApiBillNumber.toString().padLeft(4, '0')}";
    settings = AccountingSettings(
        businessName: settings.businessName,
        engineerName: settings.engineerName,
        businessAddress: settings.businessAddress,
        businessEmail: settings.businessEmail,
        businessPhone: settings.businessPhone,
        vatRegistered: settings.vatRegistered,
        vatNumber: settings.vatNumber,
        invoicePrefix: settings.invoicePrefix,
        nextInvoiceNumber: settings.nextInvoiceNumber,
        nextApiInvoiceNumber: settings.nextApiInvoiceNumber,
        nextApiBillNumber: settings.nextApiBillNumber + 1,
        nextEstimateNumber: settings.nextEstimateNumber,
        logoPath: settings.logoPath != number ? settings.logoPath : "",
        gasSafeNumber: settings.gasSafeNumber,
        postalCode: settings.postalCode,
        paymentDetails: settings.paymentDetails
    );
    await saveSettings();
    return number;
  }

  Future<String> nextEstimateNumber() async {
    final number =
        "EST-${settings.nextEstimateNumber.toString().padLeft(4, '0')}";
    settings = AccountingSettings(
        businessName: settings.businessName,
        engineerName: settings.engineerName,
        businessAddress: settings.businessAddress,
        businessEmail: settings.businessEmail,
        businessPhone: settings.businessPhone,
        vatRegistered: settings.vatRegistered,
        vatNumber: settings.vatNumber,
        invoicePrefix: settings.invoicePrefix,
        nextInvoiceNumber: settings.nextInvoiceNumber,
        nextApiInvoiceNumber: settings.nextApiInvoiceNumber,
        nextEstimateNumber: settings.nextEstimateNumber + 1,
        nextApiBillNumber: settings.nextApiBillNumber,
        logoPath: settings.logoPath != number ? settings.logoPath : "",
        gasSafeNumber: settings.gasSafeNumber,
        postalCode: settings.postalCode,
        paymentDetails: settings.paymentDetails
    );
    await saveSettings();
    return number;
  }

  // ---------------------------
  // CRUD helper methods
  // ---------------------------
  Future<void> saveInvoice(Invoice invoice) async {
    invoices.removeWhere((i) => i.id == invoice.id);
    invoices.add(invoice);
    await saveInvoices();
  }

  Future<void> deleteInvoice(String id) async {
    invoices.removeWhere((i) => i.id == id);
    await saveInvoices();
  }

  Future<void> saveExpense(Expense expense) async {
    final index = expenses.indexWhere((e) => e.id == expense.id);

    if (index != -1) {
      // ✅ Update existing
      expenses[index] = expense;
    } else {
      // ➕ Add new
      expenses.add(expense);
    }

    await saveExpenses();
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    await saveExpenses();
  }

  Future<void> saveCustomer(Customer customer) async {
    customers.removeWhere((c) => c.id == customer.id);
    customers.add(customer);
    await saveCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    customers.removeWhere((c) => c.id == id);
    await saveCustomers();
  }

  Future<void> savePart(Part part) async {
    parts.removeWhere((p) => p.id == part.id);
    parts.add(part);
    await saveParts();
  }

  Future<void> deletePart(String id) async {
    parts.removeWhere((p) => p.id == id);
    await saveParts();
  }
}
