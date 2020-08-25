import 'package:carousel_slider/carousel_slider.dart';
import 'package:closet/pages/ItemListPage.dart';
import 'package:closet/service/LocalDB.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class HorizontalList extends StatefulWidget {
  final String title;
  final bool random;
  final List<Asset> images;
  double size;
  final Function removeTitleCallBack;

  HorizontalList({this.title, this.random, this.images, this.removeTitleCallBack, this.size});

  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  double top = 0;
  double left = 0;

  bool _isModifying = false;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildRecentItems(context);
  }

  buildRecentItems(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print('Long press the container');
        setState(() {
          _isModifying = true;
        });
      },
      child: Stack(children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          width: _isModifying ? widget.size + 40 : widget.size,
          height: widget.size * 1.5,
          child: itemCarousel(context),
        ),
        ...buildModifyingOptions(context),
      ]),
    );
  }

  _showDialog(context) async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: Text('You are deleting ${widget.title}. Are you sure?'),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Yes'),
                onPressed: () {
                  widget.removeTitleCallBack(widget.title);
                  Navigator.pop(context);
                })
          ],
        ));
  }

  List<Widget> buildModifyingOptions(BuildContext context) {
    if (_isModifying == false) {
      return [Container()];
    } else {
      return [
        Positioned(
          right: 0,
          bottom: 30,
          child: IconButton(
              onPressed: () {
                print('Remove this title');
                _showDialog(context);
              },
              icon: Icon(Icons.delete_forever)),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Slider(
            value: widget.size,
            onChanged: (newSize) {
              setState(() {
                widget.size = newSize;
              });
              saveWidgetSize(widget.title, widget.size);
            },
            min: 100,
            max: 260,
            divisions: 8,
            label: '${widget.size}',
          ),
        )
      ];
    }
  }

  Widget itemCarousel(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ItemListPage(title: widget.title)));
      },
      child: widget.images.length == 0
          ? getDefaultContainer()
          : buildSlider(context),
    );
  }

  Container getDefaultContainer() {
    if (['Top', 'Shoes', 'Bottom'].contains(widget.title)) {
      return Container(
        width: widget.size,
        height: widget.size * 1.5,
        child: Image(
            fit: BoxFit.contain,
            image:
                AssetImage('asset/default/${widget.title.toLowerCase()}.jpg')),
      );
    } else {
      return Container(
        width: widget.size,
        height: widget.size * 1.5,
        color: Colors.grey[300],
      );
    }
  }

  // ignore: missing_return
  Widget buildSlider(BuildContext context) {
    return CarouselSlider.builder(
        options: CarouselOptions(
          initialPage: 0,
          autoPlay: widget.random,
          aspectRatio: 2/3,
          enlargeCenterPage: true,
        ),
        itemCount: widget.images.length,
        // ignore: missing_return
        itemBuilder: (BuildContext context, int itemIndex) {
          return AssetThumb(
            quality: 100,
            asset: widget.images[itemIndex],
            width: widget.size.round(),
            height: (widget.size * 1.5).round(),
          );
        });
  }
}
