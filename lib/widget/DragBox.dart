import 'package:closet/service/LocalDB.dart';
import 'package:flutter/material.dart';

class DragBox extends StatefulWidget {
  final Widget inputWidget;
  final String title;

  DragBox(this.title, this.inputWidget);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    _getInitOffSet();
  }

  _getInitOffSet() async {
    Offset tmp = await loadOffset(widget.title);
    setState(()  {
      position = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget tmp = widget.inputWidget;
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          child: tmp,
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = Offset(offset.dx, offset.dy - 84);
            });
            saveOffset(widget.title, position);
          },
          childWhenDragging: Container(),
          feedback: tmp,
        ));
  }
}
