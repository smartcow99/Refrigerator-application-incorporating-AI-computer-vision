import 'dart:io';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.manageExternalStorage,
  ].request();
  bool per = true;
  statuses.forEach((permission, permissionStatus) {
    if (!permissionStatus.isGranted) {
      per = false;
    }
  });

  return per;
}

class ListData {
  String purchaseDate;
  String expirationDate;
  String itemName;
  ListData(
      {required this.purchaseDate,
      required this.expirationDate,
      required this.itemName});

  String toString() => purchaseDate + "/" + expirationDate + "/" + itemName;
}

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  late File _image;
  final picker = ImagePicker();

  final _dropDownList = ['유통기한 순', '이름 순', '입고 날짜 순'];
  var _selectedValue = '유통기한 순';

  // final _textFormController = TextEditingController();

  static List<ListData> listDatas = [];
  late String _itemName;
  late String _expirationDate;
  late String _purchaseDate;
  @override
  void initState() {
    super.initState();
    setState(() {
      _readListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;

    Future getImage(ImageSource imageSource) async {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: imageSource);

      setState(() {
        _image = File(pickedFile!.path);
      });
    }

    return Container(
      height: _height,
      width: _width,
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                '냉장고',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            width: _width * 0.8,
            color: Colors.greenAccent,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: _selectedValue,
                iconSize: 18,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.lightGreen,
                ),
                elevation: 8,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                underline: Container(
                  height: 1,
                  color: Colors.lightGreen,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue!;
                  });
                },
                items: _dropDownList.map(
                  (value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Container(
            height: _height * 0.05,
          ),
          Container(
            width: _width * 0.8,
            height: _width * 0.8,
            child: DataTable(
              columns: [
                DataColumn(label: Text('구매날짜')),
                DataColumn(label: Text('유통기한')),
                DataColumn(label: Text('음식')),
              ],
              rows: listDatas
                  .map((data) => DataRow(cells: [
                        DataCell(Text(data.purchaseDate)),
                        DataCell(Text(data.expirationDate)),
                        DataCell(Text(data.itemName)),
                      ]))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('카메라 or 갤러리'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('AI 사진 입력 방식'),
                                  Text('카메라, 갤러리'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              // ignore: deprecated_member_use
                              FlatButton(
                                child: Text('카메라'),
                                onPressed: () {
                                  getImage(ImageSource.camera);
                                },
                              ),
                              // ignore: deprecated_member_use
                              FlatButton(
                                child: Text('갤러리'),
                                onPressed: () {
                                  getImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      '사진 입력',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: _width * 0.3,
                height: _height * 0.05,
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: Text(
                    '갤러리',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                width: _width * 0.3,
                height: _height * 0.05,
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    inputDialog(context);
                  },
                  child: Text(
                    '직접 입력',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showImage() {
    // ignore: unnecessary_null_comparison
    if (_image == null) {
      return Container();
    } else {
      return Image.file(_image);
    }
  }

  void inputDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("직접 입력"),
            content: Text("음식, 유통기한을 입력하세요"),
            actions: <Widget>[
              TextField(
                onChanged: (text) {
                  _purchaseDate = text;
                  print("purchaseDate = $_purchaseDate");
                },
                decoration: InputDecoration(
                  labelText: "구매 날짜",
                  hintText: "2021-01-01 형식으로 입력하세요.",
                ),
              ),
              TextField(
                onChanged: (text) {
                  _expirationDate = text;
                  print("foodLife = $_expirationDate");
                },
                decoration: InputDecoration(
                  labelText: "유통 기한",
                  hintText: "2021-01-01 형식으로 입력하세요.",
                ),
              ),
              TextField(
                onChanged: (text) {
                  _itemName = text;
                  print("inputName = $_itemName");
                },
                decoration: InputDecoration(
                  labelText: "음식",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          listDatas.add(ListData(
                              purchaseDate: _purchaseDate,
                              expirationDate: _expirationDate,
                              itemName: _itemName));
                          Navigator.pop(context, "Ok");
                        });
                        _saveListData();
                      },
                      child: Text("OK")),
                  SizedBox(width: 5),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancle");
                      },
                      child: Text("Cancle")),
                ],
              ),
            ],
          );
        });
  }

  List<String> toStringList(List<ListData> data) {
    List<String> ret = [];
    for (int i = 0; i < data.length; i++) {
      ret.add(data[i].toString());
    }
    return ret;
  }

  _saveListData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ListData';
    final value = toStringList(listDatas);
    prefs.setStringList(key, value);
  }

  _readListData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ListData';
    final value = prefs.getStringList(key);
    try {
      for (int i = 0; i < value!.length; i++) {
        print(value[i]);
        var list = value[i].split('/');
        listDatas.add(ListData(
            purchaseDate: list[0], expirationDate: list[1], itemName: list[2]));
      }
    } catch (e) {
      return 0;
    }
  }
}
