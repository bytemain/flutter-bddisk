import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant.dart';
import '../helpers/ToastHelper.dart';

var _scaffoldKey = new GlobalKey<ScaffoldState>();

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _biggerFont = const TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  final _normalFont = const TextStyle(fontSize: 18);
  bool _obscure = true;

  String _accountText = '';
  String _pwdText = '';

  var _accountController = TextEditingController();
  var _pwdController = TextEditingController();

  @override
  initState() {
    super.initState();

    _prefs.then((value) {
      setState(() {
        _accountText = value.getString(Constant.userAccount) ?? "";
        _accountController.text = _accountText;
        _pwdText = value.getString(Constant.userPassword) ?? "";
        _pwdController.text = _pwdText;
      });
    });
  }

  // 顶部文字，图片
  Widget _buildTopWidget() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset("assets/baidu_resultlogo.png"),
          Text(
            "欢迎登录百度账号",
            style: _biggerFont,
          ),
        ],
      ),
    );
  }

  // 用户名输入框
  Widget _buildAccountEditTextField() {
    return Container(
      margin: EdgeInsets.only(top: 80),
      child: TextField(
        controller: _accountController,
        style: _normalFont,
        onChanged: (text) {
          setState(() {
            _accountText = text;
          });
        },
        decoration: InputDecoration(
          hintText: "请输入手机号/用户名/邮箱",
          filled: true,
          fillColor: Color.fromARGB(255, 240, 240, 240),
          contentPadding: EdgeInsets.only(left: 8),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // 密码输入框
  Widget _buildPwdEditTextField() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: TextField(
        controller: _pwdController,
        style: _normalFont,
        onChanged: (text) {
          setState(() {
            _pwdText = text;
          });
        },
        obscureText: _obscure,
        decoration: InputDecoration(
          hintText: "请输入密码",
          filled: true,
          fillColor: Color.fromARGB(255, 240, 240, 240),
          contentPadding: EdgeInsets.only(left: 8),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Image.asset(
              _obscure ? "assets/hide.png" : "assets/open.png",
              width: 20,
              height: 20,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  // 检测按钮是否能按下
  _getLoginButtonPressed() {
    if (_pwdText.isNotEmpty && _accountText.isNotEmpty) {
      return () {
        showDialog(
            context: this.context,
            builder: (context) {
              return AlertDialog(
                title: Text("登录提醒"),
                content: Text("账户：$_accountText\n密码：$_pwdText"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "确 认",
                      style: _normalFont,
                    ),
                    onPressed: () async {
                      ToastHelper.showToast(_scaffoldKey, "登录成功，正在进入个人中心~");
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString(Constant.userAccount, _accountText);
                      prefs.setString(Constant.userPassword, _pwdText);
                      Timer(Duration(milliseconds: 1000), () {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                        Navigator.of(context).pushNamedAndRemoveUntil('/Home', (_) => false);
                      });
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "取 消",
                      style: _normalFont,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      };
    }
    return null;
  }

  // 按钮UI
  Widget _buildLoginButton() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: RaisedButton(
        child: Text(
          "登 录",
          style: _normalFont,
        ),
        color: Colors.blue,
        disabledColor: Colors.black12,
        textColor: Colors.white,
        disabledTextColor: Colors.black12,
        onPressed: _getLoginButtonPressed(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Login Page"),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.only(left: 25, right: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildTopWidget(),
                    _buildAccountEditTextField(),
                    _buildPwdEditTextField(),
                    _buildLoginButton(),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
