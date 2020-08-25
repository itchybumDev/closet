import 'dart:io';

import 'package:closet/pages/ImageFullScreen.dart';
import 'package:closet/pages/MyHomePage.dart';
import 'package:closet/service/LocalDB.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ItemListPage extends StatefulWidget {
  final String title;

  const ItemListPage({Key key, this.title}) : super(key: key);

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  bool _random = false;

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  final _delimiter = '#@';

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5000,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Closet",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // ignore: unrelated_type_equality_checks
      images = resultList.length != 0 ? resultList : images;
      _error = error;
    });
    if (resultList.length != 0) {
      _saveImage();
    }
    return;
  }

  _loadImage() async {
    print('Loading Images from DB');
    List<String> tmp = await loadImageFromDB(widget.title);
    List<Asset> tmpAsset = tmp.map((img) {
      List<String> idString = img.split(_delimiter);
      return Asset(idString[0], idString[1], int.parse(idString[2]), int.parse(idString[3]));
    }).toList();

    setState(() {
      images = tmpAsset;
    });
  }

  _saveImage() {
    print('Saving Images to DB');
    List<String> dbString = images
        .map((e) =>
            e.identifier +
            _delimiter +
            e.name +
            _delimiter +
            e.originalWidth.toString() +
            _delimiter +
            e.originalHeight.toString())
        .toList();
    saveToImageDb(widget.title, dbString);
  }

  clearAll() {
    images = [];
    saveToImageDb(widget.title, []);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title == '' ? IconButton(icon: Icon(Icons.text_fields), onPressed: () {
          print("add name");
        },) : Text(widget.title),
        elevation: 0.0,
        leading: IconButton(
          icon: Platform.isIOS
              ? Icon(Icons.arrow_back_ios)
              : Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              clearAll();
            },
            icon: Icon(Icons.clear_all),
          ),
          IconButton(
            onPressed: () {
              print('Adding item');
              loadAssets();
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: buildBody(context),
    );
  }

  buildBody(BuildContext context) {
    return GridView.builder(
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2 /*(orientation == Orientation.portrait) ? 2 : 3*/),
      itemBuilder: (BuildContext context, int index) {
        return Stack(children: <Widget>[
          new Card(
            child: new GridTile(
                child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImageFullScreen(
                        asset: images,
                        index: index,
                        loadAssetCallBack: loadAssets)));
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0)),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: AssetThumb(
                  quality: 100,
                  asset: images[index],
                  width: MediaQuery.of(context).size.width.round(),
                  height: MediaQuery.of(context).size.height.round(),
                ),
              ),
            ) //just for testing, will fill with image later
                ),
          ),
          Positioned(
            top: 0,
            right: 3,
            child: IconButton(
              onPressed: () {
                print("delete Image ${index}");
                setState(() {
                  images.removeAt(index);
                });
                _saveImage();
              },
              icon: Icon(Icons.delete_forever, color: Colors.red,),
            ),
          )
        ]);
      },
    );
  }
}
