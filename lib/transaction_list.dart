import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:know_your_number/category.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:know_your_number/config_helper.dart';
import 'package:know_your_number/transaction.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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
  final ConfigHelper _configHelper = ConfigHelper.instance;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();
  List<int> categories;
  List<Transaction> transactions;
  final Function(int) onTransactionSelected;
  DateTime selectedDate;
  MaterialLocalizations localizations;

  _TransactionListState(this.onTransactionSelected);

  @override
  void initState() {
    selectedDate = DateTime.now();
    initLocale(_configHelper.localeObj());
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  String getLocale(
    BuildContext context, {
    Locale selectedLocale,
  }) {
    if (selectedLocale != null) {
      return '${selectedLocale.languageCode}_${selectedLocale.countryCode}';
    }
    var locale = Localizations.localeOf(context);
    if (locale == null) {
      return Intl.systemLocale;
    }
    return '${locale.languageCode}_${locale.countryCode}';
  }

  initLocale(Locale locale) async {
    localizations = locale == null
        ? MaterialLocalizations.of(context)
        : await GlobalMaterialLocalizations.delegate.load(locale);
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
            DateTime firstDateOfSelectedMonth =
                new DateTime(selectedDate.year, selectedDate.month, 1);
            DateTime lastDateOfSelectedMonth =
                new DateTime(selectedDate.year, selectedDate.month, 31);
            List<Transaction> todayTransactions =
                model.getTransactionsByDateRange(
                    todayDateOnly, todayDateOnly.add(Duration(days: 1)));
            List<Transaction> monthlyTransactions =
                model.getTransactionsByDateRange(firstDateOfSelectedMonth,
                    lastDateOfSelectedMonth.add(Duration(days: 1)));
            monthlyTransactions
                .sort((t1, t2) => t2.date().compareTo(t1.date()));

            return Material(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  ListTile(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.blue,
                      ),
                      onPressed: () => this.setState(() {
                        selectedDate = selectedDate ?? DateTime.now();
                        int prevMonth = selectedDate.month == 1
                            ? 12
                            : selectedDate.month - 1;
                        int year = selectedDate.year;
                        if (selectedDate.month == 1) {
                          year -= 1;
                        }
                        selectedDate = new DateTime(year, prevMonth);
                      }),
                    ),
                    title: Center(
                      child: TextButton(
                        onPressed: () async {
                          await showMonthPicker(
                            context: this.context,
                            initialDate: selectedDate,
                            locale: _configHelper.localeObj(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 1825)),
                            lastDate: DateTime.now(),
                          );
                          // if (dateTime != null) {
                          //   this.setState(() {
                          //     selectedDate = dateTime;
                          //   });
                          // }
                        },
                        child: Text(
                          '${DateFormat.yMMM(_configHelper.locale()).format(selectedDate ?? DateTime.now())}',
                          // ${DateFormat.'yMMM'
                          // 'yMMM', _configHelper.localeLangue(),
                          // _configHelper.localeInit(_configHelper.locale())
                          //     ? _configHelper.locale()
                          //     : "en_VN",
                          // ).format(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: selectedDate.month < today.month ||
                                selectedDate.year < today.year
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      onPressed: () => {
                        if (selectedDate.month < today.month ||
                            selectedDate.year < today.year)
                          {
                            this.setState(() {
                              int nextMonth = selectedDate.month == 12
                                  ? 1
                                  : selectedDate.month + 1;
                              int year = selectedDate.year;
                              if (selectedDate.month == 12) {
                                year += 1;
                              }
                              selectedDate = new DateTime(year, nextMonth);
                            })
                          }
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total expense today'),
                        Text(
                          todayTransactions.isEmpty
                              ? ""
                              : "-" +
                                  ConfigHelper.instance.convertToCurrencyLocale(
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
                                        ConfigHelper.instance
                                            .convertToCurrencyLocale(
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
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: monthlyTransactions.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
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
                                    bool deleteConfirmed = await showDialog<
                                                bool>(
                                            context: context,
                                            builder: (context) =>
                                                new CupertinoAlertDialog(
                                                  title:
                                                      Text("Confirm deletion?"),
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
                                                      onPressed: () =>
                                                          Navigator.pop(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  monthlyTransactions[index]
                                                      .description(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  new DateFormat('dd-MMM')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              monthlyTransactions[
                                                                      index]
                                                                  .date())),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  (monthlyTransactions[index]
                                                                  .type() ==
                                                              TransactionType
                                                                  .income
                                                          ? ""
                                                          : "-") +
                                                      ConfigHelper.instance
                                                          .convertToCurrencyLocale(
                                                              monthlyTransactions[
                                                                      index]
                                                                  .amount()),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  model
                                                          .getCategory(
                                                              monthlyTransactions[
                                                                      index]
                                                                  .categoryId())
                                                          ?.name() ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
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
                        }),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
