import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/config_helper.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';

import 'category_widget.dart';
import 'model.dart';

class TransactionWidget extends StatefulWidget {
  final int _transactionId;
  TransactionWidget(this._transactionId, {Key key}) : super(key: key);

  @override
  _TransactionState createState() => _TransactionState(_transactionId);
}

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

  int _transactionId;
  Transaction selectedTransaction;

  _TransactionState(this._transactionId) : super();

  void setDefaultValue() async {
    dateController.text =
        DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
    transactionTypeController.text = 'Expense';
    descriptionController.text = "";
    amountController.text = "";
    categoryController.text = "";
    merchantController.text = "";
  }

  void populateTransactionData(Transaction transaction) {
    dateController.text = DateFormat()
        .addPattern("dd-MM-yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(transaction.date()));
    transactionTypeController.text = transaction.type().toString();
    descriptionController.text = transaction.description();
    amountController.text =
        ConfigHelper.instance.convertToCurrencyLocale(transaction.amount());
    merchantController.text = transaction.merchant();
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
          Transaction transaction = model.getTransaction(_transactionId);
          if (transaction != null) {
            selectedTransactionCategory =
                model.getCategory(transaction.categoryId());
            categoryController.text = selectedTransactionCategory.name();
            populateTransactionData(transaction);
          }
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
                            setState(() {
                              _typeSelectedIndex =
                                  TransactionType.expense.index;
                            });
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
                            setState(() {
                              _typeSelectedIndex = TransactionType.income.index;
                            });
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                    child: Text("Save"),
                    onPressed: () {
                      String description = descriptionController.text;
                      double amount = ConfigHelper.instance
                              .parseAmount(amountController.text) ??
                          0;
                      TransactionType transactionType =
                          TransactionType.values[_typeSelectedIndex];
                      DateTime transactionDate = DateFormat()
                          .addPattern("dd-MM-yyyy")
                          .parse(dateController.text);
                      model.addTransaction(
                        _transactionId != -1
                            ? new Transaction(
                                transactionDate.millisecondsSinceEpoch,
                                description,
                                transactionType,
                                amount,
                                selectedTransactionCategory.id(),
                                merchantController.text,
                                id: _transactionId)
                            : new Transaction(
                                transactionDate.millisecondsSinceEpoch,
                                description,
                                transactionType,
                                amount,
                                selectedTransactionCategory.id(),
                                merchantController.text),
                      );
                      _showScaffold(
                          context, "Transaction has been saved successfully");
                      setState(() {
                        _transactionId = -1;
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
                        _transactionId = -1;
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
