import 'dart:async';

import 'package:bddisk/helpers/UserRepository.dart';
import 'package:bddisk/models/BdDiskQuota.dart';
import 'package:bddisk/models/BdDiskUser.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class PersonalCenter extends StatefulWidget {
  UserRepository userRepository;

  PersonalCenter({UserRepository userRepository}) : this.userRepository = userRepository ?? UserRepository();

  @override
  _PersonalCenterState createState() => _PersonalCenterState();
}

class Choice {
  const Choice(
    this.key, {
    this.title,
    this.icon,
  });

  final String key;
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice("car", title: 'Car', icon: Icons.directions_car),
  const Choice("bicycle", title: 'Bicycle', icon: Icons.directions_bike),
  const Choice("exit", title: '退出', icon: Icons.exit_to_app),
];

class _PersonalCenterState extends State<PersonalCenter> {
  double used = 2800;
  double all = 3220;
  BdDiskUser _bdDiskUser;
  BdDiskQuota _bdDiskQuota;

  @override
  void initState() {
    super.initState();
    _requestBdData();
  }

  Future<void> _requestBdData() async {
    widget.userRepository.getUserInfo().then((user) => setState(() => _bdDiskUser = user));
    widget.userRepository.getDiskQuota().then((quota) => setState(() => _bdDiskQuota = quota));
  }

  Widget _buildTopWidget() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              ClipOval(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/swan_app_user_portrait_pressed.png',
                    image: _bdDiskUser?.avatarUrl ??
                        'https://ss0.bdstatic.com/7Ls0a8Sm1A5BphGlnYG'
                            '/sys/portrait/item/45c39016.jpg',
                    width: 60,
                    height: 60,
                  ),
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
                          _bdDiskUser?.baiduName ?? '',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 5),
                        Image.asset(
                          'assets/home_identity_${_bdDiskUser?.vipType ?? 0}.png',
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
                      value: _bdDiskQuota?.percentage ?? 0.3,
                    ),
                    Text("${filesize(_bdDiskQuota?.used ?? 0)} / ${filesize(_bdDiskQuota?.total ?? 0)}"),
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

  void _select(Choice choice) {
    if (choice.key == "exit") {
      widget.userRepository.logout().then((value) {
        print("logout:" + value.toString());
        if (value.containsKey("error_code")) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('退出失败！' + value["error_msg"])),
          );
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('退出成功！')),
          );
        }
        Timer(Duration(milliseconds: 1000), () {
          Scaffold.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushNamedAndRemoveUntil('/Login', (_) => false);
        });
      }, onError: (e) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('退出失败：' + e)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(choices[0].icon),
            onPressed: () {
              _select(choices[0]);
            },
          ),
          // action button
          IconButton(
            icon: Icon(choices[1].icon),
            onPressed: () {
              _select(choices[1]);
            },
          ),
          // overflow menu
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.skip(2).map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
        title: Text("个人中心"),
      ),
      body: Builder(builder: (context) {
        return RefreshIndicator(
          onRefresh: _requestBdData,
          child: Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: <Widget>[
                _buildTopWidget(),
                SizedBox(height: 100),
                _buildFunctionWidget(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
