import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key}) : super(key: key);

  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  bool _alarmIsOn = true;
  int _alarmCycle = 3;
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
          Text(
            "계정정보",
            style: TextStyle(fontSize: 15),
          ),
          loginIdinfo(),
          SizedBox(
            height: 20,
          ),
          alarmSetting(),
        ],
      ),
    );
  }

  Widget alarmSetting() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "유통기한 만료 알림",
              style: TextStyle(fontSize: 20),
            ),
            CupertinoSwitch(
              value: _alarmIsOn,
              onChanged: (bool value) {
                setState(() {
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
    );
  }

  Widget loginIdinfo() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
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
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2)),
            labelText: "Email",
            hintText: "이메일",
          ),
        ),
      ],
    );
  }

  Widget profileImage() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80.0,
            backgroundImage: AssetImage("images/profileDefault.png"),
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
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Gallery'),
                              onPressed: () {
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
}
