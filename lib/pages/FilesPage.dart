import 'dart:async';

import 'package:bddisk/Constant.dart';
import 'package:bddisk/components/FilesList.dart';
import 'package:bddisk/components/SearchInput.dart';
import 'package:bddisk/helpers/DownloadRepository.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:bddisk/models/BdDiskFileStore.dart';
import 'package:bddisk/pages/FileInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'SearchPage.dart';

// ignore: must_be_immutable
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
