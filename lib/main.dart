import 'package:bddisk/pages/BdOAuth2Page.dart';
import 'package:bddisk/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import 'AppConfig.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
}

// ignore: missing_return
Widget loadLoginPage(BuildContext context) {
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
        CircularProgressIndicator(strokeWidth: 4.0),
        SizedBox(height: 40),
        Text(
          "正在加载",
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
      namedRoutes: {
        /**
         * 命名导航路由，启动程序默认打开的是以'/'对应的界面LoginScreen()
         * 凡是后面使用Navigator.of(context).pushNamed('/Home')，都会跳转到Home()，
         */
        '/': GetRoute(page: loadLoginPage(context)),
        '/Login': GetRoute(page: BdOAuth2Page()),
        '/Home': GetRoute(page: Home()),
      },
    );
  }
}
