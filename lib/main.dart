import 'package:bddisk/pages/BdOAuth2Page.dart';
import 'package:bddisk/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

import 'AppConfig.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print("Native called background task: $task"); //simpleTask will be emitted here.
    print("inputData: $inputData");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager.registerOneOffTask("1", "simpleTask");
  // Periodic task registration
  Workmanager.registerPeriodicTask(
    "2",
    "simplePeriodicTask",
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: Duration(seconds: 11),
  );
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
      ],
    );
  }
}
