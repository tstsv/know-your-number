import 'database.dart';

enum TransactionType {
  expense,
  income,
}

class Transaction {
  int id;
  int _date;
  String _description;
  TransactionType _type;
  double _amount;
  int _categoryId;
  String _merchant;

  Transaction(this._date, this._description, this._type, this._amount,
      this._categoryId, this._merchant,
      {this.id});

  int getId() => id;
  int date() => _date;
  String description() => _description;
  TransactionType type() => _type;
  double amount() => _amount;
  int categoryId() => _categoryId;
  String merchant() => _merchant;

  Map<String, dynamic> toDatabseRow() {
    Map<String, dynamic> databaseRow = {
      DatabaseHelper.columnDate: _date,
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
