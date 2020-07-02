import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:bddisk/helpers/Download.dart';
import 'package:bddisk/helpers/DownloadRepository.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import '../AppConfig.dart';
import '../Constant.dart';

class _ItemHolder {
  final String name;
  final TaskInfo task;

  _ItemHolder({this.name, this.task});
}

List<Choice> choices = const <Choice>[
  const Choice("refresh", title: '刷新', icon: Icons.refresh),
  const Choice("delete_all", title: '删除所有', icon: Icons.delete_sweep),
  const Choice("test", title: 'test', icon: Icons.add),
];

class DownloaderPage extends StatefulWidget with WidgetsBindingObserver {
  final int homeIndex;

  DownloaderPage({Key key, this.homeIndex}) : super(key: key);

  @override
  _DownloaderPageState createState() => new _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  List<TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  ReceivePort _port = ReceivePort();
  Map<String, dynamic> _progress = Map();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback, stepSize: 1);

    _isLoading = true;
    _permissionReady = false;
    _prepare();
  }

  @override
  void didUpdateWidget(DownloaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
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
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      int downloaded = data[3];
      int all = data[4];
      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
          _progress[task.taskId] = {"downloaded": downloaded, "all": all};
        });
      }
      _prepare();
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static downloadCallback(String id, DownloadTaskStatus status, int progress, int downloaded, int all) {
    print('Background Isolate Callback: task: ($id) status: (${judgeDownloadStatus(status)}) progress: ($progress)');
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress, downloaded, all]);
  }

  void _select(Choice choice) async {
    switch (choice.key) {
      case "delete_all":
        print("delete_all");
        await FlutterDownloader.cancelAll();
        var query = "DELETE FROM task";
        await FlutterDownloader.loadTasksWithRawQuery(query: query);
        await _prepare();
        setState(() {});
        break;
      case "refresh":
        print("refresh");
        await _prepare();
        setState(() {});
        break;
    }
  }

  void showDownloadInfo(_ItemHolder item) => Get.bottomSheet(
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)]),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.perm_identity),
                  title: Text("taskId: ${item.task?.taskId}"),
                ),
                ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text("name: ${item.name}"),
                ),
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text("link: ${item.task?.link}".substring(0, 20) + "..."),
                  onTap: () => Get.defaultDialog(
                    title: "Link",
                    content: TextField(
                      controller: TextEditingController()..text = item.task?.link ?? "",
                      maxLines: 8,
                      onChanged: (text) => {},
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.folder),
                  title: Text("位置: ${item.task?.downloadTask?.savedDir}".substring(0, 20) + "..."),
                  onTap: () => Get.defaultDialog(
                    title: "Link",
                    content: TextField(
                      controller: TextEditingController()..text = item.task?.downloadTask?.savedDir ?? "",
                      maxLines: 3,
                      onChanged: (text) => {},
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.stars),
                  title: Text("status: ${judgeDownloadStatus(item.task?.status)}"),
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text("progress: ${item.task?.progress}"),
                ),
              ],
            ),
          ),
        ),
        isScrollControlled: true,
        ignoreSafeArea: true,
      );

  String getProgressText(_ItemHolder item) {
    Map progress = _progress[item.task.taskId] ?? {};
    int download = progress["downloaded"] ?? 0;
    int all = progress["all"] ?? 0;
    return "${filesize(download)} / ${filesize(all)}";
  }

  Widget _buildActionForItem(_ItemHolder item) {
    TaskInfo task = item.task;
    if (task.status == DownloadTaskStatus.undefined) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _requestDownload(task);
            },
            child: new Icon(Icons.file_download),
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
    } else if (task.status == DownloadTaskStatus.running) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _pauseDownload(task);
            },
            child: new Icon(
              Icons.pause,
              color: Colors.red,
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
    } else if (task.status == DownloadTaskStatus.paused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _resumeDownload(task);
            },
            child: new Icon(
              Icons.play_arrow,
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
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            '下载完成',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              showDownloadInfo(item);
            },
            child: Icon(
              Icons.info,
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
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('已取消', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('下载失败', style: new TextStyle(color: Colors.red)),
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(judgeDownloadStatus(task.status), style: new TextStyle(color: Colors.grey)),
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
    }
  }

  void _requestDownload(TaskInfo task) async {
    task.taskId = await DownloadRepository.instance.enqueue(task);
    await _prepare();
  }

  void _cancelDownload(TaskInfo task) async {
    await DownloadRepository.instance.cancel(task);
    await _prepare();
  }

  void _pauseDownload(TaskInfo task) async {
    await DownloadRepository.instance.pause(task);
    await _prepare();
  }

  void _resumeDownload(TaskInfo task) async {
    String newTaskId = await DownloadRepository.instance.resume(task);
    task.taskId = newTaskId;
    await _prepare();
  }

  void _retryDownload(TaskInfo task) async {
    String newTaskId = await DownloadRepository.instance.retry(task);
    task.taskId = newTaskId;
    await _prepare();
  }

  Future<bool> _openDownloadedFile(TaskInfo task) {
    return DownloadRepository.instance.open(task);
  }

  void _delete(TaskInfo task) async {
    _cancelDownload(task);
    await DownloadRepository.instance.delete(task);
    await _prepare();
  }

  Future<Null> _prepare() async {
    final tasks = await DownloadRepository.instance.tasks ?? [];
    _tasks = [];
    _items = [];
    int count = 0;
    _tasks.addAll(tasks.fold<List<TaskInfo>>([], (result, task) {
      if (task.status != DownloadTaskStatus.complete) {
        result.add(TaskInfo.fromDownloadTask(task));
      }
      return result;
    }));

    if (_tasks.length > 0) {
      _items.add(_ItemHolder(name: '未完成'));
      for (int i = 0; i < _tasks.length; i++) {
        _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
        count++;
      }
      _tasks.addAll(tasks.fold<List<TaskInfo>>([], (result, task) {
        if (task.status == DownloadTaskStatus.complete) {
          result.add(TaskInfo.fromDownloadTask(task));
        }
        return result;
      }));
      if (_tasks.skip(count).length > 0) {
        _items.add(_ItemHolder(name: '已完成'));
        for (int i = count; i < _tasks.length; i++) {
          _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
        }
      }
    }

    _permissionReady = await AppConfig.instance.requestStoragePermissions();

    DownloadRepository.instance.init();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("下载"),
        actions: <Widget>[
          ...choices.take(2).map(
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
                .skip(2)
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
        builder: (context) => RefreshIndicator(
          onRefresh: () {
            setState(() {
              _isLoading = true;
            });
            return _prepare();
          },
          child: Container(
            child: _isLoading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : _permissionReady
                    ? new Container(
                        child: _items.length > 0
                            ? new ListView(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                children: _items
                                    .map((item) => item.task == null
                                        ? new Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            child: Text(
                                              "${item.name}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
                                            ),
                                          )
                                        : new Container(
                                            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                                            child: InkWell(
                                              onTap: item.task.status == DownloadTaskStatus.complete
                                                  ? () {
                                                      _openDownloadedFile(item.task).then((success) {
                                                        if (!success) {
                                                          Scaffold.of(context).showSnackBar(SnackBar(
                                                            content: Text('无法打开此文件。'),
                                                          ));
                                                        }
                                                      });
                                                    }
                                                  : () => showDownloadInfo(item),
                                              child: new Stack(
                                                children: <Widget>[
                                                  new Container(
                                                    width: double.infinity,
                                                    height: 86.0,
                                                    child: new Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        new Expanded(
                                                          child: new Text(
                                                            item.name ?? "",
                                                            maxLines: 1,
                                                            softWrap: true,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        new Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: _buildActionForItem(item),
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
                                                          child: Column(
                                                            children: [
                                                              new LinearProgressIndicator(
                                                                value: item.task.progress / 100,
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text("${item.task.progress}%"),
                                                                  Text(getProgressText(item))
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : new Container(),
                                                ].where((child) => child != null).toList(),
                                              ),
                                            ),
                                          ))
                                    .toList(),
                              )
                            : Center(
                                child: Text("当前还没有下载任务哦~"),
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
                                  '请允许使用储存权限。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                                ),
                              ),
                              SizedBox(
                                height: 32.0,
                              ),
                              FlatButton(
                                onPressed: () {
                                  AppConfig.instance.requestStoragePermissions().then((hasGranted) {
                                    setState(() {
                                      _permissionReady = hasGranted;
                                    });
                                  });
                                },
                                child: Text(
                                  '重试',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
