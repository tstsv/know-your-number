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

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  void _showScaffold(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: Text(message),
    ));
  }

  void resetFields() {
    dateController.text = "";
    descriptionController.text = "";
    amountController.text = "";
    transactionTypeController.text = "";
    categoryController.text = "";
    merchantController.text = "";
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
                      dateController.text = dateTime != null ?
                          DateFormat().addPattern("dd-MM-yyyy").format(dateTime) : dateController.text;
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
                GestureDetector(
                    child: AbsorbPointer(
                      child: TextField(
                        controller: transactionTypeController,
                        decoration: InputDecoration(
                          labelText: "Type",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        readOnly: true,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          isDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CupertinoButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoButton(
                                          child: Text(
                                            "Done",
                                            textAlign: TextAlign.end,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ]),
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: 32.0,
                                      onSelectedItemChanged: (int index) {
                                        setState(() {
                                          _typeSelectedIndex = index;
                                          transactionTypeController.text =
                                              TransactionType.values[index]
                                                  .toString()
                                                  .split('.')
                                                  .last;
                                        });
                                      },
                                      children: new List<Widget>.generate(
                                        TransactionType.values.length,
                                        (int index) {
                                          return new Center(
                                            child: new Text(TransactionType
                                                .values[index]
                                                .toString()
                                                .split('.')
                                                .last),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    }),
                CategorySelectionWidget(
                    categoryController,
                    (_selectedCategory) => setState(() {
                          selectedTransactionCategory = _selectedCategory;
                        })),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  RaisedButton(
                    child: Text('Save'),
                    onPressed: () {
                      String description = descriptionController.text;
                      double amount =
                          double.tryParse(amountController.text) ?? 0;
                      TransactionType transactionType =
                          TransactionType.values[_typeSelectedIndex];
                      model.addTransaction(
                          new Transaction(description, transactionType, amount,
                              selectedTransactionCategory.id(), merchantController.text));
                      _showScaffold(context, "Transaction has been saved successfully");
                      setState(() {
                        resetFields();
                      });
                    },
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  RaisedButton(
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
