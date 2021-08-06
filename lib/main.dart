import 'package:flutter/material.dart';

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
    throw UnimplementedError();
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({Key? key}) : super(key: key);

  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  var _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[상단 제목]'),
        centerTitle: true, // 중앙 정렬 여부
        elevation: 6, // 상단바 그림자 강도
        actions: <Widget>[
          // MainPage 상단 버튼을 추가하려면 여기에 추가하세요.
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle_outline)),
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle_outline)),
        ],
      ),
      body: Center(
        // 가운데 내용입니다.
        child: Text('$_pageIndex 페이지', style: TextStyle(fontSize: 50)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        currentIndex: _pageIndex,
        // 현재 페이지
        selectedItemColor: Colors.amber,
        // 선택된 NavigationBar의 색상
        unselectedItemColor: Colors.black12,
        // 선택안된 NavigationBar 의 색상
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main page'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Youtube Search Page'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Myinfo Page'),
        ],
      ),
    );
  }
}
