import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'SpaceMono',
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];
  bool _showChart = false;

  @override
  void dispose() {
    _saveTransactions();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('data')) return;
    final jsonList =
        json.decode(preferences.getString('data')!) as List<String>?;
    if (jsonList == null) return;
    final transactionList = jsonList.map((value) {
      final data = json.decode(value) as Map<String, dynamic>;
      return Transaction(
        id: data['id'],
        amount: data['amount'],
        title: data['title'],
        date: DateTime.parse(data['date']),
      );
    }).toList();
    _userTransactions = transactionList;
  }

  Future<void> _saveTransactions() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('data',
        json.encode(_userTransactions.map((e) => e.getJson()).toList()));
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  Future<void> _addNewTransaction(
      String title, double amount, DateTime dateTime) async {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: dateTime,
    );
    await _saveTransactions();
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return GestureDetector(
          onTap: () => {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(addTx: _addNewTransaction),
        );
      },
    );
  }

  List<Widget> _builderLandscapeContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Chart'),
          Switch.adaptive(
              value: _showChart,
              onChanged: (val) {
                setState(() {
                  _showChart = val;
                });
              }),
        ],
      ),
      _showChart
          ? SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(recentTransaction: _userTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _builderPortraitContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      SizedBox(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.25,
        child: Chart(recentTransaction: _userTransactions),
      ),
      txListWidget
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    return FutureBuilder(
        future: _loadTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final appBar = AppBar(
            title: const Text(
              'Personal Expenses',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'SpaceMono',
              ),
            ),
            actions: <Widget>[
              IconButton(
                  onPressed: () => _startAddNewTransaction(context),
                  icon: const Icon(Icons.add)),
            ],
          );
          final txListWidget = SizedBox(
            height: (mediaQuery.size.height -
                    appBar.preferredSize.height -
                    mediaQuery.padding.top) *
                0.7,
            child: TransactionList(
              transaction: _recentTransactions,
              deleteTx: _deleteTransaction,
            ),
          );
          return Scaffold(
            appBar: appBar,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (isLandscape)
                    ..._builderLandscapeContent(
                      mediaQuery,
                      appBar,
                      txListWidget,
                    ),
                  if (!isLandscape)
                    ..._builderPortraitContent(
                      mediaQuery,
                      appBar,
                      txListWidget,
                    ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _startAddNewTransaction(context),
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
