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

  // 알림 설정 위젯
  Widget alarmSetting() {
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
                  style: TextStyle(fontSize: 20),
                ),
                // on off 스위치
                CupertinoSwitch(
                  value: _alarmIsOn,
                  onChanged: (bool value) {
                    setState(() {
                      // 스위치가 꺼진다면 알림 사이클을 0으로 켜진다면 3으로 디폴트값
                      _alarmCycle = value ? 3 : 0;
                      _alarmIsOn = value;
                    });
                  },
                ),
              ],
            ),
            // CuperionoPopup에 있는 context가 상위 context를 의미하기 때문에 builder로 상위 context 만들어줌
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
                                    // 알림이 꺼져있는데 기간을 조정하면 알림 켬
                                    if (!_alarmIsOn) _alarmIsOn = true;
                                    // 알람 주기를 0으로 설정하면 알림 끔
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

  // 로그인 정보를 입력하는 textform 위젯
  Widget loginIdinfo() {
    // 컨테이너 가운데 정렬
    return Center(
      child: Container(
        // 화면 기준 가로 90%만 사용
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            TextFormField(
              // 텍스트가 비었을때 에러 메세지 출력
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter some text";
                }
              },
              decoration: InputDecoration(
                // 버튼을 아래 밑줄만 만듦
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
                // 클릭했을 때 박스 조정
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2)),
                labelText: "Name",
                hintText: "이름",
              ),
            ),
            // 텍스트폼 사이에 간격 줌
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
                    borderSide: BorderSide(color: Colors.grey, width: 2)),
                labelText: "Email",
                hintText: "이메일",
              ),
            ),
          ],
        ),
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
            backgroundImage: _profileImage == null
                ? AssetImage("images/profileDefault.png")
                : AssetImage(_profileImage!.path),
            backgroundColor: Colors.white,
          ),
          Positioned(
            child: Builder(
              // CupertinoPopup의 context 때문에 builder 사용
              builder: (BuildContext context) {
                return InkWell(
                    onTap: () {
                      // 카메라 아이콘을 눌렀을 때 카메라와 갤러리중에 프로필 사진을 변경하는 방식 고름
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
                        Icon(Icons.camera_alt, color: Colors.grey, size: 28.0));
              },
            ),
            bottom: 20.0,
            right: 20.0,
          ),
        ],
      ),
    );
  }

  // 프로필 사진을 카메라, 갤러리에서 가져올 때 사용, 함수 인자는 카메라인지 갤러리인지 넘겨줌
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
