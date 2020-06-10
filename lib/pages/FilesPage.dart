import 'dart:async';

import 'package:bddisk/Constant.dart';
import 'package:bddisk/components/SearchInput.dart';
import 'package:bddisk/files/FilesList.dart';
import 'package:bddisk/files/file_store/BdDiskFileStore.dart';
import 'package:bddisk/files/file_store/FileStore.dart';
import 'package:bddisk/models/DiskFile.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'SearchPage.dart';

// ignore: must_be_immutable
class FilesPage extends StatefulWidget {
  FileStore fileStore;

  // 根目录时是否允许关闭文件管理浏览页面
  bool allowPop;

  // 指定的跟目录的路径
  String rootPath;

  FilesPage({this.fileStore, this.rootPath = "/", this.allowPop = false}) {
    if (this.fileStore == null) this.fileStore = BdDiskFileStore();
  }

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  var _diskFiles = <DiskFile>[];
  String _title = '/';
  String _currPath = '/';
  String _failMsg = '';
  FilesState _filesState = FilesState.loaded;

  Future<bool> _onBackParentDir() {
    if (widget.rootPath.compareTo(_currPath) == 0 && widget.allowPop) {
      Navigator.of(context).pop();
      return Future.value(false);
    }

    _currPath = p.dirname(_currPath);
    _requestFiles();
    return Future.value(false);
  }

  void _onForwardDir(DiskFile file) {
    if (file.isDir == 0) return;
    _currPath = file.path;
    _requestFiles();
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

  _initRootPath(String path) {
    setState(() {
      widget.rootPath = path;
      _currPath = path;
    });
    _requestFiles();
  }

  Future<void> _requestFiles() async {
    setState(() {
      _filesState = FilesState.loading;
    });

    widget.fileStore.list(_currPath).then((files) {
      setState(() {
        _title = p.basenameWithoutExtension(_currPath);
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
        return FileListWidget(_diskFiles, onFileTap: _onForwardDir);
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
          title: Text(_currPath),
          elevation: 0.0,
          leading: _isAllowLeading()
              ? Container()
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
                  margin: EdgeInsets.only(left: 25, right: 25, top: 5),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: SearchInputWidget(
                          autofocus: false,
                          showCursor: false,
                          readOnly: true,
                          onTap: _onSearchInputTap,
                        ),
                      ),
                      Center(child: _buildFilesWidget()),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
