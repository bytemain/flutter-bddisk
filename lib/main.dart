import 'package:bddisk/pages/BdOAuth2Page.dart';
import 'package:bddisk/pages/Home.dart';
import 'package:flutter/material.dart';

import 'AppConfig.dart';

void main() => runApp(MyApp());

// ignore: missing_return
Widget loadLoginPage(BuildContext context) {
  AppConfig.instance.token.then((token) {
    if (token == null || token.isExpired) {
      print("token is expired.");
      Navigator.of(context).pushNamedAndRemoveUntil('/Login', (_) => false);
    } else {
      print("token is valid.");
      Navigator.of(context).pushNamedAndRemoveUntil('/Home', (_) => false);
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
    return MaterialApp(
      title: '百度网盘 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      navigatorKey: AppConfig.instance.navigatorKey,
      routes: {
        /**
         * 命名导航路由，启动程序默认打开的是以'/'对应的界面LoginScreen()
         * 凡是后面使用Navigator.of(context).pushNamed('/Home')，都会跳转到Home()，
         */
        '/': (BuildContext context) => loadLoginPage(context),
        '/Login': (BuildContext context) => BdOAuth2Page(),
        '/Home': (BuildContext context) => Home(),
      },
    );
  }
}
