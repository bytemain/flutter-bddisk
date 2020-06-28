import 'package:bddisk/Constant.dart';

class DownloadHistory {
  int id;
  String taskId;
  String remarks;

  DownloadHistory(this.taskId, {this.id, this.remarks});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DownloadContract.COLUMN_TASK_ID: this.taskId,
      DownloadContract.COLUMN_REMARKS: this.remarks ?? "",
    };
    if (this.id != null) map[DownloadContract.COLUMN_ID] = this.id;
    return map;
  }

  static DownloadHistory fromMap(Map<String, dynamic> map) => DownloadHistory(
        map[DownloadContract.COLUMN_TASK_ID],
        id: map[DownloadContract.COLUMN_ID],
        remarks: map[DownloadContract.COLUMN_REMARKS],
      );
}
