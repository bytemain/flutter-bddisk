import 'package:flutter/material.dart';

typedef SearchInputOnFocusCallback = void Function();
typedef SearchInputOnSubmittedCallback = void Function(String value);

// ignore: must_be_immutable
class SearchInputWidget extends StatelessWidget {
  SearchInputOnFocusCallback onTap;
  SearchInputOnSubmittedCallback onSubmitted;

  SearchInputWidget({this.onTap, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: "搜索网盘文件",
        filled: true,
        fillColor: Color.fromARGB(255, 240, 240, 240),
        contentPadding: EdgeInsets.only(left: 0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.black26,
        ),
      ),
    );
  }
}
