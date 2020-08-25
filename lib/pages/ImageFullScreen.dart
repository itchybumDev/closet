import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageFullScreen extends StatefulWidget {
  final List<Asset> asset;
  final int index;
  final Function loadAssetCallBack;

  const ImageFullScreen({Key key, @required this.asset, @required this.index, @required this.loadAssetCallBack})
      : assert(asset != null),
        super(key: key);

  @override
  _ImageFullScreenState createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  var bytes;

  Future<File> getImageFileFromAssets() async {
    // Store the picture in the temp directory.
    // Find the temp directory using the `path_provider` plugin.
    final ByteData bytes = await widget.asset[widget.index].getByteData();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/${DateTime.now().toIso8601String()}');
    await file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);
    return file;
  }


  Future<Null> _cropImage(BuildContext context) async {
    File tmp = await getImageFileFromAssets();
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: tmp.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
//          CropAspectRatioPreset.ratio3x2,
//          CropAspectRatioPreset.original
//          CropAspectRatioPreset.ratio4x3,
//          CropAspectRatioPreset.ratio16x9
        ]
            : [
//          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
//          CropAspectRatioPreset.ratio3x2,
//          CropAspectRatioPreset.ratio4x3,
//          CropAspectRatioPreset.ratio5x3,
//          CropAspectRatioPreset.ratio5x4,
//          CropAspectRatioPreset.ratio7x5,
//          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      _saveCropImageToLocalPath(croppedFile);
    }
    widget.loadAssetCallBack();
    Navigator.of(context).pop(true);
  }

  _saveCropImageToLocalPath(File croppedFile) async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    final String fileName = DateTime.now().toString() + '.jpg'; // e.g. '.jpg'

    // 6. Save the file by copying it to the new location on the device.
    File savedCroppedFile = await croppedFile.copy('$path/$fileName');
    print("done save cropped image");
    print(savedCroppedFile.path);
    await ImageGallerySaver.saveImage(savedCroppedFile.readAsBytesSync(), quality: 100, name: fileName);
    return savedCroppedFile;
  }


  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    _getByte();
  }

  _getByte() async {
    var tmp = await widget.asset[widget.index].getByteData();
    setState(() {
      bytes = tmp.buffer.asUint8List();
    });
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              print('Crop');
              _cropImage(context);
            },
            child: Text('Crop', style: TextStyle(color: Colors.white))
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: bytes != null
          ? Column(
              children: <Widget>[
                Expanded(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: MemoryImage(bytes),
                      );
                    },
                    onPageChanged: (int index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
