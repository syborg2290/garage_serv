import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:video_player/video_player.dart';

class NetworkPlayer extends StatefulWidget {
  final String video;
  final bool isVolume;
  final bool isSmall;
  NetworkPlayer({this.video, this.isVolume, this.isSmall, Key key})
      : super(key: key);

  @override
  _NetworkPlayerState createState() => _NetworkPlayerState();
}

class _NetworkPlayerState extends State<NetworkPlayer> {
  VideoPlayerController _controller;
  Duration resumeTime;
  double _lowerValue;
  double _upperValue;
  double max = 0;
  int position = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video)
      ..addListener(() {
        setState(() {
          position = _controller.value.position.inSeconds;
        });
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          max = _controller.value.duration.inSeconds.toDouble();
        });
      });
    _controller.setLooping(true);
    //_controller.seekTo(resumeTime);
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? GestureDetector(
              onTap: () {},
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: VideoPlayer(_controller)),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                          resumeTime = _controller.value.position;
                          position = _controller.value.position.inSeconds;
                        });
                      },
                      child: ClipOval(
                        child: Container(
                          color: _controller.value.isPlaying
                              ? Colors.transparent
                              : Colors.transparent,

                          height: 50.0, // height of the button
                          width: 50.0, // width of the button
                          child: Center(
                              child: _controller.value.isPlaying
                                  ? Image.asset(
                                      'assets/Icons/pause.png',
                                      color: Color(0xffe0e0e0),
                                      width: widget.isSmall ? 30 : 40,
                                      height: widget.isSmall ? 30 : 40,
                                    )
                                  : Image.asset(
                                      'assets/Icons/play.png',
                                      color: Color(0xffe0e0e0),
                                      width: widget.isSmall ? 30 : 40,
                                      height: widget.isSmall ? 30 : 40,
                                    )),
                        ),
                      ),
                    ),
                  ),
                  !_controller.value.isPlaying
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.6,
                              left: 20),
                          child: Animator(
                            duration: Duration(milliseconds: 2000),
                            tween: Tween(begin: 1.2, end: 1.5),
                            curve: Curves.bounceOut,
                            cycles: 0,
                            builder: (anim) => Transform.scale(
                              scale: anim.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Palette.appColor,
                                  border: Border.all(
                                    width: 3,
                                    color: Palette.appColor,
                                  ),
                                ),
                                child: Text(
                                  _printDuration(_controller.value.duration),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      : Text(""),
                  widget.isVolume
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.6,
                              left: 320),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.value.volume == 0.0
                                    ? _controller.setVolume(1.0)
                                    : _controller.setVolume(0.0);
                              });
                            },
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _controller.value.volume == 0.0
                                      ? _controller.setVolume(1.0)
                                      : _controller.setVolume(0.0);
                                });
                              },
                              icon: Icon(
                                _controller.value.volume == 0.0
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                      : Text(""),
                  _controller.value.isPlaying
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.6,
                              right: 78,
                              left: 20),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    color: Colors.black,
                                    child: Text(
                                        _printDuration(
                                            Duration(seconds: position)),
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  Container(
                                    color: Colors.black,
                                    child: Text(
                                        _printDuration(
                                            Duration(seconds: max.toInt())),
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              FlutterSlider(
                                trackBar: FlutterSliderTrackBar(
                                  inactiveTrackBar: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 13,
                                      color: Palette.appColor,
                                    ),
                                  ),
                                  activeTrackBar: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Palette.appColor,
                                    border: Border.all(
                                        width: 13, color: Colors.white),
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
                                handlerHeight: 20,
                                handler: FlutterSliderHandler(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Palette.appColor,
                                    border: Border.all(
                                        width: 13, color: Colors.white),
                                  ),
                                ),
                                jump: true,
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
                            ],
                          ),
                        )
                      : Text(""),
                ],
              ),
            )
          : Container(
              color: Colors.black,
              child: circularProgress(),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
