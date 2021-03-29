import 'package:know_your_number/category.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';

import 'database.dart';

class TransactionModel extends Model {
  final dbHelper = DatabaseHelper.instance;

  List<TransactionCategory> _categories = [];
  List<Transaction> _transactions = [];

  TransactionModel() {
    initData();
  }

  void initData() async {
    _categories = await allBudgets();
    _transactions = await allTransactions();

    notifyListeners();
  }

  Transaction getTransaction(int id) => (id == -1 || _transactions.isEmpty)
      ? null
      : (_transactions.firstWhere((element) => element.id == id));

  void addTransaction(Transaction transaction) async {
    if (transaction.id == null || transaction.id == -1) {
      dbHelper.insert(
          DatabaseHelper.transactionTable, transaction.toDatabseRow());
    } else {
      dbHelper.update(
          DatabaseHelper.transactionTable, transaction.toDatabseRow());
    }

    notifyListeners();
  }

  void deleteTransaction(Transaction transaction) async {
    if (transaction.id != null) {
      dbHelper.delete(DatabaseHelper.transactionTable, transaction.getId());
      _transactions = await allTransactions();
    }

    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  List<TransactionCategory> getCategories() => _categories;
  List<Transaction> getTransactions() => _transactions;
  List<Transaction> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    startDate = startDate.subtract(Duration(days: 1));
    startDate = new DateTime(
        startDate.year, startDate.month, startDate.day, 23, 59, 59);
    endDate = endDate.add(Duration(days: 1));
    endDate = new DateTime(endDate.year, endDate.month, endDate.day);
    return _transactions.where((element) {
      DateTime transactionDate =
          DateTime.fromMillisecondsSinceEpoch(element.date());
      return transactionDate.isAfter(startDate) &&
          transactionDate.isBefore(endDate);
    }).toList();
  }

  TransactionCategory getCategory(int id) {
    return _categories.firstWhere((element) => element.id() == id);
  }

  Future<List<TransactionCategory>> allBudgets() async {
    var data = await dbHelper.queryAllRows(DatabaseHelper.categoryTable);
    List<TransactionCategory> budgets = data.map((element) {
      var id = element[DatabaseHelper.columnId];
      var name = element[DatabaseHelper.columnName];
      var desc = element[DatabaseHelper.columnDescription];
      var budget = element[DatabaseHelper.columnBudget];
      return new TransactionCategory(id, name, desc, budget);
    }).toList();
    return budgets;
  }

  Future<List<Transaction>> allTransactions() async {
    var data = await dbHelper.queryAllRows(DatabaseHelper.transactionTable);
    List<Transaction> transactions = data.map((element) {
      var id = element[DatabaseHelper.columnId];
      var date = element[DatabaseHelper.columnDate];
      var desc = element[DatabaseHelper.columnDescription];
      var type = element[DatabaseHelper.columnType];
      var amount = element[DatabaseHelper.columnAmount];
      var tranCatId = element[DatabaseHelper.columnCategoryId];
      var merchant = element[DatabaseHelper.columnMerchant];
      TransactionType tranType = TransactionType.values[type];
      return new Transaction(date, desc, tranType, amount, tranCatId, merchant,
          id: id);
    }).toList();
    return transactions;
  }
}

class CategoryModel extends Model {
  final dbHelper = DatabaseHelper.instance;

  List<TransactionCategory> _categories = [];
  List<Transaction> _transactions = [];

  CategoryModel() {
    initData();
  }

  void initData() async {
    notifyListeners();
  }

  TransactionCategory getCategory(int id) => (id == -1 || _categories.isEmpty)
      ? null
      : (_categories.firstWhere((element) => element.id() == id));

  Future<List<Transaction>> getTransactions() async => allTransactions();

  void addCategory(TransactionCategory category) async {
    if (category.id() == null || category.id() == -1) {
      dbHelper.insert(DatabaseHelper.categoryTable, category.toDatabseRow());
    } else {
      dbHelper.update(DatabaseHelper.categoryTable, category.toDatabseRow());
    }

    notifyListeners();
  }

  void deleteCategory(TransactionCategory category) async {
    if (category.id() != null) {
      dbHelper.delete(DatabaseHelper.categoryTable, category.id());
      _categories = await allCategories();
    }

    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Future<List<TransactionCategory>> getCategories() {
    return _categories.isEmpty ? allCategories() : _categories;
  }

  Future<List<TransactionCategory>> allCategories() async {
    var data = await dbHelper.queryAllRows(DatabaseHelper.categoryTable);
    return data.map((element) {
      var id = element[DatabaseHelper.columnId];
      var name = element[DatabaseHelper.columnName];
      var desc = element[DatabaseHelper.columnDescription];
      var budget = element[DatabaseHelper.columnBudget];
      return new TransactionCategory(id, name, desc, budget);
    }).toList();
  }

  Future<List<Transaction>> allTransactions() async {
    var data = await dbHelper.queryAllRows(DatabaseHelper.transactionTable);
    List<Transaction> transactions = data.map((element) {
      var id = element[DatabaseHelper.columnId];
      var date = element[DatabaseHelper.columnDate];
      var desc = element[DatabaseHelper.columnDescription];
      var type = element[DatabaseHelper.columnType];
      var amount = element[DatabaseHelper.columnAmount];
      var tranCatId = element[DatabaseHelper.columnCategoryId];
      var merchant = element[DatabaseHelper.columnMerchant];
      TransactionType tranType = TransactionType.values[type];
      return new Transaction(date, desc, tranType, amount, tranCatId, merchant,
          id: id);
    }).toList();
    return transactions;
  }
}
