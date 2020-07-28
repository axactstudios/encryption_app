import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  String path;

  VideoPlayer({this.path});

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  FlickManager flickManager;

  VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    File video = File('/${widget.path}');
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(
        video,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FlickVideoPlayer(
        flickManager: flickManager,
      ),
    );
  }
}
