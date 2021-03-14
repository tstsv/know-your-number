import 'package:know_your_number/category.dart';
import 'package:scoped_model/scoped_model.dart';

import 'database.dart';

class CategoryModel extends Model {
  final dbHelper = DatabaseHelper.instance;
  bool done = false;

  List<TransactionCategory> _categories;

  CategoryModel() {
    done = false;
    initData();
  }

  void initData() async {
    if (_categories == null) {
      _categories = [];
    }
    _categories = await allCategories();
    done = true;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  List<TransactionCategory> getCategories() => _categories;

  TransactionCategory getCategory(int id) {
    return _categories.firstWhere((element) => element.id() == id);
  }

  Future<List<TransactionCategory>> allCategories() async {
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
}