import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refrigerator/youtube_api/youtube_api.dart';
import 'package:refrigerator/youtube_api/yt_video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DemoApp extends StatefulWidget {
  DemoApp({Key? key}) : super(key: key);

  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  static String key = "AIzaSyDvrFW2FCTr_mkWz5-Kv_-UGpRca6ftmHc";
  YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 1);
  List<YT_API> ytResult = [];

  void callAPI() async {
    print('this is callAPI');
    String query = '김치찌개';
    ytResult = await ytApi.search(query, type: 'video');
    ytResult = await ytApi.nextPage();
    if (this.mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    callAPI();
    print('hello');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: ListView.builder(
        // 표시할 List 의 갯수
        itemCount: ytResult.length,
        itemBuilder: (_, int index) {
          return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => YoutubePlayerBuilder(
                              player: YoutubePlayer(
                                controller: YoutubePlayerController(
                                  initialVideoId: ytResult[index].id.toString(),
                                  flags: YoutubePlayerFlags(
                                    autoPlay: true,
                                    mute: false,
                                  ),
                                ),
                              ),
                              builder: (context, player) {
                                return Column(
                                  children: [
                                    player,
                                  ],
                                );
                              },
                            )));
              },
              child: listItem(index));
        },
      ),
    );
  }

  Widget listItem(index) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Image.network(
              ytResult[index].thumbnail?['default']['url'],
              // width: 100,
              // height: 100,
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
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
                ]))
          ],
        ),
      ),
    );
  }
}
