import 'package:flutter_downloader/flutter_downloader.dart';

String judgeDownloadStatus(DownloadTaskStatus status) {
  if (status == DownloadTaskStatus.undefined) return "undefined";
  if (status == DownloadTaskStatus.enqueued) return "enqueued";
  if (status == DownloadTaskStatus.complete) return "complete";
  if (status == DownloadTaskStatus.canceled) return "canceled";
  if (status == DownloadTaskStatus.failed) return "failed";
  if (status == DownloadTaskStatus.paused) return "paused";
  if (status == DownloadTaskStatus.running) return "running";
  return "unknown";
}
