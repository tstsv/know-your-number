import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

import 'model.dart';

class TransactionListWidget extends StatefulWidget {
  final Function(int) onTransactionSelected;

  TransactionListWidget(this.onTransactionSelected, {Key key})
      : super(key: key);

  @override
  _TransactionListState createState() =>
      _TransactionListState(onTransactionSelected);
}

/// This is the private State class that goes with MyStatefulWidget.
class _TransactionListState extends State<TransactionListWidget> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();
  List<int> categories;
  List<Transaction> transactions;
  final Function(int) onTransactionSelected;

  _TransactionListState(this.onTransactionSelected);

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

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: TransactionModel(),
      child: ScopedModelDescendant<TransactionModel>(
          rebuildOnChange: true,
          builder: (context, child, model) {
            DateTime today = DateTime.now();
            DateTime todayDateOnly =
                new DateTime(today.year, today.month, today.day);
            DateTime firstDateOfThisMonth =
                new DateTime(today.year, today.month, 1);
            List<Transaction> todayTransactions =
                model.getTransactionsByDateRange(
                    todayDateOnly, todayDateOnly.add(Duration(days: 1)));
            List<Transaction> monthlyTransactions =
                model.getTransactionsByDateRange(
                    firstDateOfThisMonth, todayDateOnly.add(Duration(days: 1)));
            monthlyTransactions
                .sort((t1, t2) => t1.date().compareTo(t2.date()));
            return SingleChildScrollView(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                      children: List<Widget>.generate(
                          monthlyTransactions.length, (int index) {
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
                                    .deleteTransaction(
                                        monthlyTransactions[index]);
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
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 0,
                          ),
                        ),
                        child: ListTile(
                          enabled: true,
                          onTap: () {
                            onTransactionSelected(
                                monthlyTransactions[index].id);
                          },
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        monthlyTransactions[index]
                                            .description(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        new DateFormat('dd-MMM').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                monthlyTransactions[index]
                                                    .date())),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        (monthlyTransactions[index].type() ==
                                                    TransactionType.income
                                                ? ""
                                                : "-") +
                                            new NumberFormat.currency(
                                                    locale: "vi_VN", symbol: "")
                                                .format(
                                                    monthlyTransactions[index]
                                                        .amount()),
                                        textAlign: TextAlign.right,
                                      ),
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
                  })),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total expense today'),
                              Text(
                                todayTransactions.isEmpty
                                    ? ""
                                    : "-" +
                                        new NumberFormat.currency(
                                                locale: "vi_VN", symbol: "")
                                            .format(
                                          todayTransactions.isEmpty
                                              ? 0.00
                                              : todayTransactions
                                                  .where((element) =>
                                                      element.type() ==
                                                      TransactionType.expense)
                                                  .map((t) => t.amount())
                                                  .reduce((value, element) =>
                                                      value + element),
                                        ),
                              ),
                            ],
                          ),
                        ),
                        // ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total expense this month'),
                              Text(
                                monthlyTransactions.isEmpty
                                    ? ""
                                    : "-" +
                                        new NumberFormat.currency(
                                                locale: "vi_VN", symbol: "")
                                            .format(
                                          monthlyTransactions.isEmpty
                                              ? 0.00
                                              : monthlyTransactions
                                                  .where((t) =>
                                                      t.type() ==
                                                      TransactionType.expense)
                                                  .map((t) => t.amount())
                                                  .reduce((value, element) =>
                                                      value + element),
                                        ),
                              ),
                            ],
                          ),
                        ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
