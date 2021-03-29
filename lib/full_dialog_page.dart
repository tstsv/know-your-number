import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/config_helper.dart';
import 'package:know_your_number/model.dart';
import 'package:scoped_model/scoped_model.dart';

class CategoryDetail extends StatefulWidget {
  final TransactionCategory _transactionCategory;
  final Function _returnFunction;
  final CategoryModel _model;
  CategoryDetail(this._transactionCategory, this._model, this._returnFunction);

  @override
  _CategoryDetailState createState() =>
      _CategoryDetailState(_transactionCategory, _model, _returnFunction);
}

class _CategoryDetailState extends State<CategoryDetail> {
  final FocusScopeNode _node = FocusScopeNode();

  TransactionCategory _transactionCategory;
  final Function _returnFunction;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final merchantController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();

  final CategoryModel _model;
  final ConfigHelper configHelper = ConfigHelper.instance;

  _CategoryDetailState(
      this._transactionCategory, this._model, this._returnFunction);

  @override
  void initState() {
    nameController.text = _transactionCategory.name();
    descriptionController.text = _transactionCategory.description();
    amountController.text =
        configHelper.convertToCurrencyLocale(_transactionCategory.budget());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusScope(
        node: _node,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
              ),
              onEditingComplete: _node.nextFocus,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
              ),
              onEditingComplete: _node.nextFocus,
            ),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Budget",
              ),
              onEditingComplete: _node.nextFocus,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  String newName = nameController.text;
                  String newDescription = descriptionController.text;
                  double newAmount =
                      configHelper.parseAmount(amountController.text) ?? 0;
                  _model.addCategory(new TransactionCategory(
                      _transactionCategory.id(),
                      newName,
                      newDescription,
                      newAmount));
                  _returnFunction();
                },
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                child: Text('Clear'),
                onPressed: _returnFunction,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
