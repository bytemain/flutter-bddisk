import 'dart:async';
import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../AppConfig.dart';

class DownloadRepository {
  factory DownloadRepository() => _getInstance();

  static DownloadRepository get instance => _getInstance();
  static DownloadRepository _instance;

  DownloadRepository._internal();

  static DownloadRepository _getInstance() {
    if (_instance == null) {
      _instance = new DownloadRepository._internal();
    }
    return _instance;
  }

  String _localPath;

  Future<List<DownloadTask>> get tasks async {
    return await FlutterDownloader.loadTasks();
  }

  Future<Map<String, dynamic>> get tasksMap async {
    var tasks = await FlutterDownloader.loadTasks();
    Map<String, dynamic> maps = {};
    tasks.forEach((e) {
      print(e);
      maps[e.filename] = e;
    });
    return maps;
  }

  void init() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    print("_localPath $_localPath");
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> enqueue(TaskInfo task, {showNotification: true, openFileFromNotification: true, isBd: true}) async {
    String token = (await AppConfig.instance.token)?.accessToken;
    String url = isBd ? task.link + "&access_token=$token" : task.link;
    if (_localPath == null) {
      AppConfig.instance.requestStoragePermissions();
      await init();
    }
    return await FlutterDownloader.enqueue(
      url: url,
      savedDir: _localPath,
      showNotification: showNotification,
      openFileFromNotification: openFileFromNotification,
      headers: isBd ? {"User-Agent": "pan.baidu.com"} : null,
    );
  }

  void cancel(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void pause(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  Future<String> resume(TaskInfo task) async {
    return await FlutterDownloader.resume(taskId: task.taskId);
  }

  Future<String> retry(TaskInfo task) async {
    return await FlutterDownloader.retry(taskId: task.taskId);
  }

  void delete(TaskInfo task, {bool shouldDeleteContent: true}) async {
    await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: shouldDeleteContent);
  }

  Future<bool> open(TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
}

class TaskInfo {
  final String name;
  final String link;
  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;
  DownloadTask downloadTask;

  TaskInfo({this.name, this.link});

  TaskInfo.fromDownloadTask(
    DownloadTask task,
  )   : this.link = task.url,
        this.name = task.filename,
        this.taskId = task.taskId,
        this.progress = task.progress,
        this.status = task.status,
        this.downloadTask = task;
}
