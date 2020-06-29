import 'package:bddisk/pages/BdOAuth2Page.dart';
import 'package:bddisk/pages/Home.dart';
import 'package:bddisk/pages/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import 'AppConfig.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.instance.requestNotificationPermissions();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
}

// ignore: missing_return
Widget loadLoginPage() {
  AppConfig.instance.token.then((token) {
    if (token == null || token.isExpired) {
      print("token is expired.");
      Get.offNamedUntil("/Login", (route) => false);
    } else {
      print("token is valid.");
      Get.offNamedUntil("/Home", (route) => false);
    }
  });
  return Scaffold(
    body: Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 40),
        Text(
          "正在登录",
          style: TextStyle(fontSize: 20),
        )
      ],
    )),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BD Disk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: "/", page: loadLoginPage),
        GetPage(
            name: '/Login',
            page: () {
              return BdOAuth2Page();
            }),
        GetPage(
            name: '/Home',
            page: () {
              return Home();
            }),
        GetPage(
            name: '/Settings',
            page: () {
              return SettingsPage();
            }),
      ],
    );
  }
}
