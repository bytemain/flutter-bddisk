import 'package:flutter/widgets.dart';

class LazyIndexedStack extends StatefulWidget {
  final AlignmentGeometry alignment;
  final TextDirection textDirection;
  final StackFit sizing;
  final int index;
  final bool reuse;

  final List<Widget> children;

  LazyIndexedStack(
      {Key key,
      this.alignment = AlignmentDirectional.topStart,
      this.textDirection,
      this.sizing = StackFit.loose,
      this.index,
      this.reuse = true,
      @required this.children})
      : super(key: key);

  @override
  _LazyIndexedStackState createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  List<Widget> _children;
  List<bool> _loaded;

  @override
  void initState() {
    _loaded = [];
    _children = [];
    for (int i = 0; i < widget.children.length; i++) {
      if (i == widget.index) {
        _children.add(widget.children[i]);
        _loaded.add(true);
      } else {
        _children.add(new Container());
        _loaded.add(false);
      }
    }
    super.initState();
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    if (oldWidget.index == widget.index) return;
    for (int i = 0; i < widget.children.length; i++) {
      if (i == widget.index) {
        if (!_loaded[i]) {
          _children[i] = widget.children[i];
          _loaded[i] = true;
        } else {
          if (widget.reuse) {
            return;
          }
          _children[i] = widget.children[i];
        }
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return new IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: _children,
    );
  }
}
