import 'dart:io';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class Inside {
  var expirationDate;
  String product;
  var productNum;

  Inside({this.expirationDate, this.product, this.productNum});

  static List<Inside> getInside() {
    return <Inside>[
      Inside(
        expirationDate: DateTime.now(),
        product: 'apple',
        productNum: Random(5),
      ),
      Inside(
        expirationDate: DateTime.now(),
        product: 'banana',
        productNum: Random(5),
      ),
      Inside(
        expirationDate: DateTime.now(),
        product: 'orange',
        productNum: Random(5),
      ),
    ];
  }
}

class _MyMainState extends State<MyMain> {
  late File _image;
  final picker = ImagePicker();

  final _dropDownList = ['유통기한 순', '이름 순', '입고 날짜 순'];
  var _selectedValue = '유통기한 순';

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
          Expanded(
            child: Container(
              color: Colors.black12,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('유통기한')),
                      DataColumn(label: Text('음식')),
                      DataColumn(label: Text('수량')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('2021-09-11')),
                        DataCell(Text('사과')),
                        DataCell(Text('1개')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2021-08-12')),
                        DataCell(Text('바나나')),
                        DataCell(Text('2개')),
                      ]),
                    ],
                  ),
                ),
              ),
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
                            title: Text('직접 추가'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '제품명',
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '유통기한',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              // ignore: deprecated_member_use
                              FlatButton(
                                child: Text('cancel'),
                                onPressed: () {},
                              ),
                              // ignore: deprecated_member_use
                              FlatButton(
                                child: Text('ok'),
                                onPressed: () {},
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      '직접 추가',
                      style: TextStyle(
                        fontSize: 20,
                      ),
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
}
