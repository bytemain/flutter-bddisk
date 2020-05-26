import 'package:flutter/material.dart';

import '../components/SearchInput.dart';
import '../files/file_store/FileStore.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  FileStore fileStore;
  String currPath;
  SearchPage(this.fileStore, {this.currPath});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<String> _list = List<String>();
  var inputText = "";

  void _onSearchInputSubmit(String value) {
    setState(() {
      if (value.isNotEmpty) _list.insert(0, value);
    });
  }

  Widget _displayClearButton() {
    if (_list.isNotEmpty) {
      return FlatButton(
        textColor: Colors.blue,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
          setState(() {
            _list.clear();
          });
        },
        child: Text(
          "清除历史记录",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }
    return SizedBox(
      height: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = _list.map(
      (s) {
        return ListTile(
          title: Text(
            s,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _list.remove(s);
              });
            },
          ),
          onTap: () {
            setState(() {
              inputText = s;
            });
          },
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
      appBar: AppBar(
          title: SafeArea(
        child: Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: SearchInputWidget(
                  onSubmitted: _onSearchInputSubmit,
                ),
              ),
            ],
          ),
        ),
      )),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25, top: 10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                "搜索历史",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: divided,
              ),
            ),
            _displayClearButton()
          ],
        ),
      ),
    );
  }
}
