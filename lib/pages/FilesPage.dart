import 'dart:async';

import 'package:bddisk/Constant.dart';
import 'package:bddisk/components/FilesList.dart';
import 'package:bddisk/components/SearchInput.dart';
import 'package:bddisk/helpers/DownloadRepository.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:bddisk/models/BdDiskFileStore.dart';
import 'package:bddisk/pages/FileInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'SearchPage.dart';

List<Choice> choices = const <Choice>[
  const Choice("add_file", title: '上传', icon: Icons.add),
  const Choice("test", title: 'test', icon: Icons.edit_attributes),
];

class FilesPage extends StatefulWidget {
  final BdDiskFileStore fileStore = BdDiskFileStore();

  // 根目录时是否允许关闭文件管理浏览页面
  bool allowPop;

  // 指定的跟目录的路径
  String rootPath;

  FilesPage({this.rootPath = "/", this.allowPop = false}) {}

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  var _diskFiles = <BdDiskFile>[];
  String _currPath = '/';
  String _failMsg = '';
  FilesState _filesState = FilesState.loaded;

  Map<String, dynamic> _map;

  Future<bool> _onBackParentDir() {
    if (widget.rootPath.compareTo(_currPath) == 0 && widget.allowPop) {
      Navigator.of(context).pop();
      return Future.value(false);
    }

    _currPath = p.dirname(_currPath);
    _requestFiles();
    return Future.value(false);
  }

  void _onFileTap(BdDiskFile file) {
    if (file.isDir == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileInfoPage(file.fsId),
        ),
      );
    } else {
      _currPath = file.path;
      _requestFiles();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.rootPath != null) {
      _initRootPath(widget.rootPath);
    } else {
      _initRootPath("/");
    }
  }

  @override
  void didUpdateWidget(FilesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rootPath != null) {
      _initRootPath(widget.rootPath);
    } else {
      _initRootPath("/");
    }
  }

  _initRootPath(String path) {
    setState(() {
      widget.rootPath = path;
      _currPath = path;
    });
    _requestFiles();
  }

  Future<void> _requestFiles() async {
    var map = await DownloadRepository.instance.tasksMap;
    setState(() {
      _filesState = FilesState.loading;
      _map = map;
    });

    widget.fileStore.list(_currPath).then((files) {
      setState(() {
        _diskFiles = files;
        _filesState = FilesState.loaded;
      });
    }, onError: (e) {
      setState(() {
        _filesState = FilesState.fail;
        _failMsg = e.toString();
      });
    });
  }

  bool _isAllowLeading() {
    if (widget.rootPath == null) return false;
    return widget.rootPath.compareTo(_currPath) == 0 && !widget.allowPop;
  }

  // ignore: missing_return
  Widget _buildFilesWidget() {
    switch (_filesState) {
      case FilesState.loading:
        return Column(
          children: <Widget>[SizedBox(height: 200), CircularProgressIndicator(strokeWidth: 4.0), Text("正在加载")],
        );
      case FilesState.loaded:
        return FileListWidget(
          _diskFiles,
          onFileTap: _onFileTap,
          map: _map,
        );
      case FilesState.fail:
        return Column(
          children: <Widget>[
            SizedBox(height: 200),
            IconButton(
              icon: Icon(Icons.refresh),
              iconSize: 96,
              onPressed: _requestFiles,
            ),
            Text(_failMsg)
          ],
        );
    }
  }

  void _onSearchInputTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(widget.fileStore, currPath: _currPath)),
    );
  }

  void _select(Choice choice) async {
    switch (choice.key) {
      case "add_file":
        print("add_file");
        Get.bottomSheet(Container(
          margin: const EdgeInsets.only(top: 25, left: 10, right: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)]),
          child: Flexible(
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 4 / 5,
                children: <String, String>{
                  'file_add_btn_scan.png': "扫一扫",
                  'file_add_btn_photo.png': "上传照片",
                  'file_add_btn_video.png': "上传视频",
                  'file_add_btn_note.png': "新建笔记",
                  'file_add_btn_file.png': "上传文档",
                  'file_add_btn_music.png': "上传音乐",
                  'file_add_btn_folder.png': "新建文件夹",
                  'file_add_btn_other.png': "上传其他文件",
                }.entries.map((MapEntry entry) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(9),
                        child: Image.asset(
                          "assets/" + entry.key,
                        ),
                      ),
                      Text(entry.value, style: TextStyle(fontSize: 12))
                    ],
                  );
                }).toList()),
          ),
        ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currPath == "/" ? "根目录" : _currPath),
        elevation: 0.0,
        automaticallyImplyLeading: true,
        leading: _isAllowLeading()
            ? null
            : IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black),
                onPressed: _onBackParentDir,
              ),
        actions: <Widget>[
          ...choices.take(1).map(
                (Choice choice) => Tooltip(
                  message: choice.title,
                  child: IconButton(
                    icon: Icon(choice.icon),
                    onPressed: () {
                      _select(choice);
                    },
                  ),
                ),
              ),
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) => choices
                .skip(1)
                .map(
                  (Choice choice) => PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          size: 24,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(choice.title),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return RefreshIndicator(
            onRefresh: _requestFiles,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: SearchInputWidget(
                          autofocus: false,
                          showCursor: false,
                          readOnly: true,
                          onTap: _onSearchInputTap,
                        ),
                      ),
                    ),
                    Center(child: _buildFilesWidget()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
