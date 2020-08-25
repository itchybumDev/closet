import 'package:closet/pages/ItemListPage.dart';
import 'package:closet/service/LocalDB.dart';
import 'package:closet/widget/DragBox.dart';
import 'package:closet/widget/HorizontalList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _random = false;
  Set<String> titles = {'Top', 'Bottom', 'Shoes'};
  final _delimiter = '#@';

  final categoryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  _loadTitles() async {
    print('Loading Titles from DB');
    Set<String> tmp = await loadTitlesFromDB();
    setState(() {
      titles = tmp;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    categoryTextController.dispose();
    super.dispose();
  }

  _addTitle(String title) {
    setState(() {
      titles.add(title);
    });
    saveTitlesToDb(titles.toList(growable: false));
  }

  _removeTitle(String title) {
    setState(() {
      titles.remove(title);
    });
    saveTitlesToDb(titles.toList(growable: false));
  }

  Future<List> _loadImage(String title) async {
    print('Loading Images from DB');
    List<String> tmp = await loadImageFromDB(title);
    List<Asset> tmpAsset = tmp.map((img) {
      List<String> idString = img.split(_delimiter);
      return Asset(idString[0], idString[1], int.parse(idString[2]),
          int.parse(idString[3]));
    }).toList();

    double size = await loadWidgetSize(title);

    return [tmpAsset, size];
  }

  Widget getFutureBuilder(String title) {
    return FutureBuilder<List>(
        future: _loadImage(title),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DragBox(
                title,
                HorizontalList(
                    title: title,
                    random: true,
                    images: snapshot.data[0],
                    size: snapshot.data[1],
                    removeTitleCallBack: _removeTitle));
          } else {
            return Container();
          }
        });
  }

  List<Widget> buildChildren() {
    return titles.map((e) => getFutureBuilder(e)).toList();
  }

  _showDialog(context) async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      controller: categoryTextController,
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'Category',
                          hintText: 'eg. Jewellery',
                          labelStyle: TextStyle(
                              color: Colors.green,
                              fontSize: 25,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new FlatButton(
                    child: const Text('CREATE'),
                    onPressed: () {
                      String tmpTitle = categoryTextController.text.trim();
                      _addTitle(tmpTitle);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ItemListPage(title: tmpTitle)));
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Closet'),
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                print("add new title");
                _showDialog(context);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Stack(children: <Widget>[...buildChildren()])),
    );
  }
}
