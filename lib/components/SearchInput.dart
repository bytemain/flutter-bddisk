import 'package:flutter/material.dart';

typedef SearchInputOnFocusCallback = void Function();
typedef SearchInputOnSubmittedCallback = void Function(String value);
typedef SearchInputOnChanged = void Function(String value);
typedef SearchInputOnClear = void Function();

class SearchInputWidget extends StatefulWidget {
  final SearchInputOnFocusCallback onTap;
  final SearchInputOnSubmittedCallback onSubmitted;
  final SearchInputOnChanged onChanged;
  final SearchInputOnClear onClear;
  final TextEditingController controller;

  final bool readOnly;
  final bool showCursor;
  final bool autofocus;

  SearchInputWidget({
    this.controller,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
  });

  @override
  State<StatefulWidget> createState() => _SearchInputWidgetState();
}

// ignore: must_be_immutable
class _SearchInputWidgetState extends State<SearchInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      controller: widget.controller,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
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
        suffixIcon: (widget.controller?.text?.length ?? 0) > 0
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  widget?.onClear();
                  widget.controller?.clear();
                },
              )
            : null,
      ),
    );
  }
}
