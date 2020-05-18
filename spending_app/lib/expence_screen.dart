import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class ExpenceScreen extends StatefulWidget {
  ExpenceScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ExpenceScreen createState() => _ExpenceScreen();
}

class _ExpenceScreen extends State<ExpenceScreen>{
  List<String> _categories = ['Clothes', 'Eating Out', 'Entertainment', 'General', 'Gifts', 'Shopping', 'Travel', 'Other'];
  String _selectedCategory;
  DateTime _selectedDate;
  String _amountString;
  AudioCache _audioCache;
  final player = AudioCache();
  final List<String> transaction = [];
  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(prefix: "audio/");
  }

  Future<List> _submitData() async {
    await http.post("https://gravuur.ee/mobiilirakendused/insert.php", body: {
      "amount": _amountString,
      "calendar": DateFormat("yyyy-MM-dd").format(_selectedDate),
      "category": _selectedCategory,
      "type": '0',
    });
    Navigator.pushReplacementNamed(context, "/");
  }

  _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Insert new expence'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              new TextField(
                decoration: new InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  setState(() {
                    _amountString = double.parse(text).toStringAsFixed(2);
                  });
                },
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date Chosen!'
                            : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                      ),
                    ),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _presentDatePicker,
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child:

                DropdownButton(
                  hint: Text('Please choose a category'),
                  value: _selectedCategory,
                  isExpanded: true,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      child: new Text(category),
                      value: category,
                    );
                  }).toList(),
                ),
              ),
              RaisedButton(
                onPressed:() {_submitData(); _audioCache.play('score.mp3');},
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


