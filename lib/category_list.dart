import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/category_detail.dart';
import 'package:know_your_number/transaction.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

import 'config_helper.dart';
import 'model.dart';

class CategoryListWidget extends StatefulWidget {
  final Function() _functionToReselectTab;

  CategoryListWidget(this._functionToReselectTab, {Key key}) : super(key: key);

  @override
  _CategoryListState createState() =>
      _CategoryListState(_functionToReselectTab);
}

/// This is the private State class that goes with MyStatefulWidget.
class _CategoryListState extends State<CategoryListWidget> {
  final Function() _functionToReselectTab;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final transactionTypeController = TextEditingController();
  final categoryController = TextEditingController();
  List<TransactionCategory> categories = List.empty();
  List<Transaction> transactions = List.empty();
  Map<int, double> categoryTotalAmount = {};

  _CategoryListState(this._functionToReselectTab);
  int editingCategoryId = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopedModel(
        model: CategoryModel(),
        child: ScopedModelDescendant<CategoryModel>(
            rebuildOnChange: true,
            builder: (context, child, model) {
              if (categories.isEmpty) {
                Future<List<TransactionCategory>> categoriesFuture =
                    model.getCategories();
                categoriesFuture
                    .then((value) => setState(() => categories = value));
              }
              if (transactions.isEmpty) {
                Future<List<Transaction>> transactionFuture =
                    model.getTransactions();
                transactionFuture.then((value) => setState(() {
                      transactions = value;
                      categoryTotalAmount.clear();
                    }));
              }
              if (categories.isNotEmpty && transactions.isNotEmpty) {
                categories.forEach((element) {
                  List<Transaction> transactionInCategory = transactions
                      .where((t) => t.categoryId() == element.id())
                      .toList();
                  if (transactionInCategory.isNotEmpty) {
                    categoryTotalAmount.putIfAbsent(
                        element.id(),
                        () => transactionInCategory
                            .map((e) =>
                                e.amount() *
                                (e.type() == TransactionType.income ? -1 : 1))
                            .reduce((value, element) => value + element));
                  }
                });
              }
              return SingleChildScrollView(
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                        children: List<Widget>.generate(categories.length,
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
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                ),
                                              ],
                                            )) ??
                                    false;
                                if (deleteConfirmed) {
                                  ScopedModel.of<CategoryModel>(context)
                                      .deleteCategory(categories[index]);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
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
                            onTap: () async {
                              // if (categories.isNotEmpty) {
                              //   setState(() {
                              //     editingCategoryId = index;
                              //   });
                              // }
                              if (categories.isNotEmpty) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetail(
                                        categories[index],
                                        () => {
                                              this.setState(() {
                                                editingCategoryId = -1;
                                                categories.clear();
                                              })
                                            }),
                                  ),
                                );
                                this.setState(() {
                                  categories.clear();
                                });
                              }
                            },
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(categoryTotalAmount
                                                        .isEmpty ||
                                                    !categoryTotalAmount
                                                        .containsKey(
                                                            categories[index]
                                                                .id())
                                                ? ''
                                                : ConfigHelper.instance
                                                        .convertToCurrencyLocale(
                                                            categoryTotalAmount[
                                                                categories[index]
                                                                    .id()]) +
                                                    " / " +
                                                    ConfigHelper.instance
                                                        .convertToCurrencyLocale(
                                                            categories[index]
                                                                .budget())),
                                          ),
                                          Expanded(
                                              child: Text(
                                            categoryTotalAmount.isEmpty ||
                                                    !categoryTotalAmount
                                                        .containsKey(
                                                            categories[index]
                                                                .id())
                                                ? ''
                                                : NumberFormat
                                                        .decimalPercentPattern(
                                                            locale: ConfigHelper
                                                                .instance
                                                                .locale(),
                                                            decimalDigits: 2)
                                                    .format(categoryTotalAmount[
                                                            categories[index]
                                                                .id()] /
                                                        categories[index]
                                                            .budget())
                                                    .toString(),
                                            textAlign: TextAlign.right,
                                          ))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              categories[index].name(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: Text(
                                          //     categories[index].,
                                          //     overflow: TextOverflow.ellipsis,
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              ConfigHelper.instance
                                                  .convertToCurrencyLocale(
                                                categories[index].budget(),
                                              ),
                                              textAlign: TextAlign.right,
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
                    })),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetail(
                  null,
                  () => {
                        this.setState(() {
                          editingCategoryId = -1;
                          categories.clear();
                        })
                      }),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
