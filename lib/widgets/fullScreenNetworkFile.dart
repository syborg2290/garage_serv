import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';

class FullScreenNetworkFile extends StatefulWidget {
  final String media;
  final String thumb;
  final bool isImage;
  final bool isCurrentUser;
  final int index;
  final String garageId;
  final String docId;
  FullScreenNetworkFile(
      {this.media,
      this.thumb,
      this.isImage,
      this.isCurrentUser,
      this.index,
      this.garageId,
      this.docId,
      Key key})
      : super(key: key);

  @override
  _FullScreenNetworkFileState createState() => _FullScreenNetworkFileState();
}

class _FullScreenNetworkFileState extends State<FullScreenNetworkFile> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  bool isLoading = true;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    if (!widget.isImage) {
      videoPlayerController = VideoPlayerController.network(widget.media);

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
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                flashProgress(),
                Text("removing media...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
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
        actions: <Widget>[
          widget.isCurrentUser
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      icon: Image.asset(
                        'assets/Icons/delete.png',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        pr.show();
                        await removeMediaFromGarage(
                            widget.index, widget.garageId, widget.docId);
                        await deleteStorage(widget.media);
                        await deleteStorage(widget.thumb);
                        pr.hide().whenComplete(() {
                          Navigator.pop(context);
                        });
                      }),
                )
              : SizedBox.shrink()
        ],
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Container(
          child: widget.isImage
              ? PhotoView(
                  imageProvider: NetworkImage(widget.media),
                )
              : isLoading
                  ? circularProgress()
                  : Chewie(
                      controller: chewieController,
                    )),
    );
  }
}
