import 'dart:async';

import 'package:bddisk/helpers/Prefs.dart';
import 'package:bddisk/models/BdOAuth2Token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AppConfig.dart';
import '../Constant.dart';

class BdOAuth2PageArguments {
  final String title;
  final String message;

  BdOAuth2PageArguments(this.title, this.message);
}

class BdOAuth2Page extends StatefulWidget {
  final LoginUrl;

  BdOAuth2Page({Key key, this.LoginUrl}) : super(key: key);

  @override
  _BdOAuth2PageState createState() => _BdOAuth2PageState();
}

class _BdOAuth2PageState extends State<BdOAuth2Page> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;
  bool loginSuccess = false;

  Widget refreshButton() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('正在重新加载')),
              );
              setState(() {
                isLoading = true;
              });
              controller.data?.reload();
            },
            child: const Icon(Icons.replay),
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('百度账户授权登录'),
      ),
      floatingActionButton: refreshButton(),
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            WebView(
              initialUrl: AppConfig.baiduOAuth2Url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
                print("onPageFinished" + url);

                /// 处理重新加载展示的 SnackBar
                if (!loginSuccess) Scaffold.of(context).hideCurrentSnackBar();
              },
              gestureNavigationEnabled: true,
              navigationDelegate: (NavigationRequest request) {
                var url = request.url;
                print("visit $url");
                setState(() {
                  isLoading = true;
                });
                if (_checkOAuth2Result(context, url)) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
            isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(),
          ],
        );
      }),
    );
  }

  _checkOAuth2Result(BuildContext context, String url) async {
    url = url.replaceFirst('#', '?');
    Uri uri = Uri.parse(url);
    if (uri == null) return false;

    if (uri.pathSegments.contains('login_success') && uri.queryParameters.containsKey('access_token')) {
      print("登录成功");
      var prefs = await _prefs;
      var token =
          BdOAuth2Token(uri.queryParameters['access_token'], expiresIn: int.parse(uri.queryParameters['expires_in']));
      prefs.setJson(Constant.keyBdOAuth2Token, token.toJson());

      Get.rawSnackbar(message: '登录成功！', instantInit: true);
      Timer(Duration(milliseconds: 1000), () {
        Scaffold.of(context).hideCurrentSnackBar();
        Get.offAndToNamed("/Home");
      });
      return true;
    }
    return false;
  }

  @override
  void didUpdateWidget(BdOAuth2Page oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("widget" + widget.LoginUrl);
    print("oldWidget" + oldWidget.LoginUrl);
  }
}
