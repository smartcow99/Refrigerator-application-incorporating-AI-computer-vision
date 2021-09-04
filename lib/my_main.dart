import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrigerator/data/json_data.dart';
import 'package:refrigerator/data/listData.dart';
import 'package:refrigerator/setPushAlarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

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

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  TextEditingController descTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  final picker = ImagePicker();
  File? imgFile;
  PickedFile? _file;

  List? _outputs;
  bool _loading = false;

  final _dropDownList = ['유통기한 순', '이름 순', '구매 날짜 순'];
  var _selectedValue = '유통기한 순';

  static List<ListData> listDatas = [];
  String _itemName = "";
  String _expirationDate = "";
  String _purchaseDate = "";

  @override
  initState() {
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

  dispose() {
    Tflite.close();

    super.dispose();
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

  takeImage(mContext) {
    return showCupertinoDialog(
        context: mContext,
        builder: (context) {
          return CupertinoAlertDialog(
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text(
                    '카메라',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    getImageFromCamera(context);
                  }),
              CupertinoDialogAction(
                  child: Text(
                    '갤러리',
                  ),
                  onPressed: () {
                    getImageFromGallery(context);
                  }),
              CupertinoDialogAction(
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Future getImageFromGallery(BuildContext context) async {
    Navigator.pop(context);
    var image =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = image!;
    });
    classifyImage(File(_file!.path));
  }

  Future getImageFromCamera(BuildContext context) async {
    Navigator.pop(context);
    var image =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      _file = image!;
    });
    classifyImage(File(_file!.path));
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

    List<String> tmp = _outputs![0]["label"].toString().split(' ');
    int index = int.tryParse(tmp[0]) ?? -1;
    setState(() {
      if (index != -1) {
        addData(index, listDatas);
        sortListData(_selectedValue);
        _saveListData();
      }
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
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Text(
                    'RAIC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.lightGreen,
                      fontSize: 32,
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
                padding: const EdgeInsets.only(
                    left: 40.0, right: 8.0, top: 16.0, bottom: 8.0),
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
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  color: Color(0xFFF0F0F0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 68,
                        showCheckboxColumn: false,
                        columns: [
                          DataColumn(label: Text('구매 날짜')),
                          DataColumn(label: Text('유통기한')),
                          DataColumn(label: Text('음식')),
                        ],
                        rows: listDatas
                            .map((data) => DataRow(
                                    onSelectChanged: (bool? selected) {
                                      if (selected!) {
                                        listDataModify(context, data);
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
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            child: SpeedDial(
              childrenButtonSize: 60,
              icon: Icons.menu,
              activeIcon: Icons.close,
              backgroundColor: Colors.lightGreen,
              foregroundColor: Colors.white,
              activeBackgroundColor: Colors.red,
              activeForegroundColor: Colors.white,
              buttonSize: 60,
              visible: true,
              closeManually: false,
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              onOpen: () => print('Open'),
              onClose: () => print('Close'),
              spaceBetweenChildren: 24,
              elevation: 4.0,
              shape: CircleBorder(),
              children: [
                SpeedDialChild(
                  child: Icon(
                    Icons.add,
                  ),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  label: 'instant add',
                  labelStyle: TextStyle(fontSize: 16),
                  onTap: () {
                    inputDialog(context);
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.add_a_photo_outlined),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  label: 'picture add',
                  labelStyle: TextStyle(fontSize: 16),
                  onTap: () {
                    takeImage(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void nameModify(BuildContext context, ListData change) async {
    await showCupertinoDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("음식 이름 변경"),
            actions: <Widget>[
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: CupertinoTextField(
                      placeholder: "음식",
                      onChanged: (text) {
                        change.itemName = text;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context, "Ok");
                            Navigator.pop(context, "Ok");
                          },
                          child: Text(
                            "OK",
                          )),
                      CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                          child: Text(
                            "Cancel",
                          )),
                    ],
                  ),
                ],
              )
            ],
          );
        });
  }

  void nameDirectInput(BuildContext context) async {
    await showCupertinoDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("음식 이름 변경"),
            actions: <Widget>[
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: CupertinoTextField(
                      placeholder: "음식",
                      onChanged: (text) {
                        _itemName = text;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context, "Ok");
                          },
                          child: Text(
                            "OK",
                          )),
                      CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                          child: Text(
                            "Cancel",
                          )),
                    ],
                  ),
                ],
              )
            ],
          );
        });
  }

  void showModifyDatePicker(
      BuildContext ctx, ListData change, String selected) async {
    String tmp = DateTime.now().toString();
    await showCupertinoModalPopup(
        context: ctx,
        barrierDismissible: false,
        builder: (context) {
          return Container(
            height: 300,
            color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                Container(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime value) {
                        tmp = value.toString();
                      },
                    )),
                CupertinoButton(
                    child: Text("OK"),
                    onPressed: () {
                      List<String> input = tmp.split(" ");
                      setState(() {
                        if (selected == "expire") {
                          change.expirationDate = input[0];
                        } else {
                          change.purchaseDate = input[0];
                        }
                      });
                      Navigator.of(ctx).pop();
                      Navigator.of(ctx).pop();
                    }),
              ],
            ),
          );
        });
  }

  void listDataModify(BuildContext context, ListData modifyData) async {
    await showCupertinoDialog(
        context: context,
        // barrierDismissible: false, // user must tap button!
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text("수정할 데이터를 선택하세요."),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () =>
                    showModifyDatePicker(ctx, modifyData, "purchase"),
                child: Text("구매 날짜 변경"),
              ),
              CupertinoDialogAction(
                onPressed: () =>
                    showModifyDatePicker(ctx, modifyData, "expire"),
                child: Text("유통기한 변경"),
              ),
              CupertinoDialogAction(
                onPressed: () => nameModify(ctx, modifyData),
                child: Text("음식 변경"),
              ),
              CupertinoDialogAction(
                  onPressed: () {
                    setState(() {
                      listDatas.remove(modifyData);
                      pushNotif(listDatas, 1);
                      _saveListData();
                      Navigator.pop(ctx, "제거");
                    });
                  },
                  child: Text("제거")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    pushNotif(listDatas, 1);
                    _saveListData();
                    setState(() {
                      sortListData(_selectedValue);
                    });
                    Navigator.pop(ctx, "Cancel");
                  },
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.red, fontSize: 15))),
            ],
          );
        });
  }

  void showDirectDatePicker(BuildContext ctx, String selected) async {
    String tmp = DateTime.now().toString();
    await showCupertinoModalPopup(
        context: ctx,
        barrierDismissible: false,
        builder: (context) {
          return Container(
            height: 300,
            color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                Container(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime value) {
                        tmp = value.toString();
                        print(tmp);
                      },
                    )),
                CupertinoButton(
                    child: Text("OK"),
                    onPressed: () {
                      List<String> input = tmp.split(" ");
                      setState(() {
                        if (selected == "expire") {
                          _expirationDate = input[0];
                        } else {
                          _purchaseDate = input[0];
                        }
                      });
                      Navigator.of(ctx).pop();
                    }),
              ],
            ),
          );
        });
  }

  void inputDialog(BuildContext context) async {
    await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("직접 입력"),
            content: Text("음식, 유통기한을 입력하세요"),
            actions: <Widget>[
              CupertinoDialogAction(
                  onPressed: () => showDirectDatePicker(context, "purchase"),
                  child: Text(
                    "구매 날짜",
                  )),
              CupertinoDialogAction(
                  onPressed: () => showDirectDatePicker(context, "expire"),
                  child: Text(
                    "유통기한",
                  )),
              CupertinoDialogAction(
                  onPressed: () => nameDirectInput(context), child: Text("음식")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoButton(
                      onPressed: () {
                        setState(() {
                          listDatas.add(ListData(
                              purchaseDate: _purchaseDate,
                              expirationDate: _expirationDate,
                              itemName: _itemName));
                          sortListData(_selectedValue);
                          Navigator.pop(context, "Save");
                        });
                        pushNotif(listDatas, 1);
                        _saveListData();
                      },
                      child: Text("Save")),
                  CupertinoButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancel");
                      },
                      child: Text("Cancel",
                          style: TextStyle(color: Colors.red, fontSize: 15))),
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
