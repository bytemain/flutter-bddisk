import 'package:bddisk/AppConfig.dart';
import 'package:bddisk/models/BdOAuth2Token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  int _threadNum = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: FutureBuilder(
          future: AppConfig.instance.token,
          builder: (context, AsyncSnapshot<BdOAuth2Token> snapshot) {
            if (snapshot.hasData && snapshot.data.accessToken != null) {
              return SettingsList(
                sections: [
                  SettingsSection(
                    title: '信息',
                    tiles: [
                      SettingsTile(
                        title: "access_token",
                        leading: Icon(Icons.fingerprint),
                        subtitle: snapshot.data.accessToken,
                      ),
                      SettingsTile(
                        title: "刷新信息",
                        trailing: Icon(Icons.refresh),
                      )
                    ],
                  ),
                  SettingsSection(
                    title: '设置',
                    tiles: [
                      SettingsTile(
                        title: '下载线程数',
                        subtitle: '$_threadNum',
                        leading: Icon(Icons.language),
                        onTap: () {
                          Get.defaultDialog(
                              title: "下载线程数",
                              content: TextField(
                                controller: TextEditingController()..text = '$_threadNum',
                                maxLines: 1,
                                onChanged: (text) => {_threadNum = int.tryParse(text) ?? _threadNum},
                              ));
                        },
                      ),
                      SettingsTile.switchTile(
                        title: '删除任务时删除文件',
                        leading: Icon(Icons.fingerprint),
                        switchValue: true,
                        onToggle: (bool value) {},
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: '关于',
                    tiles: [
                      SettingsTile(
                        title: '免责声明',
                        subtitle: "本作品仅用于学习交流，不得用作其他用途。",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
