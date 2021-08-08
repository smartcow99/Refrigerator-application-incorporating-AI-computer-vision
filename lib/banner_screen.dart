
import 'package:flutter/material.dart';
import 'package:refrigerator/youtube_screen.dart';

final _pageLimitCount = 3;
final _itemCount = 3;

class BannerPage extends StatefulWidget {
  BannerPage({Key? key, required this.textdata}) : super(key: key);
  final String textdata;
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  // Page 에 대한 Controller
  PageController _pageController = PageController();
  LittleDotsPainter _littleDotsPainter = LittleDotsPainter(_itemCount, 0);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController.addListener(onPageChange);
  }

  void onPageChange() {
    setState(() {
        _littleDotsPainter = LittleDotsPainter(_pageLimitCount,_pageController.page ?? 0.0);

    });
    //print(_pageController.page);
  }

  // searchbar 의 TextField 값은 widget.textdata 를 사용하세요.
  @override
  Widget build(BuildContext context) {
    // 핸드폰마다의 사이즈를 맞춰줌
    return Stack(
      children: <Widget>[
        YoutubeShow(),
        Positioned(
            left: 100,
            right: 100,
            bottom: 10,
            height: 10,
            child:

            CustomPaint(
              painter: _littleDotsPainter,
            )

        ),
      ],
    );
  }

  PageView TestImg() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        // 이부분에 Youtube 관련 영상을 뿌리면 될듯
        return Image.network(
          'https://picsum.photos/200/300',
          width: 300,
          height: 100,
        );
      },
    );
  }
}

class LittleDotsPainter extends CustomPainter {
  late int numOfDots;
  double page;

  LittleDotsPainter(this.numOfDots, this.page);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < numOfDots; i++) {
      canvas.drawCircle(
          // This is test code
          Offset(size.width / numOfDots * i + (size.width / numOfDots / 2), 0),
          5,
          Paint()
            ..color = Colors.red
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke);
    }
    canvas.drawCircle(
        Offset(size.width / numOfDots * page + (size.width / numOfDots / 2), 0),
        8, // 해당 circle의 반지름
        Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if(page < _pageLimitCount-1)
      return (oldDelegate as LittleDotsPainter).page != page;
    else
      return false;
  }
}




