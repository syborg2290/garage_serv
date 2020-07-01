import 'dart:io';

import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/utils/compressMedia.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:garage/widgets/fullScreenNetworkFile.dart';
import 'package:garage/widgets/imageCropper.dart';
import 'package:garage/widgets/openGallery.dart';
import 'package:garage/widgets/videoTrimmer.dart';
import 'package:garage/widgets/video_players/videoPlayerNetwork.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GarageMedia extends StatefulWidget {
  final Garage garage;
  final String docId;
  GarageMedia({this.garage, this.docId, Key key}) : super(key: key);

  @override
  _GarageMediaState createState() => _GarageMediaState();
}

class _GarageMediaState extends State<GarageMedia> {
  List<File> media = [];
  List<String> mediaType = [];
  ProgressDialog pr;
  String currentUserId;

  getCurrentUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = pref.getString('userid');
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
                Text("updating media...",
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

  uploadImages(File image) async {
    String downUrl =
        await uploadImageToGarage(await compressImageFile(image, 90));
    String downThumbImageUrl =
        await uploadThumbImageToGarage(await getThumbnailForImage(image, 45));
    await updateMediaForGarage(
        widget.garage.id, downUrl, downThumbImageUrl, "image", widget.docId);
  }

  uploadVideos(File video) async {
    String downVideoUrl =
        await uploadVideoToGarage(await compressVideoFile(video));
    String downThumbVideoUrl =
        await uploadThumbVideoToGarage(await getThumbnailForVideo(video));
    await updateMediaForGarage(widget.garage.id, downVideoUrl,
        downThumbVideoUrl, "video", widget.docId);
  }

  pickMedia() async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 9.0,
        useRootNavigator: true,
        clipBehavior: Clip.hardEdge,
        enableDrag: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: 90,
              decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(50.0),
                      topRight: const Radius.circular(50.0))),
              child: new Wrap(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                File image = await ImagePicker.pickImage(
                                  source: ImageSource.camera,
                                );

                                if (image != null) {
                                  Navigator.pop(context);

                                  File croppedImage =
                                      await cropImageFile(image);
                                  pr.show();
                                  if (croppedImage != null) {
                                    await uploadImages(croppedImage);
                                    pr.hide();
                                  } else {
                                    await uploadImages(image);
                                    pr.hide();
                                  }
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset(
                                  'assets/Icons/camera.png',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                            Text("Cam photo",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                        ),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                File video = await ImagePicker.pickVideo(
                                  source: ImageSource.camera,
                                );

                                if (video != null) {
                                  Navigator.pop(context);

                                  File videoTrimmed = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VideoTrimmer(
                                              videoFile: video,
                                            )),
                                  );
                                  pr.show();
                                  if (videoTrimmed != null) {
                                    await uploadVideos(videoTrimmed);
                                    pr.hide();
                                  } else {
                                    await uploadVideos(video);
                                    pr.hide();
                                  }
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset(
                                  'assets/Icons/video.png',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                            Text("Cam video",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          List<AssetEntity> imgList = await openGalleryWindow(
                              context, 10, PickType.all);

                          if (imgList != null) {
                            if (imgList.isNotEmpty) {
                              Navigator.pop(context);

                              imgList.forEach((element) async {
                                String type;
                                if (element.type.toString() ==
                                    "AssetType.image") {
                                  type = "image";
                                } else {
                                  type = "video";
                                }

                                element.file.then((file) async {
                                  if (type == "image") {
                                    File croppedImage =
                                        await cropImageFile(file);
                                    pr.show();
                                    if (croppedImage != null) {
                                      await uploadImages(croppedImage);
                                      pr.hide();
                                    } else {
                                      await uploadImages(file);
                                      pr.hide();
                                    }
                                  } else {
                                    if (file != null) {
                                      File videoTrimmed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => VideoTrimmer(
                                                  videoFile: file,
                                                )),
                                      );
                                      pr.show();
                                      if (videoTrimmed != null) {
                                        await uploadVideos(videoTrimmed);
                                        pr.hide();
                                      } else {
                                        await uploadVideos(file);
                                        pr.hide();
                                      }
                                    }
                                  }
                                });
                              });
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 30,
                            left: 30,
                          ),
                          child: Column(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset(
                                  'assets/Icons/gallery.png',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              Text("Gallery",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/Icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          widget.garage.garageName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
        ),
        actions: <Widget>[
          currentUserId == widget.garage.addedId
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Image.asset(
                        'assets/Icons/plus.png',
                        width: 60,
                        height: 60,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        pickMedia();
                      }))
              : SizedBox.shrink(),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: streamingSingleGarage(widget.garage.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: EmptyListWidget(
                      title: 'No Media',
                      subTitle: 'No Media available yet',
                      image: 'assets/designs/empty.png',
                      titleTextStyle: Theme.of(context)
                          .typography
                          .dense
                          .display1
                          .copyWith(color: Color(0xff9da9c7)),
                      subtitleTextStyle: Theme.of(context)
                          .typography
                          .dense
                          .body2
                          .copyWith(color: Color(0xffabb8d6))));
            } else {
              List mediaOrig = [];
              List mediaThumb = [];
              List mediaTypes = [];

              snapshot.data.documents.forEach((doc) {
                Garage ga = Garage.fromDocument(doc);
                mediaOrig = ga.mediaOrig;
                mediaThumb = ga.mediaThumb;
                mediaTypes = ga.mediaTypes;
              });

              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                children: List.generate(mediaOrig.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullScreenNetworkFile(
                                  isImage: mediaTypes[index] == "image"
                                      ? true
                                      : false,
                                  media: mediaOrig[index],
                                  isCurrentUser:
                                      currentUserId == widget.garage.addedId
                                          ? true
                                          : false,
                                  index: index,
                                  docId: widget.docId,
                                  garageId: widget.garage.id,
                                  thumb: mediaThumb[index],
                                )),
                      );
                    },
                    child: Container(
                      child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: Colors.white,
                          child: mediaTypes[index] == "image"
                              ? Image.network(
                                  mediaThumb[index],
                                  fit: BoxFit.cover,
                                )
                              : NetworkPlayer(
                                  isVolume: false,
                                  video: mediaOrig[index],
                                  isSmall: true,
                                )),
                      margin: EdgeInsets.all(0),
                    ),
                  );
                }),
              );
            }
          }
        },
      ),
    );
  }
}
