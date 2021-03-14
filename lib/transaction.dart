import 'package:know_your_number/category.dart';

import 'database.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction {
  int id;
  String _description;
  TransactionType _type;
  double _amount;
  int _categoryId;
  String _merchant;

  Transaction(this._description, this._type, this._amount, this._categoryId, this._merchant,
      {this.id});

  int getId() => id;
  String description() => _description;
  TransactionType type() => _type;
  double amount() => _amount;
  int categoryId() => _categoryId;
  String merchant() => _merchant;

  Map<String, dynamic> toDatabseRow() {
    Map<String, dynamic> databaseRow = {
      DatabaseHelper.columnDescription: _description,
      DatabaseHelper.columnType: this._type.index,
      DatabaseHelper.columnAmount: this._amount,
      DatabaseHelper.columnCategoryId: this._categoryId,
      DatabaseHelper.columnMerchant: this._merchant,
    };
    if (id != 0) {
      databaseRow['id'] = id;
    }
    return databaseRow;
  }
}
