import 'package:bddisk/AppConfig.dart';
import 'package:bddisk/models/BdOAuth2Token.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: FutureBuilder(
          future: AppConfig.instance.token,
          builder: (context, AsyncSnapshot<BdOAuth2Token> snapshot) {
            if (snapshot.data.accessToken != null) {
              return SettingsList(
                sections: [
                  SettingsSection(
                    title: '信息',
                    tiles: [
                      SettingsTile(
                        title: "access_token",
                        leading: Icon(Icons.fingerprint),
                        subtitle: snapshot.data.accessToken,
                      )
                    ],
                  ),
                  SettingsSection(
                    title: '设置',
                    tiles: [
                      SettingsTile(
                        title: '下载线程数',
                        subtitle: '1',
                        leading: Icon(Icons.language),
                        onTap: () {},
                      ),
                      SettingsTile.switchTile(
                        title: '删除任务时删除文件',
                        leading: Icon(Icons.fingerprint),
                        switchValue: true,
                        onToggle: (bool value) {},
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
