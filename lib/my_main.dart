import 'dart:io';

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
      padding: EdgeInsets.only(left: _width * 0.02),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: _height * 0.025,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '나의 냉장고',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ),
          Container(
            height: _height * 0.04,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: _selectedValue,
              iconSize: 24,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
              underline: Container(
                height: 1,
                color: Colors.black,
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
                    child: Text(value),
                  );
                },
              ).toList(),
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
              rows: [
                DataRow(cells: [
                  DataCell(Text('2021-08-11')),
                  DataCell(Text('2021-09-11')),
                  DataCell(Text('apple')),
                ]),
                DataRow(cells: [
                  DataCell(Text('2021-08-01')),
                  DataCell(Text('2021-08-12')),
                  DataCell(Text('바나나')),
                ]),
              ],
            ),
          ),
          Container(
            height: _height * 0.15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _width * 0.35,
                height: _height * 0.05,
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  child: Text(
                    '카메라',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                width: _width * 0.35,
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
