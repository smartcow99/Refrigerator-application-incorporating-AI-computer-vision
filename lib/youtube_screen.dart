import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeShow extends StatefulWidget {
  const YoutubeShow({Key? key}) : super(key: key);

  @override
  _YoutubeShowState createState() => _YoutubeShowState();
}

class _YoutubeShowState extends State<YoutubeShow> {
  YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'g9aXIpJFKyU',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      )
  );


  @override
  Widget build(BuildContext context) {
    return Container(
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
        ),
        builder: (context, player){
          return Column(
            children: [
              Container(
                color: Colors.red,
                child: Text('THis is first text'),
              ),
              player,
              Container(
                color: Colors.blue,
                child: Text('THis is second text'),
              ),

            ],
          );
        },
      )

    );
  }

}
