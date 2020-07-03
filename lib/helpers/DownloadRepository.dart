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
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> enqueue(String downloadUrl, String fileName,
      {showNotification: true, openFileFromNotification: true, isBd: true}) async {
    String token = (await AppConfig.instance.token)?.accessToken;
    String url = isBd ? downloadUrl + "&access_token=$token" : downloadUrl;
    if (_localPath == null) {
      AppConfig.instance.requestStoragePermissions();
      await init();
    }
    return await FlutterDownloader.enqueue(
      url: url,
      fileName: fileName,
      savedDir: _localPath,
      showNotification: showNotification,
      openFileFromNotification: openFileFromNotification,
      headers: isBd ? {"User-Agent": "pan.baidu.com"} : null,
    );
  }

  void cancel(DownloadTask task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void pause(DownloadTask task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  Future<String> resume(DownloadTask task) async {
    return await FlutterDownloader.resume(taskId: task.taskId);
  }

  Future<String> retry(DownloadTask task) async {
    return await FlutterDownloader.retry(taskId: task.taskId);
  }

  void delete(DownloadTask task, {bool shouldDeleteContent: true}) async {
    await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: shouldDeleteContent);
  }

  Future<bool> open(DownloadTask task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
}
