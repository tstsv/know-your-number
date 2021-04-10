import 'package:know_your_number/database.dart';

enum CategoryFrequencyType {
  daily,
  weekly,
  monthly,
}

class TransactionCategory {
  int _id;
  String _name;
  String _description;
  double _budget;
  int _frequencyIndex;

  TransactionCategory(this._id, this._name, this._description, this._budget,
      this._frequencyIndex);

  int id() => _id;
  String name() => _name;
  String description() => _description;
  double budget() => _budget;
  int frequency() => _frequencyIndex;

  Map<String, dynamic> toDatabseRow() {
    Map<String, dynamic> databaseRow = {
      DatabaseHelper.columnDescription: _description,
      DatabaseHelper.columnName: this._name,
      DatabaseHelper.columnBudget: this._budget,
      DatabaseHelper.columnFrequency: this._frequencyIndex,
    };
    if (_id != -1) {
      databaseRow['id'] = _id;
    }
    return databaseRow;
  }
}
