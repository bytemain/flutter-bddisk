import 'package:flutter/material.dart';

class ToastHelper {
  static void showToast(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(label: 'DISMISS', onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
      ),
    );
  }
}
