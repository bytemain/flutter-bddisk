import 'package:bddisk/Constant.dart';
import 'package:bddisk/components/FilesList.dart';
import 'package:bddisk/components/SearchHistoryWidget.dart';
import 'package:bddisk/components/SearchInput.dart';
import 'package:bddisk/helpers/SearchHistoryDbHelper.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:bddisk/models/BdDiskFileStore.dart';
import 'package:bddisk/models/SearchHistory.dart';
import 'package:bddisk/pages/FilesPage.dart';
import 'package:flutter/material.dart';

import 'FileInfoPage.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  BdDiskFileStore fileStore;
  String currPath;
  String searchKeyword;

  SearchPage(this.fileStore, {this.currPath, this.searchKeyword});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchKeyword;
  String _failMsg;
  SearchState _searchState = SearchState.empty;
  var _historyWords = List<SearchHistory>();
  var _searchResult = List<BdDiskFile>();
  TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.searchKeyword != null)
      setState(() {
        _searchKeyword = widget.searchKeyword;
      });
    SearchHistoryDbHelper.queryAll().then((value) => setState(() => _historyWords = value));
  }

  void _onSearchInputSubmit(String value) {
    value = value.trim();
    if (value.isEmpty) return;
    setState(() {
      _searchKeyword = value;
      _searchState = SearchState.loading;
    });

    widget.fileStore.search(value, dir: widget.currPath, recursion: 1).then((listOfFiles) {
      setState(() {
        _searchState = SearchState.done;
        _searchResult = listOfFiles;
      });
      _onSearchHistoryEvent(SearchHistoryEvent.insert, SearchHistory(value));
    }).catchError((error) {
      setState(() {
        _failMsg = error.toString();
      });
    });
  }

  void _onOpenFile(BdDiskFile file) {
    if (file.isDir == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileInfoPage(file.fsId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilesPage(
            rootPath: file.path,
            allowPop: true,
          ),
        ),
      );
    }
  }

  void _onSearchTextChanged(String value) {
    setState(() {
      _searchKeyword = value.trim();
      _searchState = SearchState.typing;
    });
  }

  void _onSearchHistoryEvent(SearchHistoryEvent event, SearchHistory history) {
    switch (event) {
      case SearchHistoryEvent.insert:
        SearchHistoryDbHelper.insert(history).then((value) => setState(() => _historyWords.insert(0, value)));
        break;
      case SearchHistoryEvent.delete:
        SearchHistoryDbHelper.deleteById(history?.id).then((value) => setState(() => _historyWords.remove(history)));
        break;
      case SearchHistoryEvent.clear:
        SearchHistoryDbHelper.deleteAll().then((value) => setState(() => _historyWords.clear()));
        break;
      case SearchHistoryEvent.search:
        _onSearchInputSubmit(history?.keyword);
        setState(() {
          inputController.text = history?.keyword;
        });
        break;
    }
  }

  // ignore: missing_return
  Widget _buildPageBody() {
    switch (_searchState) {
      case SearchState.loading:
        return Column(
          children: <Widget>[SizedBox(height: 200), CircularProgressIndicator(strokeWidth: 4.0), Text("正在加载")],
        );
      case SearchState.typing:
      case SearchState.empty:
        return SearchHistoryWidget(
          _historyWords,
          searchKeyword: _searchKeyword,
          eventCallback: _onSearchHistoryEvent,
        );
      case SearchState.done:
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ListTile(
                title: Text(
                  "搜索结果 (${_searchResult.length})",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 500,
                child: FileListWidget(
                  _searchResult,
                  onFileTap: _onOpenFile,
                ),
              ),
            ],
          ),
        );
      case SearchState.fail:
        return Column(
          children: <Widget>[
            SizedBox(height: 200),
            IconButton(
              icon: Icon(Icons.refresh),
              iconSize: 96,
              onPressed: () {
                print("SearchState.fail");
              },
            ),
            Text(_failMsg)
          ],
        );
    }
  }

  void _onTap() {
    setState(() {
      _searchState = SearchState.typing;
    });
  }

  void _onInputClear() {
    setState(() {
      _searchKeyword = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          child: SearchInputWidget(
            autofocus: true,
            controller: inputController,
            onTap: _onTap,
            onSubmitted: _onSearchInputSubmit,
            onChanged: _onSearchTextChanged,
            onClear: _onInputClear,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 25, right: 25, top: 10),
          child: Center(
            child: _buildPageBody(),
          ),
        ),
      ),
    );
  }
}
