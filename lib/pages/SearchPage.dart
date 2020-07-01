import 'package:bddisk/Constant.dart';
import 'package:bddisk/components/FilesList.dart';
import 'package:bddisk/components/SearchHistoryWidget.dart';
import 'package:bddisk/components/SearchInput.dart';
import 'package:bddisk/helpers/BdDiskApiClient.dart';
import 'package:bddisk/helpers/DownloadRepository.dart';
import 'package:bddisk/helpers/SearchHistoryDbHelper.dart';
import 'package:bddisk/helpers/Utils.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:bddisk/models/BdDiskFileStore.dart';
import 'package:bddisk/models/SearchHistory.dart';
import 'package:bddisk/pages/FilesPage.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  BdDiskFileStore fileStore;
  String currPath;
  String searchKeyword;
  final BdDiskApiClient apiClient = BdDiskApiClient();

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
      List<int> fsIds = List();
      fsIds.add(file.fsId);
      widget.apiClient.getFileMetas(fsIds, thumb: 1, dLink: 1, extra: 1).then((diskFiles) {
        BdDiskFile diskFile = diskFiles[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('${diskFile.serverFilename}')),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  DownloadRepository.instance
                      .enqueue(TaskInfo(name: '${diskFile.serverFilename}', link: diskFile.dLink));
                  Get.rawSnackbar(
                    message: "开始下载~",
                    onTap: (GetBar snack) {
                      snack.show();
                    },
                    shouldIconPulse: true,
                    mainButton: FlatButton(
                      child: Text(
                        "查看",
                        style: TextStyle(color: Colors.lightBlue, fontSize: 14),
                      ),
                      onPressed: () {
                        Get.toNamed("/Home?index=1");
                      },
                    ),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Icon(Icons.cloud_download),
                backgroundColor: Colors.green,
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.local_play),
                        title: Text('${diskFile.path}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("创建时间："),
                        subtitle: Text("${Utils.getDataTime(diskFile.serverCTime)}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("修改时间："),
                        subtitle: Text("${Utils.getDataTime(diskFile.serverMTime)}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text("文件大小："),
                        subtitle: Text(filesize(diskFile.size ?? 0)),
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text("下载链接："),
                        subtitle: Text("${diskFile.dLink}"),
                        isThreeLine: true,
                      ),
                      ListTile(
                        leading: Icon(Icons.apps),
                        title: Text("分类："),
                        subtitle: Text("${diskFile.category}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.confirmation_number),
                        title: Text("文件md5："),
                        subtitle: Text("${diskFile.md5}"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
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
