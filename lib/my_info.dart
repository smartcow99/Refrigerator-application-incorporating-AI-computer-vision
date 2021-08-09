import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key}) : super(key: key);

  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  final ImagePicker _picker = ImagePicker(); // 프로필 사진 변경을 위한 picker
  XFile? _profileImage; // 프로필 이미지
  bool _alarmIsOn = true; // 유통기한 만료 알림 여부
  int _alarmCycle = 3; // 유통기한 만료 알림 기간
  final _alarmCycleList = List.generate(10, (i) => i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          profileImage(),
          SizedBox(
            height: 20,
          ),
          const Text(
            "계정정보",
            style: TextStyle(fontSize: 15),
          ),
          loginIdinfo(),
          SizedBox(
            height: 20,
          ),
          const Text(
            "알림설정",
            style: TextStyle(fontSize: 15),
          ),
          alarmSetting(),
        ],
      ),
    );
  }

  Widget alarmSetting() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "유통기한 만료 알림",
                  style: TextStyle(fontSize: 20),
                ),
                CupertinoSwitch(
                  value: _alarmIsOn,
                  onChanged: (bool value) {
                    setState(() {
                      _alarmCycle = value ? 3 : 0;
                      _alarmIsOn = value;
                    });
                  },
                ),
              ],
            ),
            Builder(builder: (BuildContext context) {
              return OutlinedButton(
                  onPressed: () async {
                    await showCupertinoModalPopup(
                        context: context,
                        builder: (context) => Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                backgroundColor: Colors.white,
                                children: _alarmCycleList
                                    .map((e) => Text("$e일전"))
                                    .toList(),
                                itemExtent: 50.0,
                                scrollController:
                                    FixedExtentScrollController(initialItem: 1),
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    if (!_alarmIsOn) _alarmIsOn = true;
                                    if (index == 0) _alarmIsOn = false;
                                    _alarmCycle = _alarmCycleList[index];
                                  });
                                },
                              ),
                            ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("만료 $_alarmCycle일 전",
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      Icon(
                        Icons.expand_more,
                        color: Colors.teal,
                      ),
                    ],
                  ));
            }),
          ],
        ),
      ),
    );
  }

  Widget loginIdinfo() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter some text";
                }
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2)),
                labelText: "Name",
                hintText: "이름",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter some text";
                }
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2)),
                labelText: "Email",
                hintText: "이메일",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileImage() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80.0,
            backgroundImage: _profileImage == null
                ? AssetImage("images/profileDefault.png")
                : AssetImage(_profileImage!.path),
            backgroundColor: Colors.white,
          ),
          Positioned(
            child: Builder(
              builder: (BuildContext context) {
                return InkWell(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          title: const Text('업로스 방식을 선택하세요'),
                          actions: <CupertinoActionSheetAction>[
                            CupertinoActionSheetAction(
                              child: const Text('Camera'),
                              onPressed: () {
                                filePicker(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Gallery'),
                              onPressed: () {
                                filePicker(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                          ),
                        ),
                      );
                      print("tap");
                    },
                    child:
                        Icon(Icons.camera_alt, color: Colors.teal, size: 28.0));
              },
            ),
            bottom: 20.0,
            right: 20.0,
          ),
        ],
      ),
    );
  }

  void filePicker(ImageSource source) async {
    print("func on");
    final XFile? selectImage = await _picker.pickImage(source: source);
    print(selectImage!.path);
    print("주소");
    setState(() {
      _profileImage = selectImage;
    });
  }
}
