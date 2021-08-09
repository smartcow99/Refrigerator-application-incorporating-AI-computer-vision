import 'package:flutter/material.dart';
import 'package:refrigerator/youtube_api/youtube_api.dart';
import 'package:refrigerator/youtube_api/yt_video.dart';

class BannerPage extends StatefulWidget {
  BannerPage({Key? key, required this.textdata}) : super(key: key);
  final String textdata;

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  // Var for Youtube Api
  String regionCode = " ";
  static String _key = "AIzaSyBA3z_uabghRz3RhkW26vrE3RDthkgHoBc";
  YoutubeAPI ytApi = YoutubeAPI(_key);
  List<YT_API> ytResult = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callAPI();
    print('initstate running');
  }

  callAPI() async {
    // Test for Youtube API
    // choose type : "channel" or "playlist" or "video"
    ytResult = await ytApi.search(widget.textdata, type: 'video');
    ytResult = await ytApi.nextPage();
    setState(() {});
  }

  // searchbar 의 TextField 값은 widget.textdata 를 사용하세요.
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => listItem(index),
      itemCount: ytResult.length,
    );
  }

  Widget listItem(index) {
    return Card(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Image.network(
              ytResult[index].thumbnail?['default']['url'],
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    ytResult[index].title,
                    softWrap: true,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 1.5)),
                  Text(
                    ytResult[index].channelTitle,
                    softWrap: true,
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 3.0)),
                  Text(
                    ytResult[index].url,
                    softWrap: true,
                  ),
                ])),
          ],
        ),
      ),
    );
  }

}
