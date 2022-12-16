import 'package:flutter/material.dart';

import '../models/transaction.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transaction;
  final Function deleteTx;
  const TransactionList(
      {Key? key, required this.transaction, required this.deleteTx})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: transaction.isEmpty
          ? LayoutBuilder(builder: ((context, constraints) {
              return Column(
                children: <Widget>[
                  const Text(
                    'No transactions added yet!',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.7,
                    width: constraints.maxWidth * 0.75,
                    child: Image.asset(
                      'assets/images/naruto.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              );
            }))
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return TransactionItem(
                  transaction: transaction[index],
                  deleteTx: deleteTx,
                );
              },
              itemCount: transaction.length,
            ),
    );
  }
}
