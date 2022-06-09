// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:wizmusic/music_player.dart';

class Tracks extends StatefulWidget {
  const Tracks({Key? key}) : super(key: key);

  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  final GlobalKey<MusicPlayerState> key=GlobalKey<MusicPlayerState>();

  @override
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext){
    if(isNext){
      if(currentIndex!=songs.length-1){
        currentIndex++;
      }
    }else{
      if(currentIndex!=0){
        currentIndex--;
      }
    }
    key.currentState?.setSong(songs[currentIndex]);
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(
          Icons.music_note,
          color: Colors.white,
        ),
        title: const Text(
          'WizMusic',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(color: Colors.black,),
        itemCount: songs.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
              backgroundImage: songs[index].albumArtwork == null
                  ? AssetImage('assets/images/album_image.jpg')
                  : FileImage(
                      File(songs[index].albumArtwork),
                    ) as ImageProvider),
          title: Text(songs[index].title, style: TextStyle(color: Colors.white),),
          subtitle: Text(songs[index].artist, style: TextStyle(color: Colors.grey),),
          onTap: () {

            currentIndex = index;
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MusicPlayer(songInfo: songs[currentIndex],changeTrack: changeTrack, key: key,)));
          },
        ),
      ),
    );
  }
}
