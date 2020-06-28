import 'package:bddisk/helpers/Download.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

import '../helpers/Utils.dart';

typedef FileOnTapCallback = void Function(BdDiskFile file);

// ignore: must_be_immutable
class FileListWidget extends StatelessWidget {
  var diskFiles = List<BdDiskFile>();
  FileOnTapCallback onFileTap;
  Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) => _buildFilesWidget();

  FileListWidget(this.diskFiles, {this.onFileTap, this.map});

  Widget _buildFolderItem(BdDiskFile file) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))),
        child: ListTile(
          leading: Image.asset(
            "assets/folder.png",
            width: 40,
            height: 40,
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(file.serverFilename),
              )
            ],
          ),
          subtitle: Text(
            Utils.getDataTime(file.serverCTime),
          ),
          trailing: Icon(Icons.chevron_right),
        ),
      ),
      onTap: () {
        if (this.onFileTap != null) this.onFileTap(file);
      },
    );
  }

  Widget renderTrailingIcon(BdDiskFile file) {
    print("this.map:");
    print(this.map);
    if (this.map != null && this.map.containsKey(file.serverFilename)) {
      return Text(judgeDownloadStatus(map[file.serverFilename].status), style: new TextStyle(color: Colors.grey));
    }
    return Icon(
      Icons.cloud_queue,
    );
  }

  Widget _buildFileItem(BdDiskFile file) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))),
        child: ListTile(
          leading: Image.asset(
            "assets/file.png",
            width: 40,
            height: 40,
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(file.serverFilename),
              )
            ],
          ),
          subtitle: Text(
            Utils.getDataTime(file.serverCTime) + "  " + filesize(file.size),
          ),
          trailing: renderTrailingIcon(file),
        ),
      ),
      onTap: () {
        if (this.onFileTap != null) this.onFileTap(file);
      },
    );
  }

  Widget _buildFilesWidget() => this.diskFiles.length == 0
      ? Column(
          children: <Widget>[
            SizedBox(
              height: 200,
            ),
            Image.asset("assets/folder.png"),
            Text("当前目录下没有文件！")
          ],
        )
      : ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (this.diskFiles[index].isDir == 1)
              return _buildFolderItem(this.diskFiles[index]);
            else
              return _buildFileItem(this.diskFiles[index]);
          },
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: this.diskFiles.length,
        );
}
