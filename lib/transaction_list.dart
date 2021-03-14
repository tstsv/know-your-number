import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

import 'model.dart';

class TransactionListWidget extends StatefulWidget {
  TransactionListWidget({Key key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _TransactionListState extends State<TransactionListWidget> {
  double _amount = 0.0;
  int _categorySelectedIndex = 0;
  int _typeSelectedIndex = 0;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  List<int> categories;
  List<Transaction> transactions;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  void _onItemTapped(double amount) {
    setState(() {
      _amount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: TransactionModel(),
      child: ScopedModelDescendant<TransactionModel>(
          rebuildOnChange: true,
          builder: (context, child, model) {
            List<Transaction> transactions = model.getTransactions();
            return SingleChildScrollView(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                      children: List<Widget>.generate(transactions.length,
                          (int index) {
                    return new Slidable(
                      actionExtentRatio: 0.15,
                      direction: Axis.horizontal,
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        Container(
                          height: 50,
                          // margin: EdgeInsets.all(2.0),
                          constraints: BoxConstraints(minHeight: 60),
                          child: SlideAction(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            onTap: () async {
                              bool deleteConfirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          new CupertinoAlertDialog(
                                            title: Text("Confirm deletion?"),
                                            content: Text(
                                                "Proceed to delete the transaction?"),
                                            actions: [
                                              CupertinoDialogAction(
                                                  child: Text("Yes"),
                                                  onPressed: () => {
                                                        Navigator.pop(
                                                            context, true)
                                                      }),
                                              CupertinoDialogAction(
                                                child: Text("No"),
                                                isDefaultAction: true,
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                              ),
                                            ],
                                          )) ??
                                  false;
                              if (deleteConfirmed) {
                                ScopedModel.of<TransactionModel>(context)
                                    .deleteTransaction(transactions[index]);
                              }
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )
                                ]),
                          ),
                        ),
                      ],
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 60),
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      transactions[index].description(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      new NumberFormat.currency(locale: "en_VN",symbol: "").format(transactions[index].amount()),
                                    ),
                                  ],
                                ),
                              ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }))
                ],
              ),
            );
          }),
    );
  }
}
