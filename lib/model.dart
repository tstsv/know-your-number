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

  void addTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      dbHelper.insert(DatabaseHelper.transactionTable, transaction.toDatabseRow());
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
      var desc = element[DatabaseHelper.columnDescription];
      var type = element[DatabaseHelper.columnType];
      var amount = element[DatabaseHelper.columnAmount];
      var tranCatId = element[DatabaseHelper.columnCategoryId];
      var merchant = element[DatabaseHelper.columnMerchant];
      TransactionType tranType = TransactionType.values[type];
      return new Transaction(desc, tranType, amount, tranCatId, merchant, id: id);
    }).toList();
    return transactions;
  }
}