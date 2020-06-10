import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

import '../helpers/Utils.dart';
import '../models/DiskFile.dart';

typedef FileOnTapCallback = void Function(DiskFile file);

// ignore: must_be_immutable
class FileListWidget extends StatelessWidget {
  var diskFiles = List<DiskFile>();
  FileOnTapCallback onFileTap;
  @override
  Widget build(BuildContext context) => _buildFilesWidget();

  FileListWidget(this.diskFiles, {this.onFileTap});

  Widget _buildFolderItem(DiskFile file) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))),
        child: ListTile(
          leading: Image.asset("assets/folder.png"),
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

  Widget _buildFileItem(DiskFile file) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))),
        child: ListTile(
          leading: Image.asset("assets/file.png"),
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
