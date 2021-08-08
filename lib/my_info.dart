import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key}) : super(key: key);

  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          profileImage(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
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
