import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/category_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CategorySelectionWidget extends StatefulWidget {
  final TextEditingController _categoryController;
  final Function _callback;

  CategorySelectionWidget(this._categoryController, this._callback);
  @override
  State<StatefulWidget> createState() =>
      _CategorySelectionState(_categoryController, _callback);
}

class _CategorySelectionState extends State<CategorySelectionWidget> {
  final Function _callback;
  int _currentSelectedIndex;
  TextEditingController _categoryController;
  List<TransactionCategory> _categoriesList;
  List<int> categories;

  _CategorySelectionState(this._categoryController, this._callback);

  @override
  void initState() {
    _currentSelectedIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CategoryModel>(
      model: CategoryModel(),
      child: ScopedModelDescendant<CategoryModel>(
      builder: (context, child, model) {
        _categoriesList = model.getCategories();
        categories = _categoriesList.map((t) => t.id()).toList();
        return TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            labelText: "Category",
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          readOnly: true,
          onTap: () async {
            int originalSelectedIndex = _currentSelectedIndex ?? 0;
            if (!model.done) {
              return;
            }
            _currentSelectedIndex = await showTransactionList(originalSelectedIndex);
            TransactionCategory selectedTransactionCategory =
                                  _categoriesList.firstWhere((element) =>
                                      element.id() == categories[_currentSelectedIndex ?? originalSelectedIndex]);
            _callback(selectedTransactionCategory);
          },
        );
      }),
    );
  }

  Future<int> showTransactionList(originalSelectedIndex) {
  return showModalBottomSheet<int>(
      isDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      // color: Colors.blue,
                      child: Text("Cancel"),
                      onPressed: () {
                        _currentSelectedIndex = originalSelectedIndex;
                        TransactionCategory
                            selectedTransactionCategory =
                            _categoriesList.firstWhere((element) =>
                                element.id() ==
                                categories[_currentSelectedIndex]);
                        _categoryController.text =
                            selectedTransactionCategory.getName();
                        Navigator.pop(context, _currentSelectedIndex);
                      },
                    ),
                    CupertinoButton(
                      // color: Colors.red,
                      child: Text(
                        "Done",
                        textAlign: TextAlign.end,
                      ),
                      onPressed: () {
                        Navigator.pop(context, _currentSelectedIndex);
                      },
                    ),
                  ]),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: originalSelectedIndex),
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _currentSelectedIndex = index;
                      TransactionCategory selectedTransactionCategory =
                          _categoriesList.firstWhere((element) =>
                              element.id() == categories[index]);
                      _categoryController.text =
                          selectedTransactionCategory.getName();
                    });
                  },
                  children: new List<Widget>.generate(
                      _categoriesList.length, (int index) {
                    return new Center(
                      child: new Text(_categoriesList
                          .firstWhere((element) =>
                              element.id() == categories[index])
                          .getName()),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


