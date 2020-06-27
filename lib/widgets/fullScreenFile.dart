import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class FullScreenFile extends StatefulWidget {
  final File file;
  final bool isImage;
  FullScreenFile({this.file, this.isImage, Key key}) : super(key: key);

  @override
  _FullScreenFileState createState() => _FullScreenFileState();
}

class _FullScreenFileState extends State<FullScreenFile> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (!widget.isImage) {
      videoPlayerController = VideoPlayerController.file(widget.file);

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 3 / 2,
        autoPlay: true,
        looping: true,
        materialProgressColors: ChewieProgressColors(
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black,
          handleColor: Palette.appColor,
          playedColor: Palette.appColor,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          backgroundColor: Colors.black,
          handleColor: Palette.appColor,
          playedColor: Palette.appColor,
        ),
      );
      isLoading = false;
    }
  }

  @override
  void dispose() {
    if (!widget.isImage) {
      videoPlayerController.dispose();
      chewieController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/Icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Container(
          child: widget.isImage
              ? PhotoView(
                  imageProvider: FileImage(widget.file),
                )
              : isLoading
                  ? circularProgress()
                  : Chewie(
                      controller: chewieController,
                    )),
    );
  }
}
