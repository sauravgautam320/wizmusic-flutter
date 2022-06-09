// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({required this.songInfo, required this.changeTrack, required this.key}):super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;
  int currentIndex=0;

  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose(){
    super.dispose();
    player?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setAudioSource(createPlaylist(widget.songInfo), initialIndex: widget.songInfo);
    currentValue = minimumValue;
    maximumValue = player.duration!.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying=false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue=duration.inMilliseconds.toDouble();
      setState((){
        currentTime=getDuration(currentValue);
      });
    });
  }

  void changeStatus(){
    setState((){
      isPlaying=!isPlaying;

    });
    if(isPlaying){
      player.play();
    }else{
      player.pause();
    }
  }


  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(15, 50, 5, 0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: widget.songInfo.albumArtwork == null
                  ? AssetImage('assets/images/album_image.jpg')
                  : FileImage(
                      File(widget.songInfo.albumArtwork),
                    ) as ImageProvider,
              radius: 95,
            ),
            Container(
              color: Colors.black,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
              child: Text(
                widget.songInfo.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              color: Colors.black,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                widget.songInfo.artist,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Slider(
              value: currentValue,
              min: minimumValue,
              max: maximumValue,
              onChanged: (value) {
                currentValue = value;
                player.seek(Duration(milliseconds: currentValue.round()));
              },
              inactiveColor: Colors.grey,
              activeColor: Colors.green,
            ),
            Container(
              transform: Matrix4.translationValues(0, -5, 0),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    endTime,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Icon(Icons.shuffle,
                      color: Colors.white, size: 25,),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      player.setShuffleModeEnabled(true);
                    },
                  ),
                  GestureDetector(
                    child: Icon(Icons.skip_previous,
                        color: Colors.white, size: 55,),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(false);
                    },
                  ),
                  GestureDetector(
                    child: Icon(isPlaying?Icons.pause:Icons.play_arrow,
                        color: Colors.white, size: 75,),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      changeStatus();
                    },
                  ),
                  GestureDetector(
                    child: Icon(Icons.skip_next,
                        color: Colors.white, size: 55,),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(true);
                    },
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: (){
                        player.loopMode == LoopMode.one ? player.setLoopMode(LoopMode.all) : player.setLoopMode(LoopMode.one);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<LoopMode>(
                          stream: player.loopModeStream,
                          builder: (context, snapshot){
                            final loopMode = snapshot.data;
                            if(LoopMode.one == loopMode){
                              return const Icon(Icons.repeat_one, color: Colors.white70,);
                            }
                            return const Icon(Icons.repeat, color: Colors.white70,);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


}
