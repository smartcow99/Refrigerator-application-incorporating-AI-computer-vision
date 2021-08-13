import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refrigerator/youtube_api/youtube_api.dart';
import 'package:refrigerator/youtube_api/yt_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'my_main.dart';

class ytPlay extends StatefulWidget {
  String data;

  ytPlay({Key? key, required this.data}) : super(key: key);

  @override
  _ytPlayState createState() => _ytPlayState(this.data);
}

class _ytPlayState extends State<ytPlay> {
  // Youtube API를 사용하기 위한 고유 key.
  // 일당 10,000 query 지원
  // 해당 query 초과시 key값을 바꿔야됨
  static String key = "AIzaSyDvrFW2FCTr_mkWz5-Kv_-UGpRca6ftmHc";
  List<ListData> saved_data = [];
  // search 할 string 을 담는 변수
  String _data;
  YoutubeAPI ytApi = YoutubeAPI(key,);

  // search 한 결과를 Youtube API 로부터 받는 List 변수
  List<YT_API> ytResult = [];

  _ytPlayState(this._data);

  // API 를 통해서 해당 검색결과를 담아옴
  void callAPI() async {
    log('Running callAPI');
    ytResult = await ytApi.search(this._data, type: 'video');
    ytResult = await ytApi.nextPage();
    setState(() {});
  }

  @override
  void initState()  {
    super.initState();
    callAPI();
    _readListData();
  }

  void _readListData() async {
    log('_readLIstData running...');
    final prefs = await SharedPreferences.getInstance();
    final key = 'ListData';
    final value  = prefs.getStringList(key);
    try{
      for(int i=0;i<value!.length;i++){
        print(value[i]);
        var list = value[i].split('/');
        saved_data.add(ListData(purchaseDate: list[0], expirationDate: list[1], itemName: list[2]));
      }
      setState(() {

      });
    }catch(e){
      log('_readData Error catch');
      return ;
    }
  }
  void _FindingMostMenu(){
    for(int i=0;i<saved_data.length;i++){

    }
  }
  @override
  Widget build(BuildContext context) {

    if (_data.isNotEmpty)
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
                          builder: (context) =>
                              YoutubePlayerBuilder(
                                player: YoutubePlayer(
                                  controller: YoutubePlayerController(
                                    initialVideoId:
                                    ytResult[index].id.toString(),
                                    // 재생할 video의 id값
                                    flags: YoutubePlayerFlags(
                                      autoPlay: true, // 자동재생 true
                                      mute: false, // 음소거 false
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
    else
      return Container( // 처음 시작시, 빈 Container 출력
        child: Text('${saved_data.length}'),
      );
  }

  Widget listItem(index) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Image.network(
              ytResult[index].thumbnail?['default']['url'], // 표시할 썸네일 image
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
                        ytResult[index].title, // 해당 동영상 제목
                        softWrap: true,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 1.5)),
                      Text(
                        ytResult[index].channelTitle, // 채널이름
                        softWrap: true,
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 3.0)),
                      Text(
                        ytResult[index].url, // 해당 동영상 url
                        softWrap: true,
                      ),
                    ]))
          ],
        ),
      ),
    );
  }
}
