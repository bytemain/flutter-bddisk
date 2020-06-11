import 'package:bddisk/pages/PathPage.dart';
import 'package:flutter/material.dart';

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
  final List<Widget> _widgetOptions = <Widget>[
    FilesPage(),
    PersonalCenter(),
    DownloaderPage(),
    PathProviderPage(title: 'Path Provider')
  ];
  final List<BottomNavigationBarItem> _bottomNavigationBarItem = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.archive),
      title: Text('文件'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text('我的'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.file_download),
      title: Text('下载'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.show_chart),
      title: Text('Path'),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
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
