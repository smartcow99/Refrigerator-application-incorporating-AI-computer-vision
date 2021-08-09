import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlaying extends StatefulWidget {
  String id;

  YoutubePlaying({Key? key, required this.id}) : super(key: key);

  @override
  _YoutubePlayingState createState() => _YoutubePlayingState();
}

class _YoutubePlayingState extends State<YoutubePlaying> {
  late YoutubePlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(player: YoutubePlayer(
      controller: _controller,
    ), builder: (context, player){
      return Column(
        children: [
          // some widgets
          player,
          // some other widgets
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
        initialVideoId: widget.id,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: true,
        ));

  }
}
