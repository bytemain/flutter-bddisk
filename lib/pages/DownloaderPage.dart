import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloaderPage extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;

  DownloaderPage({Key key, this.platform}) : super(key: key);

  @override
  _DownloaderPageState createState() => new _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  final _images = [
    {
      'name': 'wKgAYVput8CAPnPWAAF3oKDVY4Q703.jpg',
      'link': 'http://acm.swust.edu.cn/group1/M00/00/10/wKgAYVput8CAPnPWAAF3oKDVY4Q703.jpg'
    },
    {
      'name': '/union/document/basic#%E4%B8%8B%E8%BD%BD%E6%8E%A5%E5%8F%A3',
      'link': 'https://pan.baidu.com/union/document/basic#%E4%B8%8B%E8%BD%BD%E6%8E%A5%E5%8F%A3'
    },
  ];

  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      print('UI Isolate Callback: $data');
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("下载"),
      ),
      body: Builder(
        builder: (context) => _isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : _permissionReady
                ? new Container(
                    child: new ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      children: _items
                          .map(
                            (item) => item.task == null
                                ? new Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      item.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
                                    ),
                                  )
                                : new Container(
                                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                                    child: InkWell(
                                      onTap: item.task.status == DownloadTaskStatus.complete
                                          ? () {
                                              _openDownloadedFile(item.task).then((success) {
                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(content: Text('无法打开该文件。')));
                                                }
                                              });
                                            }
                                          : null,
                                      child: new Stack(
                                        children: <Widget>[
                                          new Container(
                                            width: double.infinity,
                                            height: 64.0,
                                            child: new Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: new Text(
                                                    item.name,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                new Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: _buildActionForTask(item.task),
                                                ),
                                              ],
                                            ),
                                          ),
                                          item.task.status == DownloadTaskStatus.running ||
                                                  item.task.status == DownloadTaskStatus.paused
                                              ? new Positioned(
                                                  left: 0.0,
                                                  right: 0.0,
                                                  bottom: 0.0,
                                                  child: new LinearProgressIndicator(
                                                    value: item.task.progress / 100,
                                                  ),
                                                )
                                              : new Container()
                                        ].where((child) => child != null).toList(),
                                      ),
                                    ),
                                  ),
                          )
                          .toList(),
                    ),
                  )
                : new Container(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Please grant accessing storage permission to continue -_-',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          FlatButton(
                            onPressed: () {
                              _checkPermission().then((hasGranted) {
                                setState(() {
                                  _permissionReady = hasGranted;
                                });
                              });
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () {
          _requestDownload(task);
        },
        child: Row(
          children: <Widget>[
            Icon(Icons.file_download),
          ],
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        child: Row(
          children: <Widget>[
            new Icon(
              Icons.pause,
              color: Colors.red,
            ),
            Text("pause"),
          ],
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        child: Row(
          children: <Widget>[
            new Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
            Text("pause"),
          ],
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            'Ready',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('Canceled', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('Failed', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('enqueued', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      print(task.status);
      return Text("unknown status");
    }
  }

  void _requestDownload(_TaskInfo task) async {
    print(task.link);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
//      return await Permission.storage.request().isGranted;
      Permission.storage.request().isGranted.then((value) {
        print("storage permission: $value");
        if (value) {
          return true;
        } else {
          Permission.storage.isPermanentlyDenied.then((value) {
            if (value) openAppSettings();
          });
          return false;
        }
      });
    } else {
      return true;
    }
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    _tasks.addAll(_images.map((image) => _TaskInfo(name: image['name'], link: image['link'])));

    _items.add(_ItemHolder(name: 'Images'));
    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    print("_localPath" + _localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      print("create dir");
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
