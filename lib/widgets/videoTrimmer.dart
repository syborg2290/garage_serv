import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:video_player/video_player.dart';

class VideoTrimmer extends StatefulWidget {
  final File videoFile;

  VideoTrimmer({this.videoFile, Key key}) : super(key: key);

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState();
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  VideoPlayerController _controller;
  int position = 0;
  double _lowerValue;
  double _upperValue;
  double max = 0;
  int seconds = 0;
  File initVideoFile;
  File videoFileAf;
  String dirs;
  bool isLoad = true;
  List<File> frames = [];
  bool isFramesLoad = true;
  double firstrange = 0;
  double secondRange = 0;
  File thumbnail;

  @override
  void initState() {
    super.initState();
    videoFileAf = widget.videoFile;
    initVideoFile = widget.videoFile;
    videoInitialize();
  }

  videoInitialize() {
    _controller = VideoPlayerController.file(videoFileAf)
      ..addListener(() {
        setState(() {
          position = _controller.value.position.inSeconds;
        });
      })
      ..initialize().then((_) async {
        if (_controller.value.initialized) {
          setState(() {
            firstrange = 0;
            secondRange = _controller.value.duration.inSeconds.toDouble();
            seconds = _controller.value.duration.inSeconds;
            max = _controller.value.duration.inSeconds.toDouble();
            _controller.setLooping(true);
            isLoad = false;
          });
          await getVideoFrames();
        }
      });
  }

  getVideoFrames() async {
    setState(() {
      isFramesLoad = true;
    });
    dirs = (await getTemporaryDirectory()).path;
    File newFile = File("$dirs/videoTrimmedPath.mp4");
    newFile.writeAsBytesSync(videoFileAf.readAsBytesSync());
    String newPath = newFile.path;
    await _flutterFFmpeg
        .execute("-i $newPath -vf fps=1 $dirs/trimmedout%d.png");

    for (var i = 1; i < seconds; i++) {
      setState(() {
        frames.add(File("$dirs/trimmedout$i.png"));
      });
    }
    setState(() {
      thumbnail = File("$dirs/trimmedout2.png");
      isFramesLoad = false;
    });
  }

  refreshController() async {
    if (_controller == null) {
      videoInitialize();
    } else {
      final oldController = _controller;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController.dispose();
        setState(() {});
      });
      videoInitialize();
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  void _onItemFocus(int index) {
    setState(() {
      position = index;
    });

    _controller.seekTo(Duration(seconds: position));
  }

  done() {
    Navigator.pop(context, videoFileAf);
  }

  @override
  Widget build(BuildContext context) {
    var ori = MediaQuery.of(context).orientation;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text("Customize your video",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              )),
          leading: IconButton(
            icon: Image.asset(
              'assets/Icons/left-arrow.png',
              width: 30,
              height: 30,
              color: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                  icon: Icon(Icons.done, color: Colors.white), onPressed: done),
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: !isLoad
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Center(
                            child: _controller.value.initialized
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _controller.value.isPlaying
                                            ? _controller.pause()
                                            : _controller.pause();
                                      });
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        VideoPlayer(_controller),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _controller.value.isPlaying
                                                    ? _controller.pause()
                                                    : _controller.play();
                                              });
                                            },
                                            child: ClipOval(
                                              child: Container(
                                                color:
                                                    _controller.value.isPlaying
                                                        ? Colors.transparent
                                                        : Colors.transparent,

                                                height:
                                                    50.0, // height of the button
                                                width:
                                                    50.0, // width of the button
                                                child: Center(
                                                    child: _controller
                                                            .value.isPlaying
                                                        ? Image.asset(
                                                            'assets/Icons/pause.png',
                                                            color: Color(
                                                                0xffe0e0e0),
                                                          )
                                                        : Image.asset(
                                                            'assets/Icons/play.png',
                                                            color: Color(
                                                                0xffe0e0e0),
                                                          )),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    color: Colors.black,
                                    child: circularProgress(),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 25,
                            left: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_printDuration(Duration(seconds: position)),
                                  style: TextStyle(color: Colors.white)),
                              Text(_printDuration(Duration(seconds: seconds)),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: FlutterSlider(
                              handler: FlutterSliderHandler(
                                  child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Palette.appColor,
                                ),
                              )),
                              trackBar: FlutterSliderTrackBar(
                                inactiveTrackBar: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.yellow,
                                  border: Border.all(
                                      width: 13, color: Colors.yellow),
                                ),
                                activeTrackBar: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Palette.appColor,
                                ),
                              ),
                              tooltip: FlutterSliderTooltip(
                                disabled: true,
                              ),
                              handlerAnimation: FlutterSliderHandlerAnimation(
                                  curve: Curves.elasticOut,
                                  reverseCurve: Curves.bounceIn,
                                  duration: Duration(milliseconds: 500),
                                  scale: 1.5),
                              handlerHeight: 30,
                              values: [position.toDouble()],
                              max: max,
                              min: 0,
                              onDragCompleted:
                                  (handlerIndex, lowerValue, upperValue) {
                                _lowerValue = lowerValue;
                                _upperValue = upperValue;
                                setState(() {
                                  position = lowerValue.round();
                                  _controller
                                      .seekTo(Duration(seconds: position));
                                });
                              },
                              onDragStarted:
                                  (handlerIndex, lowerValue, upperValue) {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.play()
                                      : _controller.play();
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 0,
                            left: ori == Orientation.landscape ? 280 : 80,
                            right: ori == Orientation.landscape ? 220 : 80,
                          ),
                          child: FlatButton(
                            onPressed: () async {
                              setState(() {
                                videoFileAf = initVideoFile;
                              });
                              refreshController();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(
                                      isFramesLoad
                                          ? Icons.info_outline
                                          : Icons.undo,
                                      color: Colors.black,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                          isFramesLoad
                                              ? "Loading video frames"
                                              : "Redo changes",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            color: Palette.appColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0),
                                side: BorderSide(
                                  color: Palette.appColor,
                                )),
                          ),
                        ),
                        isFramesLoad
                            ? Padding(
                                padding: EdgeInsets.only(
                                  right: 30,
                                  left: 30,
                                  top: 10,
                                ),
                                child: Text("Loading video frames",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    )),
                              )
                            : Text(""),
                        SizedBox(
                          height: 20,
                        ),
                        !isFramesLoad
                            ? Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: Container(
                                  height: 150,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ScrollSnapList(
                                          onItemFocus: _onItemFocus,
                                          itemSize: 150,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (index == frames.length)
                                              return Center(
                                                child: circularProgress(),
                                              );

                                            //horizontal
                                            return index == 0
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 10,
                                                    ),
                                                    child: Image.asset(
                                                      'assets/Icons/hand.png',
                                                      color: Colors.white,
                                                      width: 70,
                                                      height: 70,
                                                    ),
                                                  )
                                                : Image.file(frames[index]);
                                          },
                                          itemCount: frames.length,
                                          dynamicItemSize: false,
                                          // dynamicSizeEquation: customEquation, //optional
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : circularProgress(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      _printDuration(Duration(
                                          seconds: firstrange.toInt())),
                                      style: TextStyle(color: Colors.white)),
                                  Text(
                                      _printDuration(
                                          Duration(seconds: seconds)),
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Container(
                                child: FlutterSlider(
                                  values: [firstrange, secondRange],
                                  rangeSlider: true,
                                  disabled: isFramesLoad,
                                  max: max,
                                  axis: Axis.horizontal,
                                  jump: true,
                                  min: 0,
                                  handlerHeight: 30,
                                  tooltip: FlutterSliderTooltip(
                                    disabled: true,
                                  ),
                                  trackBar: FlutterSliderTrackBar(
                                    inactiveTrackBar: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.yellow,
                                      border: Border.all(
                                          width: 13, color: Colors.yellow),
                                    ),
                                    activeTrackBar: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Palette.appColor,
                                    ),
                                  ),
                                  rightHandler: FlutterSliderHandler(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/Icons/cut.png'),
                                  )),
                                  handler: FlutterSliderHandler(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/Icons/cut.png'),
                                  )),
                                  handlerAnimation:
                                      FlutterSliderHandlerAnimation(
                                          curve: Curves.elasticOut,
                                          reverseCurve: Curves.bounceIn,
                                          duration: Duration(milliseconds: 500),
                                          scale: 1.5),
                                  onDragCompleted: (handlerIndex, lowerValue,
                                      upperValue) async {
                                    dirs = (await getTemporaryDirectory()).path;
                                    setState(() {
                                      firstrange = lowerValue;
                                      secondRange = upperValue;
                                    });
                                    File oldvideoFile =
                                        File('$dirs/oldVideoPath736.mp3');
                                    oldvideoFile.writeAsBytesSync(
                                        videoFileAf.readAsBytesSync());

                                    String oldVideoPath = oldvideoFile.path;

                                    await _flutterFFmpeg.execute(
                                        "-y -i $oldVideoPath -ss $firstrange -to $secondRange -c:v copy -c:a copy $dirs/trimmedVideo.mp4");
                                    setState(() {
                                      videoFileAf =
                                          File("$dirs/trimmedVideo.mp4");
                                    });

                                    refreshController();
                                    _controller.play();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : circularProgress(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
