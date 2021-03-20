import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';

import 'category_widget.dart';
import 'model.dart';

class TransactionWidget extends StatefulWidget {
  TransactionWidget({Key key}) : super(key: key);

  @override
  _TransactionState createState() => _TransactionState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _TransactionState extends State<TransactionWidget> {
  int _typeSelectedIndex = 0;
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final merchantController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  List<int> categories;
  TransactionCategory selectedTransactionCategory;

  void setDefaultValue() {
    dateController.text =
        DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
    transactionTypeController.text = 'Expense';
    descriptionController.text = "";
    amountController.text = "";
    categoryController.text = "";
    merchantController.text = "";
  }

  @override
  void initState() {
    super.initState();
    setDefaultValue();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  void _showScaffold(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: Text(message),
    ));
  }

  void resetFields() {
    setDefaultValue();
    _node.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TransactionModel>(
      model: TransactionModel(),
      child: ScopedModelDescendant<TransactionModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          return FocusScope(
            node: _node,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                              color: transactionTypeController.text == 'Expense'
                                  ? Colors.blue
                                  : Colors.grey),
                        ),
                        onPressed: () {
                          if (transactionTypeController.text != 'Expense') {
                            transactionTypeController.text = 'Expense';
                            setState(() {});
                          }
                        }),
                    CupertinoButton(
                        child: Text(
                          'Income',
                          style: TextStyle(
                              color: transactionTypeController.text == 'Income'
                                  ? Colors.blue
                                  : Colors.grey),
                        ),
                        onPressed: () {
                          if (transactionTypeController.text != 'Income') {
                            transactionTypeController.text = 'Income';
                            setState(() {});
                          }
                        }),
                  ],
                ),
                GestureDetector(
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: "Date",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        readOnly: true,
                      ),
                    ),
                    onTap: () async {
                      DateTime dateTime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 60)),
                          lastDate: DateTime.now().add(Duration(days: 60)));
                      dateController.text = dateTime != null
                          ? DateFormat()
                              .addPattern("dd-MM-yyyy")
                              .format(dateTime)
                          : dateController.text;
                    }),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                  ),
                  onEditingComplete: _node.nextFocus,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: "Amount",
                  ),
                  onEditingComplete: _node.nextFocus,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  controller: merchantController,
                  decoration: InputDecoration(
                    labelText: "Merchant",
                  ),
                  onEditingComplete: _node.nextFocus,
                ),
                CategorySelectionWidget(
                    categoryController,
                    (_selectedCategory) => setState(() {
                          selectedTransactionCategory = _selectedCategory;
                        })),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: () {
                      String description = descriptionController.text;
                      double amount =
                          double.tryParse(amountController.text) ?? 0;
                      TransactionType transactionType =
                          TransactionType.values[_typeSelectedIndex];
                      model.addTransaction(new Transaction(
                          description,
                          transactionType,
                          amount,
                          selectedTransactionCategory.id(),
                          merchantController.text));
                      _showScaffold(
                          context, "Transaction has been saved successfully");
                      setState(() {
                        resetFields();
                      });
                    },
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    child: Text('Clear'),
                    onPressed: () {
                      setState(() {
                        resetFields();
                      });
                    },
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
