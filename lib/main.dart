import 'package:flutter/material.dart';

import 'my_info.dart';
import 'my_main.dart';
import 'my_search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Refrigeator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomepage(),
    );
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({key}) : super(key: key);

  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  var _pageIndex = 0;

  // _children 은 각각의 Page 를 담는 List<Widget>
  // ex. YoutubeSearchPage : class ytfPage 일경우
  // ytfPage() 를 _children 에 추가한다.
  // Main 페이지 : my_main.dart
  // 유투브 검색 페이지 : my_search.dart
  // 개인정보,설정 페이지 : my_info.dart
  final List<Widget> _children = [
    const MyMain(),
    const MySearch(),
    const MyInfo()
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _children[_pageIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              _pageIndex = value;
            });
          },
          currentIndex: _pageIndex,
          // 현재 페이지
          selectedItemColor: Colors.lightGreen,
          // 선택된 NavigationBar의 색상
          unselectedItemColor: Colors.black12,
          // 선택안된 NavigationBar 의 색상
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.sensor_window_rounded), label: '나의 냉장고'),
            BottomNavigationBarItem(
              icon: Icon(Icons.youtube_searched_for),
              label: '유투브 검색',
              //   activeIcon: FavoriteListPage([])
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person_add), label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}
