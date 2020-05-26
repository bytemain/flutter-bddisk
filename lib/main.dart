import 'package:flutter/material.dart';

import 'pages/FilesPage.dart';
import 'pages/LoginPage.dart';
import 'pages/PathExample.dart';
import 'pages/PersonalCenter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '百度网盘 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        /**
         * 命名导航路由，启动程序默认打开的是以'/'对应的界面LoginScreen()
         * 凡是后面使用Navigator.of(context).pushNamed('/Home')，都会跳转到Home()，
         */
        '/': (BuildContext context) => new LoginPage(),
        '/Home': (BuildContext context) => new Home(),
      },
    );
  }
}

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
    PathExample(title: 'Path Provider'),
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
      icon: Icon(Icons.terrain),
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
        items: _bottomNavigationBarItem,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
