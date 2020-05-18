import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class API {
  static Future getTransactions() {
    var response = "https://gravuur.ee/mobiilirakendused/db.php";
    return http.get(response);
  }
}

class Transactions {
  int id;
  double amount;
  String calendar;
  String category;
  String type;
  String created;

  Transactions(int id, double amount, String calendar, String category, String type, String created) {
    this.id = id;
    this.amount = amount;
    this.calendar = calendar;
    this.category = category;
    this.type = type;
    this.created = created;
  }

  Transactions.fromJson(Map json)
      : id = json['id'],
        amount = json['amount'],
        calendar = json['calendar'],
        category = json['category'],
        type = json['type'],
        created = json['created'];

  Map toJson() {
    return {'id': id, 'amount': amount, 'calendar': calendar, 'category': category, 'type': type, 'created': created};
  }
}



class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen>{
  double _income = 0, _expense = 0, _balance = 0;
  var transactions = new List<Transactions>();

  @override
  void initState() {
    super.initState();
    _getTransactions();
  }

  _getTransactions() {
    API.getTransactions().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        var test = json.decode(response.body);
        for (int i = 0; i < test.length; i++) {
          if(test[i]['type'] == '0'){
            _expense += test[i]['amount'];
          } else {
            _income += test[i]['amount'];
          }
        }
        _submitData();
        transactions = list.map((model) => Transactions.fromJson(model)).toList();
      });
    });
  }

  _submitData() async{
    setState(() {
      _expense = _expense;
      _income = _income;
      _balance = _income - _expense;
    });
  }
  _deleteTransaction(id) async{
    await http.post("https://gravuur.ee/mobiilirakendused/delete.php", body: {
      "id": id.toString(),
    });
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Income: ${_income.toString() != '0.0' ? _income.toStringAsFixed(2) : '-'}',
              //Text('Income: ' + _income.toString() != '0.0' ? _income.toString() : '_income',
                style: Theme.of(context).textTheme.headline),
              Text('Expense: ${_expense.toString() != '0.0' ? _expense.toStringAsFixed(2) : '-'}',
                  style: Theme.of(context).textTheme.headline),
              Text('Balance: ${_balance.toString() != '0.0' ? _balance.toStringAsFixed(2) : '-'}',
                  style: Theme.of(context).textTheme.headline),
            ],
          ),
        ),
        Expanded(
        child: transactions.isEmpty
        ? Column(
         children: <Widget>[
           Text(
             'No transactions added yet!',
             style: Theme.of(context).textTheme.title,
           ),
           SizedBox(
             height: 10,
           ),
           Expanded(
             child: Image.asset(
               'assets/images/waiting.png'
             ),
           )
         ],
        )
        : ListView.builder(
          itemBuilder: (ctx, index) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 5,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transactions[index].type == '0' ? Colors.pink : Colors.green,
                  radius: 30,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: FittedBox(
                      child: Text(
                          '\€${transactions[index].amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
                title: Text(
                  transactions[index].category,
                  style: Theme.of(context).textTheme.title,
                ),
                subtitle: Text(
                    '${transactions[index].calendar}'
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.grey,
                  onPressed: () {
                    _deleteTransaction(transactions[index].id);
                  },
                ),
              ),
            );
          },
          itemCount: transactions.length,
          ),
        ),
      ],
    );
  }
}


