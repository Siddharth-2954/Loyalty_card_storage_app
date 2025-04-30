import 'package:dashboard_template/dummies/transaction.dart';
import 'package:dashboard_template/entities/transaction.dart';
import 'package:dashboard_template/helpers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    Color appBarTextColor = ColorHelper.keepOrWhite(
        Theme.of(context).primaryColor, Theme.of(context).cardColor);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Transaction History",
          style: TextStyle(color: appBarTextColor),
        ),
      ),
      body: buildListView(),
    );
  }

  ListView buildListView() {
    String? prevDay;
    final String today = DateFormat("EEE, MMM d, y").format(DateTime.now());
    final String yesterday = DateFormat("EEE, MMM d, y")
        .format(DateTime.now().add(const Duration(days: -1)));

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final Transaction transaction = transactions[index];
        final DateTime date =
            DateTime.fromMillisecondsSinceEpoch(transaction.createdMillis);
        String dateString = DateFormat("EEE, MMM d, y").format(date);

        if (today == dateString) {
          dateString = "Today";
        } else if (yesterday == dateString) {
          dateString = "Yesterday";
        }

        final bool showHeader = prevDay != dateString;
        prevDay = dateString;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (showHeader)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  dateString,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: ColorHelper.keepOrWhite(
                            Theme.of(context).primaryColor,
                            Theme.of(context).canvasColor),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            buildItem(context, date, transaction),
          ],
        );
      },
    );
  }

  Widget buildItem(
      BuildContext context, DateTime date, Transaction transaction) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(width: 20),
          buildLine(context),
          Container(
            width: 92,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Text(
              DateFormat("hh:mm a").format(date),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: buildItemInfo(transaction, context),
          ),
        ],
      ),
    );
  }

  Card buildItemInfo(Transaction transaction, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: transaction.point.isNegative
                  ? [Colors.deepOrange, Colors.red]
                  : [Colors.green, Colors.teal]),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  transaction.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                NumberFormat("###,###,#### P").format(transaction.point),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildLine(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
