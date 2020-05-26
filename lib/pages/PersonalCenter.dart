import 'package:flutter/material.dart';

class PersonalCenter extends StatefulWidget {
  PersonalCenter({Key key}) : super(key: key);

  @override
  _PersonalCenterState createState() => _PersonalCenterState();
}

class _PersonalCenterState extends State<PersonalCenter> {
  double used = 2800;
  double all = 3220;
  Widget _buildTopWidget() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Image.asset(
                  "assets/swan_app_user_portrait_pressed.png",
                  width: 60,
                  height: 60,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "UserName",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 5),
                        Image.asset(
                          "assets/home_identity_super.png",
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                      value: used / all,
                    ),
                    Text("${used}GB/${all}GB"),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildFunctionWidget() {
    return Container(
      child: Flexible(
        child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 4 / 5,
            children: <String, String>{
              'file_add_btn_scan.png': "扫一扫",
              'file_add_btn_photo.png': "上传照片",
              'file_add_btn_video.png': "上传视频",
              'file_add_btn_note.png': "新建笔记",
              'file_add_btn_file.png': "上传文档",
              'file_add_btn_music.png': "上传音乐",
              'file_add_btn_folder.png': "新建文件夹",
              'file_add_btn_other.png': "上传其他文件",
            }.entries.map((MapEntry entry) {
              return Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      "assets/" + entry.key,
                    ),
                  ),
                  Text(entry.value, style: TextStyle(fontSize: 11))
                ],
              );
            }).toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Center"),
      ),
      body: Builder(builder: (context) {
        return Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: <Widget>[
              _buildTopWidget(),
              SizedBox(height: 100),
              _buildFunctionWidget(),
            ],
          ),
        );
      }),
    );
  }
}
