import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refrigerator/youtube_api/youtube_api.dart';
import 'package:refrigerator/youtube_api/yt_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'json_data.dart';
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
  // 초과시 다음의 key 로 바꾸세요!.
  // AIzaSyBA3z_uabghRz3RhkW26vrE3RDthkgHoBc
  // AIzaSyDvrFW2FCTr_mkWz5-Kv_-UGpRca6ftmHc
  static String key = "AIzaSyBA3z_uabghRz3RhkW26vrE3RDthkgHoBc";
  List<ListData> saved_data = [];

  // search 할 string 을 담는 변수
  String _data;
  YoutubeAPI ytApi = YoutubeAPI(
    key,
  );

  // search 한 결과를 Youtube API 로부터 받는 List 변수
  List<YT_API> ytResult = [];

  _ytPlayState(this._data);

  RecipeList list = RecipeList.fromJson([
    {
      "name": "닭볶음탕",
      "ingre": [
        "닭",
        "당면",
        "감자",
        "당근",
        "양파",
        "고추",
        "대파",
        "다진마늘",
        "우유",
        "멸치",
        "다시마",
        "표고버섯",
        "간장",
        "고추장",
        "고춧가루",
        "요리당",
        "간양파",
        "청주",
        "물",
        "후추",
        "참기름",
        "액젓"
      ]
    }
  ]);

  // API 를 통해서 해당 검색결과를 담아옴
  void callAPI() async {
    log('Running callAPI');
    ytResult = await ytApi.search(this._data, type: 'video');
    ytResult = await ytApi.nextPage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    callAPI();
    _readListData();
  }

  void _readListData() async {
    log('_readLIstData running...');
    final prefs = await SharedPreferences.getInstance();
    final key = 'ListData';
    final value = prefs.getStringList(key);
    var validate = DateTime.now().subtract(Duration(days: 5)); // 유통기한 마감 5일 기준!
    DateFormat('yyyy-MM-dd').format(validate); // 현재 날짜를 yyyy-MM--dd 형식으로 바꿈.

    try {
      for (int i = 0; i < value!.length; i++) {
        print(value[i]);
        var list = value[i].split('/');
        var list_validate = new DateFormat("yyyy-MM-dd").parse(list[1]);
        if (validate.isBefore(list_validate)) {
          // 유통기한이 얼마 남지 않은 경우
          saved_data.add(ListData(
              purchaseDate: list[0],
              expirationDate: list[1],
              itemName: list[2]));
        }
      }
      log('End _readListData');
      setState(() {});
    } catch (e) {
      log('_readData Error catch');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    log('this is build');
    int max = 0, pos = -1, cnt = 0;
    for (int i = 0; i < list.recipes.length; i++) {
      for (int j = 0; j < list.recipes[i].ingre.length; j++) {
        for (int k = 0; k < saved_data.length; k++) {
          if (saved_data[k].itemName == list.recipes[i].ingre[j]) {
            // 일치하는 재료가 있을경우
            cnt++;
          }
        }
      }

      if (cnt > max) {
        max = cnt;
        pos = i;
      }
      cnt = 0;
    }
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
                          builder: (context) => YoutubePlayerBuilder(
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
    else {
      if (pos >= 0)
        return Container(
          // 처음 시작시, 빈 Container 출력
          child: Text('${list.recipes[pos].name}'),
        );
      else
        return Container(
          child: Text('Error detected'),
        );
    }
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
