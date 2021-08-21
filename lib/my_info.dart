import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refrigerator/setPushAlarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'my_main.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key}) : super(key: key);

  @override
  _MyInfoState createState() => _MyInfoState();
}

int alarmCycle = 3; // 유통기한 만료 알림 기간

class _MyInfoState extends State<MyInfo> {
  static String _profileImage = "images/profile1.png";
  final _alarmCycleList = List.generate(10, (i) => i);
  // textform을 컨트롤 하기 위한 변수
  final _formkey = GlobalKey<FormState>();
  final _textFormController = TextEditingController();
  static String? _name; // 이름
  static String? _email; // 이메일

  static bool _alarmIsOn = true; // 유통기한 만료 알림 여부
  late List<ListData> listDatas = [];
  int profileSelect = 0;

  @override
  void initState() {
    super.initState();
    // myController에 리스너 추가료
    _textFormController.addListener(_printLatestValue);
    setState(() {
      _readAlarmData();
      _readListData();
      _readProfileData();
    });
  }

  // myController의 텍스트를 콘솔에 출력하는 메소드
  void _printLatestValue() {
    print("Second text field: ${_textFormController.text}");
  }

  // _MyCustomFormState가 제거될 때 호출
  @override
  void dispose() {
    // 텍스트에디팅컨트롤러를 제거하고, 등록된 리스너도 제거된다.
    _textFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: _width * 0.9,
          child: ListView(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: _height * 0.1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '마이페이지',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.lightGreen,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            height: _height * 0.03,
                          ),
                          Container(
                            height: _height * 0.001,
                            width: _width * 0.8,
                            color: Colors.lightGreen,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _height * 0.05,
                    )
                  ],
                ),
              ),
              profileImage(),
              SizedBox(
                height: 20,
              ),
              const Text(
                "계정정보",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.lightGreen),
              ),
              loginIdinfo(),
              SizedBox(
                height: 20,
              ),
              const Text(
                "알림설정",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.lightGreen),
              ),
              alarmSetting(),
            ],
          ),
        ),
      ),
    );
  }

  // 알림 설정 위젯
  Widget alarmSetting() {
    _readAlarmData();
    // 컨테이너 가운데 정렬
    return Center(
      child: Container(
        // 컨테이너 화면 비율 기준 가로 90% 만 차지
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "유통기한 만료 알림",
                  style: TextStyle(fontSize: 14),
                ),
                // on off 스위치
                CupertinoSwitch(
                  value: _alarmIsOn,
                  onChanged: (bool value) {
                    setState(() {
                      // _readAlarmData();
                      // 스위치가 꺼진다면 알림 사이클을 0으로 켜진다면 3으로 디폴트값
                      print("value = $value");
                      alarmCycle = value ? 3 : 0;
                      _alarmIsOn = value;
                      _saveAlarmData();
                      pushNotif(listDatas, -1);
                    });
                  },
                ),
              ],
            ),
            // CuperionoPopup에 있는 context가 상위 context를 의미하기 때문에 builder로 상위 context 만들어줌
            Builder(builder: (BuildContext context) {
              // _readAlarmData();
              return OutlinedButton(onPressed: () async {
                await showCupertinoModalPopup(
                    context: context,
                    builder: (context) => Container(
                          height: 200.0,
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            children: _alarmCycleList
                                .map((e) => Text("$e일 전"))
                                .toList(),
                            itemExtent: 50.0,
                            scrollController:
                                FixedExtentScrollController(initialItem: 1),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                // _readAlarmData();
                                // 알림이 꺼져있는데 기간을 조정하면 알림 켬
                                if (!_alarmIsOn) _alarmIsOn = true;
                                // 알람 주기를 0으로 설정하면 알림 끔
                                if (index == 0) _alarmIsOn = false;
                                alarmCycle = _alarmCycleList[index];
                                _saveAlarmData();
                                pushNotif(listDatas, 1);
                              });
                            },
                          ),
                        ));
              }, child: Builder(builder: (BuildContext context) {
                // _readAlarmData();
                // print("alarm cycle == $_alarmCycle");
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("만료 $alarmCycle일 전",
                        style: TextStyle(fontSize: 15, color: Colors.black)),
                    Icon(
                      Icons.expand_more,
                      color: Colors.teal,
                    ),
                  ],
                );
              }));
            }),
          ],
        ),
      ),
    );
  }

  // 로그인 정보를 입력하는 textform 위젯
  Widget loginIdinfo() {
    // 컨테이너 가운데 정렬
    return Center(
      child: Container(
        // 화면 기준 가로 90%만 사용
        width: MediaQuery.of(context).size.width * 0.9,
        child: Builder(builder: (BuildContext context) {
          return Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  // controller: _textFormController,
                  onChanged: (text) {
                    // 현재 텍스트필드의 텍스트를 출력
                    _name = text;
                    print("name field: $_name");
                  },
                  // 텍스트가 비었을때 에러 메세지 출력
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter some text";
                    }
                  },
                  decoration: InputDecoration(
                    // 버튼을 아래 밑줄만 만듦
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen)),
                    // 클릭했을 때 박스 조정
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.lightGreen, width: 2)),
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    hintText: "이름",
                  ),
                ),
                // 텍스트폼 사이에 간격 줌
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _textFormController,
                  onChanged: (text) {
                    // 현재 텍스트필드의 텍스트를 출력
                    _email = text;
                    print("email: $_email");
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter some text";
                    }
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.lightGreen, width: 2)),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    hintText: "이메일",
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 프로필 사진 위젯
  Widget profileImage() {
    return Center(
      child: Stack(
        children: <Widget>[
          // 동그란 모양 위젯
          CircleAvatar(
            radius: 80.0,
            // 프로필 사진 변경으로 사진이 바뀌었다면 그 사진을 출력하고 아니면 기본 이미지 출력
            backgroundImage: AssetImage(_profileImage),
            backgroundColor: Colors.white,
          ),
          Positioned(
            child: Builder(
              // CupertinoPopup의 context 때문에 builder 사용
              builder: (BuildContext context) {
                return InkWell(
                    onTap: () {
                      print("click");
                      profileSelect = (profileSelect + 1) % 9;
                      setState(() {
                        setProfile();
                      });
                      _saveProfileData();
                    },
                    child: Icon(Icons.sync, color: Colors.grey, size: 28.0));
              },
            ),
            bottom: 20.0,
            right: 20.0,
          ),
        ],
      ),
    );
  }

  void setProfile() {
    if (profileSelect == 0)
      _profileImage = "images/profile0.png";
    else if (profileSelect == 1)
      _profileImage = "images/profile1.png";
    else if (profileSelect == 2)
      _profileImage = "images/profile2.png";
    else if (profileSelect == 3)
      _profileImage = "images/profile3.png";
    else if (profileSelect == 4)
      _profileImage = "images/profile4.png";
    else if (profileSelect == 5)
      _profileImage = "images/profile5.png";
    else if (profileSelect == 6)
      _profileImage = "images/profile6.png";
    else if (profileSelect == 7)
      _profileImage = "images/profile7.png";
    else if (profileSelect == 8) _profileImage = "images/profile8.png";
  }

  _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'profile';
    final value = profileSelect;
    prefs.setInt(key, value);
    print('saved $value');
  }

  _readProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'profile';
    final value = prefs.getInt(key);
    profileSelect = value ?? 0;
    setState(() {
      setProfile();
    });
  }

  _saveAlarmData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'alarmCycle';
    final value = alarmCycle;
    prefs.setInt(key, value);
    // print('saved $value');
  }

  _readAlarmData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'alarmCycle';
    final value = prefs.getInt(key);
    alarmCycle = value ?? 3;
    // print("read: ${_alarmCycle}");
  }

  Future _pushNotification(int index) async {
    print(index);
    final notiTitle = '냉장고';
    final notiDesc = '냉장고에 곧 썩는 음식이 있어요!';

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    var android = AndroidNotificationDetails('id', notiTitle, notiDesc,
        importance: Importance.max, priority: Priority.max);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    if (result!) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannelGroup('id');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        notiTitle,
        notiDesc,
        _setNotiTime(index),
        detail,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _setNotiTime(int index) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    var tmp = listDatas[index].expirationDate.split('-');
    var alarmDate = [
      int.parse(tmp[0]),
      int.parse(tmp[1]),
      int.parse(tmp[2]),
    ];
    if (alarmDate[2] - alarmCycle < 0) {
      alarmDate[1]--;
      if (alarmDate[1] <= 7 && alarmDate[1] % 2 == 1 ||
          alarmDate[1] > 7 && alarmDate[1] % 2 == 0)
        alarmDate[2] = 31 + alarmDate[2] - alarmCycle;
      else
        alarmDate[2] = 30 + alarmDate[2] - alarmCycle;
    }
    var scheduledDate = tz.TZDateTime(
        tz.local, alarmDate[0], alarmDate[1], alarmDate[2], 10, 0);
    return scheduledDate;
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
