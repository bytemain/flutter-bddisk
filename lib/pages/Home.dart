import 'package:bddisk/helpers/LazyIndexedStack.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'DownloaderPage.dart';
import 'FilesPage.dart';
import 'PersonalCenter.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<BottomNavigationBarItem> _bottomNavigationBarItem = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.archive),
      title: Text('文件'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.file_download),
      title: Text('下载'),
    ),
//    BottomNavigationBarItem(
//      icon: Icon(Icons.show_chart),
//      title: Text('Path'),
//    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text('我的'),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void handleShouldIndexChange() {
    if (Get.parameters.containsKey("index")) {
      setState(() {
        int number = int.parse(Get.parameters["index"]);
        if (number >= 0 && number <= _bottomNavigationBarItem.length) _selectedIndex = number;
      });
      Get.parameters.remove("index");
    }
  }

  @override
  void initState() {
    super.initState();
    handleShouldIndexChange();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleShouldIndexChange();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      FilesPage(),
      DownloaderPage(
        homeIndex: _selectedIndex,
      ),
//    PathProviderPage(title: 'Path Provider'),
      PersonalCenter(),
    ];

    return Scaffold(
      body: LazyIndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _bottomNavigationBarItem,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
