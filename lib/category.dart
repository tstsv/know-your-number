class TransactionCategory {
  int _id;
  String _name;
  String _description;
  double _budget;

  TransactionCategory(this._id, this._name, this._description, this._budget);

  int id() => _id;
  String getName() => _name;
  String getDescription() => _description;
  double getBudget() => _budget;
}