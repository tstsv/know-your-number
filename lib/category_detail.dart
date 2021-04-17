import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:know_your_number/category.dart';
import 'package:know_your_number/config_helper.dart';
import 'package:know_your_number/model.dart';
import 'package:scoped_model/scoped_model.dart';

class CategoryDetail extends StatefulWidget {
  final TransactionCategory _transactionCategory;
  final Function _returnFunction;
  CategoryDetail(this._transactionCategory, this._returnFunction);

  @override
  _CategoryDetailState createState() =>
      _CategoryDetailState(_transactionCategory, _returnFunction);
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
  int selectedCategoryFrequencyIndex = 2;

  final ConfigHelper configHelper = ConfigHelper.instance;

  _CategoryDetailState(this._transactionCategory, this._returnFunction);

  @override
  void initState() {
    if (_transactionCategory != null) {
      nameController.text = _transactionCategory.name();
      descriptionController.text = _transactionCategory.description();
      amountController.text =
          configHelper.convertToCurrencyLocale(_transactionCategory.budget());
      selectedCategoryFrequencyIndex = _transactionCategory.frequency();
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        textTheme: TextTheme(
            headline6: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'New Transaction',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              String locale =
                  ConfigHelper.instance.locale() == "vi_VN" ? "en_VN" : "vi_VN";
              ConfigHelper.instance.config(locale: locale, currencySymbol: "");
              setState(() {});
            },
            child: Text(ConfigHelper.instance.locale(),
                style: TextStyle(color: Colors.red)),
          ),
        ]),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: ScopedModel(
        model: CategoryModel(),
        child: ScopedModelDescendant<CategoryModel>(
          rebuildOnChange: true,
          builder: (context, child, model) {
            return FocusScope(
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: "Budget",
                    ),
                    onEditingComplete: _node.nextFocus,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: new List<Widget>.generate(
                      CategoryFrequencyType.values.length,
                      (index) => CupertinoButton(
                        child: Text(
                          CategoryFrequencyType.values[index]
                              .toString()
                              .substring("CategoryFrequencyType.".length),
                          style: TextStyle(
                              color: selectedCategoryFrequencyIndex == index
                                  ? Colors.blue
                                  : Colors.grey),
                        ),
                        onPressed: () {
                          selectedCategoryFrequencyIndex = index;
                          this.setState(() {});
                        },
                      ),
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      child: Text(ConfigHelper.instance.localizations().saveButtonLabel),
                      onPressed: () {
                        String newName = nameController.text;
                        String newDescription = descriptionController.text;
                        double newAmount =
                            configHelper.parseAmount(amountController.text) ??
                                0;
                        model.addCategory(new TransactionCategory(
                          _transactionCategory?.id() ?? -1,
                          newName,
                          newDescription,
                          newAmount,
                          selectedCategoryFrequencyIndex,
                        ));
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    ElevatedButton(
                      child: Text(ConfigHelper.instance.localizations().cancelButtonLabel),
                      onPressed: _returnFunction,
                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
