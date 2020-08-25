import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveToImageDb(String key, List<String> images) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(key, images);
  print('Save images for $key');
}

Future<List<String>> loadImageFromDB(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> stringValue = prefs.getStringList(key) ?? [];
  print('Load images for $key');
  print(stringValue);
  return stringValue;
}

saveTitlesToDb(List<String> titles) async {
  String key = 'Titles';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(key, titles);
  print('saveTitlesToDb for $key');
}

Future<Set<String>> loadTitlesFromDB() async {
  String key = 'Titles';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> stringValue = prefs.getStringList(key) ?? [];
  print('loadTitleFromDB for $key');
  return stringValue.toSet();
}

saveWidgetSize(String title, double size) async {
  String key = 'size-$title';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(key, size);
  print('saveWidgetSize for $key');
}

Future<double> loadWidgetSize(String title) async {
  String key = 'size-$title';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double stringValue = prefs.getDouble(key) ?? 200;
  print('loadWidgetSize for $key');
  return stringValue;
}


saveOffset(String key, Offset offset) async {
  String tempKey = 'Offset-$key';
  List<String> values = [offset.dx.toString(), offset.dy.toString()];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(tempKey, values);
  print('Save images for $key');
}

Future<Offset> loadOffset(String key) async {
  String tempKey = 'Offset-$key';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> stringValue = prefs.getStringList(tempKey) ?? [];
  if (stringValue.length != 0) {
    Offset offset = Offset(
        double.parse(stringValue[0]), double.parse(stringValue[1]));
    print('loadOffset for $tempKey');
    print(stringValue);
    return offset;
  } else {
    return Offset(0.0, 0.0);
  }
}