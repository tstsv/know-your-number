import 'package:flutter/material.dart';
import 'package:know_your_number/category_list.dart';
import 'package:know_your_number/config_helper.dart';
import 'package:know_your_number/transaction_list.dart';
import 'package:know_your_number/transaction_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Know your Number';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final configHelper = ConfigHelper.instance;
  int _selectedIndex = 0;
  int _selectedTransactionId = -1;

  @override
  void initState() {
    configHelper.config(locale: "en_VN", currencySymbol: "");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _transitToTransactionWidget(int selectedTransactionId) {
    setState(() {
      _selectedTransactionId = selectedTransactionId;
      _selectedIndex = 0;
    });
  }

  void _transitToCategoryWidget() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      TransactionWidget(_selectedTransactionId),
      TransactionListWidget(_transitToTransactionWidget),
      CategoryListWidget(_transitToCategoryWidget),
    ];
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
            'Know Your Number',
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
        leading: Icon(FontAwesomeIcons.piggyBank),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.piggyBank),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
