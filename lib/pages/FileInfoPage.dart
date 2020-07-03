import 'package:bddisk/helpers/BdDiskApiClient.dart';
import 'package:bddisk/helpers/DownloadRepository.dart';
import 'package:bddisk/helpers/Utils.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileInfoPage extends StatefulWidget {
  final int fsId;
  final BdDiskApiClient apiClient = BdDiskApiClient();

  FileInfoPage(this.fsId, {Key key}) : super(key: key);

  @override
  _FileInfoPageState createState() => _FileInfoPageState();
}

class _FileInfoPageState extends State<FileInfoPage> {
  BdDiskFile diskFile = null;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    List<int> fsIds = List();
    fsIds.add(widget.fsId);
    widget.apiClient.getFileMetas(fsIds, thumb: 1, dLink: 1, extra: 1).then((diskFiles) {
      setState(() {
        diskFile = diskFiles[0];
        _loading = false;
      });
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return Column(
        children: <Widget>[SizedBox(height: 200), CircularProgressIndicator(strokeWidth: 4.0), Text("正在加载")],
      );
    } else {
      return diskFile != null
          ? SingleChildScrollView(
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
            )
          : Text("获取文件出错！");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${diskFile?.serverFilename ?? "加载中"}')),
      floatingActionButton: diskFile != null
          ? FloatingActionButton(
              onPressed: () {
                DownloadRepository.instance.enqueue(TaskInfo(name: '${diskFile.serverFilename}', link: diskFile.dLink));
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
                      Get.offNamedUntil("/Home?index=1", (_) => false);
                    },
                  ),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Icon(Icons.cloud_download),
              backgroundColor: Colors.green,
            )
          : null,
      body: Center(
        child: _buildBody(),
      ),
    );
  }
}
