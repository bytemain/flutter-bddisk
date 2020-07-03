import 'dart:async';

import 'package:bddisk/helpers/UserRepository.dart';
import 'package:bddisk/models/BdDiskQuota.dart';
import 'package:bddisk/models/BdDiskUser.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Constant.dart';

class PersonalCenter extends StatefulWidget {
  final UserRepository userRepository;

  PersonalCenter({UserRepository userRepository}) : this.userRepository = userRepository ?? UserRepository();

  @override
  _PersonalCenterState createState() => _PersonalCenterState();
}

const List<Choice> choices = const <Choice>[
  const Choice("settings", title: '设置', icon: Icons.settings),
  const Choice("logout", title: '退出登录', icon: Icons.exit_to_app),
  const Choice("exit", title: '退出应用', icon: Icons.power_settings_new),
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

  @override
  void didUpdateWidget(PersonalCenter oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                  alignment: Alignment.center,
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
              SizedBox(
                width: 20,
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
          child: Column(
        children: choices.map((Choice choice) {
          return ListTile(
            leading: Icon(
              choice.icon,
              size: 24,
              color: Colors.blue,
            ),
            title: Text(choice.title),
            onTap: () => _select(choice),
          );
        }).toList(),
      )),
    );
  }

  void _select(Choice choice) {
    switch (choice.key) {
      case "logout":
        widget.userRepository.logout().then((value) {
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
            Get.offNamedUntil("/Login", (route) => false);
          });
        }, onError: (e) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('失败：' + e)),
          );
        });
        break;
      case "exit":
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
      case "settings":
        Get.toNamed("/Settings");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
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
