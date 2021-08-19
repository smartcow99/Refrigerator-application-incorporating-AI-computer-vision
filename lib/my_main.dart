import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:uuid/uuid.dart';
import 'package:refrigerator/savePhotoData.dart';

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
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  File? imgFile;
  PickedFile? _file;

  List? _outputs;
  bool _loading = false;

  final _dropDownList = ['유통기한 순', '이름 순', '입고 날짜 순'];
  var _selectedValue = '유통기한 순';

  // final _textFormController = TextEditingController();

  static List<ListData> listDatas = [];
  late String _itemName;
  late String _expirationDate;
  late String _purchaseDate;

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });

    setState(() {
      _readListData();
      sortListData(_selectedValue);
    });
  }

  void sortListData(String value) {
    if (value == _dropDownList[0]) {
      listDatas.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    } else if (value == _dropDownList[1]) {
      listDatas.sort((a, b) => a.itemName.compareTo(b.itemName));
    } else {
      listDatas.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    }
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Demo'),
          content: Column(
            children: [
              _file == null
                  ? Text('no Image Selected.')
                  : Image.file(File(_file!.path)),
              _outputs == null
                  ? Text('no result')
                  : Text(
                      "${_outputs![0]["label"]}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        background: Paint()..color = Colors.white,
                      ),
                    ),
            ],
          ),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text(
              '사진 입력 방법!',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  '카메라',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                onPressed: getImageFromCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  '갤러리',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: getImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Future getImageFromGallery() async {
    Navigator.pop(context);
    var image =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = image!;
    });
    classifyImage(File(_file!.path));
  }

  Future getImageFromCamera() async {
    Navigator.pop(context);
    var image =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      _file = image!;
    });
    classifyImage(File(_file!.path));
  }

  clearPostInfo() {
    uploading = false;
    postId = Uuid().v4();
    descTextEditingController.clear();
    locationTextEditingController.clear();
    setState(() {
      // ignore: unnecessary_statements
      imgFile = null;
    });
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output!;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;

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
                '스마트 SSU 고',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.lightGreen,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            width: _width * 0.8,
            color: Colors.green,
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
                    sortListData(newValue);
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
                          color: Colors.lightGreen,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                // ignore: deprecated_member_use
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () {
                    addData(17, listDatas);
                    setState(() {});
                  },
                  child: Text(
                    'add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                // ignore: deprecated_member_use
                child: FlatButton(
                    color: Colors.lightGreen,
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    child: Text(
                      'AlertDialog!',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
          // ignore: deprecated_member_use

          Container(
              width: _width * 0.8,
              height: _width * 0.8,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text('입고 날짜')),
                      DataColumn(label: Text('유통기한')),
                      DataColumn(label: Text('음식')),
                    ],
                    rows: listDatas
                        .map((data) => DataRow(
                                onSelectChanged: (bool? selected) {
                                  if (selected!) {
                                    checkDeleteDialog(context, data);
                                  }
                                },
                                cells: [
                                  DataCell(Text(data.purchaseDate)),
                                  DataCell(Text(data.expirationDate)),
                                  DataCell(Text(data.itemName)),
                                ]))
                        .toList(),
                  ),
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ignore: deprecated_member_use
              RaisedButton(
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '영수증입력',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => takeImage(context),
              ),
              // ignore: deprecated_member_use
              RaisedButton(
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '재료입력',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => inputDialog(context),
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
      return Image.file(_image!);
    }
  }

  void checkDeleteDialog(BuildContext context, ListData removeData) async {
    await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("정말로 삭제 하시겠습니까?"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          listDatas.remove(removeData);
                          Navigator.pop(context, "Ok");
                        });
                        _saveListData();
                      },
                      child: Text("OK",
                          style: TextStyle(color: Colors.lightGreen))),
                  SizedBox(width: 5),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancle");
                      },
                      child: Text("Cancle",
                          style: TextStyle(color: Colors.lightGreen))),
                ],
              ),
            ],
          );
        });
  }

  void inputDialog(BuildContext context) async {
    await showDialog(
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
                  // print("purchaseDate = $_purchaseDate");
                },
                decoration: InputDecoration(
                  labelText: "구매 날짜",
                  hintText: "2021-01-01 형식으로 입력하세요.",
                ),
              ),
              TextField(
                onChanged: (text) {
                  _expirationDate = text;
                  // print("foodLife = $_expirationDate");
                },
                decoration: InputDecoration(
                  labelText: "유통 기한",
                  hintText: "2021-01-01 형식으로 입력하세요.",
                ),
              ),
              TextField(
                onChanged: (text) {
                  _itemName = text;
                  // print("inputName = $_itemName");
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
                          sortListData(_selectedValue);
                          Navigator.pop(context, "Ok");
                        });
                        _saveListData();
                      },
                      child: Text("OK",
                          style: TextStyle(color: Colors.lightGreen))),
                  SizedBox(width: 5),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancle");
                      },
                      child: Text("Cancle",
                          style: TextStyle(color: Colors.lightGreen))),
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
      if (listDatas.isEmpty) {
        for (int i = 0; i < value!.length; i++) {
          print(value[i]);
          var list = value[i].split('/');
          listDatas.add(ListData(
              purchaseDate: list[0],
              expirationDate: list[1],
              itemName: list[2]));
        }
      }
    } catch (e) {
      return 0;
    }
  }
}
