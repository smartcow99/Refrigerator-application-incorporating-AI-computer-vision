import 'dart:io';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrigerator/setPushAlarm.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';

import 'package:refrigerator/savePhotoData.dart';

import 'data/listData.dart';

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
  String _itemName = '음식을 입력하세요';
  String _expirationDate = DateTime.now().toString().split(' ')[0];
  String _purchaseDate = DateTime.now().toString().split(' ')[0];

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

    var today = DateTime.now();

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
                  padding: EdgeInsets.all(12),
                  width: _width * 0.8,
                  // color: Color(0xFFF0F0F0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: _width * 0.4,
                        showCheckboxColumn: false,
                        showBottomBorder: true,
                        columns: [
                          DataColumn(
                              label: Text(
                            '음식',
                            style: TextStyle(
                                fontSize: 16, color: Colors.lightGreen),
                          )),
                          DataColumn(
                              label: Text(
                            '유통기한',
                            style: TextStyle(
                                fontSize: 16, color: Colors.lightGreen),
                          )),
                        ],
                        rows: listDatas
                            .map((data) => DataRow(
                                    onSelectChanged: (bool? selected) {
                                      if (selected!) {
                                        setState(() {
                                          showDetail(
                                              context, data, _width, _height);
                                        });
                                      }
                                    },
                                    cells: [
                                      DataCell(Text(data.itemName)),
                                      DataCell(Text(data.calLastDate(data))),
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
                    setState(() {
                      directInput(context);
                    });
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

  String foodImage = "images/foods/41.png";
  findCorrectFoodImage(ListData data) {
    int i = 0;
    for (; i < dataSet.length; i++) {
      if (data.itemName == dataSet[i].name) break;
    }
    foodImage = "images/foods/$i.png";
  }

  showDetail(BuildContext context, ListData data, double _width,
      double _height) async {
    findCorrectFoodImage(data);
    setState(() {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                content: Container(
                  width: _width * 0.85,
                  height: _height * 0.53,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          foodImage,
                          width: _width * 0.6,
                          height: _height * 0.2,
                        ),
                      ),
                      Text(
                        "음식",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.itemName,
                            style: TextStyle(fontSize: 24),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  nameModify(context, data);
                                  findCorrectFoodImage(data);
                                  sortListData(_selectedValue);
                                  _saveListData();
                                });
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey,
                              )),
                        ],
                      ),
                      Text(
                        "구매 날짜",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.purchaseDate,
                            style: TextStyle(fontSize: 24),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  showModifyCalender(context, data, "purchase");
                                  sortListData(_selectedValue);
                                  _saveListData();
                                });
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey,
                              )),
                        ],
                      ),
                      Text(
                        "유통 기한",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.expirationDate,
                            style: TextStyle(fontSize: 24),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  showModifyCalender(context, data, "expire");
                                  sortListData(_selectedValue);
                                  _saveListData();
                                });
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey,
                              )),
                        ],
                      ),
                      Center(
                        child: DialogButton(
                          child: Text(
                            "제거",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            print("click");
                            setState(() {
                              listDatas.remove(data);
                              pushNotif(listDatas, 1);
                              _saveListData();
                              Navigator.pop(context);
                            });
                          },
                          width: _width * 0.5,
                        ),
                      )
                      // ignore: deprecated_member_use
                    ],
                  ),
                ),
              );
            });
          }).then((value) {
        setState(() {});
      });
    });
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
                        setState(() {
                          change.itemName = text;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context, "Ok");
                            });
                          },
                          child: Text(
                            "OK",
                          )),
                      CupertinoButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context, "Cancel");
                            });
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

  void showModifyCalender(
      BuildContext context, ListData data, String selected) async {
    if (selected == 'purchase')
      selected = data.purchaseDate;
    else
      selected = data.expirationDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selected),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selected) {
      setState(() {
        if (selected == data.purchaseDate)
          data.purchaseDate = picked.toString().split(' ')[0];
        else
          data.expirationDate = picked.toString().split(' ')[0];
      });
    }
  }

  void showDirectCalender(BuildContext context, String selected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selected) {
      setState(() {
        if (selected == 'purchase')
          _purchaseDate = picked.toString().split(' ')[0];
        else
          _expirationDate = picked.toString().split(' ')[0];
      });
    }
  }

  void directInput(BuildContext context) async {
    bool purchaseFlag = false;
    bool expireFlag = false;
    bool nameFlag = false;
    await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text("직접 입력"),
              content: Text("음식, 유통기한을 입력하세요"),
              actions: <Widget>[
                CupertinoDialogAction(
                    onPressed: () {
                      setState(() {
                        showDirectCalender(context, "purchase");
                        purchaseFlag = true;
                      });
                    },
                    child: Text(
                      purchaseFlag ? _purchaseDate : "구매 날짜를 입력하세요!",
                    )),
                CupertinoDialogAction(
                    onPressed: () {
                      setState(() {
                        showDirectCalender(context, "expire");
                        expireFlag = true;
                      });
                    },
                    child: Text(
                      expireFlag ? _expirationDate : "유통기한을 입력하세요!",
                    )),
                CupertinoDialogAction(
                    onPressed: () {
                      setState(() {
                        nameDirectInput(context);
                        nameFlag = true;
                      });
                    },
                    child: Text(nameFlag ? _itemName : "음식을 입력하세요!")),
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
        }).then((value) {
      setState(() {});
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
