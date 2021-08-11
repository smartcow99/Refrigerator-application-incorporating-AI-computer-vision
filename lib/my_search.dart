import 'package:flutter/material.dart';
import 'package:refrigerator/searchbar_screen.dart';
import 'package:refrigerator/youtube_screen.dart';

// Youtube 검색을 실행하는 class
class MySearch extends StatefulWidget {
  const MySearch({Key? key}) : super(key: key);

  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  // SearchBar 에 표시되는 string 을 저장하는 변수
  String searchbarText = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: SearchBar(
            function: returnDataFunction,
          ),
        ),
        Expanded(
          flex: 20,
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            padding: EdgeInsets.all(3),
            alignment: Alignment.center,
            child: ytPlay(data: searchbarText,
            key: UniqueKey(),),
            color: Colors.white,
          ),
        )
      ],
    );
  }

  // searchbartext 을 갱신하기 위한 callback 함수
  void returnDataFunction(String rtData) {
    setState(() {
      searchbarText = rtData;
    });
  }

}
