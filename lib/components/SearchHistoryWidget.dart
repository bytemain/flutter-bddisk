import 'package:bddisk/models/SearchHistory.dart';
import 'package:flutter/material.dart';

enum SearchHistoryEvent { insert, delete, clear, search }

typedef OnSearchHistoryEventCallback = void Function(SearchHistoryEvent event, SearchHistory history);

// ignore: must_be_immutable
class SearchHistoryWidget extends StatefulWidget {
  var historyWords = List<SearchHistory>();
  String searchKeyword;

  OnSearchHistoryEventCallback eventCallback;

  SearchHistoryWidget(this.historyWords, {this.searchKeyword, this.eventCallback});

  @override
  State<StatefulWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  var _historyWords = List<SearchHistory>();

  @override
  void initState() {
    super.initState();
    _refreshSearchHistory();
    print("SearchHistoryWidget searchKeyword: ${widget.searchKeyword}");
  }

  void _refreshSearchHistory() {
    setState(() {
      _historyWords = widget.historyWords.toList();
      if (widget.searchKeyword != null && widget.historyWords.isNotEmpty) {
        print("searchKeyword：" + widget.searchKeyword);
        _historyWords.retainWhere(
            (element) => element.keyword.toLowerCase().contains(widget.searchKeyword?.toString()?.toLowerCase()));
      }
    });
  }

  void _sendEvent(SearchHistoryEvent event, SearchHistory history) {
    widget.eventCallback(event, history);
  }

  Widget _displayClearButton() {
    if (_historyWords.isNotEmpty) {
      return FlatButton(
        textColor: Colors.blue,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
          _sendEvent(SearchHistoryEvent.clear, null);
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
    final Iterable<ListTile> tiles = _historyWords.map(
      (s) {
        return ListTile(
          title: Text(
            s.keyword,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _sendEvent(SearchHistoryEvent.delete, s);
            },
          ),
          onTap: () {
            _sendEvent(SearchHistoryEvent.search, s);
          },
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              "搜索历史",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            child: ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              children: divided,
            ),
          ),
          _displayClearButton(),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(SearchHistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshSearchHistory();
  }
}
