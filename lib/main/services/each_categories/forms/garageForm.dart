import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_pickers/currency_pickers.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/main/services/garages.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/utils/compressMedia.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:garage/widgets/fullScreenFile.dart';
import 'package:garage/widgets/imageCropper.dart';
import 'package:garage/widgets/maps/location.dart';
import 'package:garage/widgets/openGallery.dart';
import 'package:garage/widgets/videoTrimmer.dart';
import 'package:garage/widgets/video_players/videoPlayerFile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as dd;
import 'package:photo_manager/photo_manager.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:garage/utils/flush_bars.dart';
import 'package:progress_dialog/progress_dialog.dart';

class GarageForm extends StatefulWidget {
  final List engineType;
  final List vehicleType;
  final User currentUser;
  GarageForm({this.engineType, this.vehicleType, this.currentUser, Key key})
      : super(key: key);

  @override
  _GarageFormState createState() => _GarageFormState();
}

class _GarageFormState extends State<GarageForm> {
  double latitude;
  double longitude;
  TextEditingController garageName = TextEditingController();
  TextEditingController garagePhone = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  TextEditingController garageAddress = TextEditingController();
  List<File> media = [];
  List<String> mediaType = [];
  List<String> repairsType = [];
  List vehicleTypes = [];
  List engineTypes = [];
  List<List<TextEditingController>> priceControllers = [];
  List<List<TextEditingController>> allRepairForPrice = [];
  String currentCurrencyType;
  final format = dd.DateFormat("HH:mm");
  DateTime open;
  DateTime close;
  List<int> closingDays = [];
  List<String> selectedClosingDays = [];
  List<String> daysOfAWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    vehicleTypes = widget.vehicleType;
    engineTypes = widget.engineType;

    getCurrentCurrency();

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
                Text("making your garage...",
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

  getCurrentCurrency() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> list = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      currentCurrencyType =
          CurrencyPickerUtils.getCountryByIsoCode(list[0].isoCountryCode)
              .currencyCode
              .toString();
    });
  }

  done() async {
    if (garageName.text.trim() != "") {
      if (garagePhone.text.trim() != "") {
        if (openController.text.trim() != "" &&
            closeController.text.trim() != "") {
          if (garageAddress.text.trim() != "") {
            if (latitude != null && longitude != null) {
              pr.show();
              QuerySnapshot snap =
                  await checkGarageNameAlreadyExist(garageName.text.trim());
              if (snap.documents.isEmpty) {
                List mediaOrig = [];
                Map<String, List<int>> eachPrice = {};
                List mediaThumb = [];
                List allTypesOfMedia = [];

                if (repairsType.isNotEmpty) {
                  for (var i = 0; i < repairsType.length; i++) {
                    List<int> eachp = [];
                    allRepairForPrice[i].forEach((element) {
                      eachp.add(int.parse(element.text.trim()));
                    });
                    eachPrice[repairsType[i]] = eachp;
                  }
                }

                if (media.isNotEmpty) {
                  for (var j = 0; j < media.length; j++) {
                    if (mediaType[j] == "image") {
                      String downUrl = await uploadImageToGarage(
                          await compressImageFile(media[j], 90));
                      mediaOrig.add(downUrl);
                      String downThumbImageUrl = await uploadThumbImageToGarage(
                          await getThumbnailForImage(media[j], 45));
                      mediaThumb.add(downThumbImageUrl);
                      allTypesOfMedia.add("image");
                    } else {
                      String downVideoUrl = await uploadVideoToGarage(
                          await compressVideoFile(media[j]));
                      mediaOrig.add(downVideoUrl);
                      String downThumbVideoUrl = await uploadThumbVideoToGarage(
                          await getThumbnailForVideo(media[j]));
                      mediaThumb.add(downThumbVideoUrl);
                      allTypesOfMedia.add("video");
                    }
                  }
                }

                addAGarage(
                  widget.currentUser.id,
                  garageName.text.trim(),
                  garagePhone.text.trim(),
                  latitude,
                  longitude,
                  vehicleTypes,
                  engineTypes,
                  repairsType,
                  json.encode(eachPrice),
                  mediaOrig,
                  mediaThumb,
                  allTypesOfMedia,
                  garageAddress.text.trim(),
                  Timestamp.fromDate(open),
                  Timestamp.fromDate(close),
                  closingDays,
                  currentCurrencyType,
                );

                pr.hide().whenComplete(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Garages(
                                currentUser: widget.currentUser,
                              )));
                });
              } else {
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Provided name for the garage is already in!");
              }
            } else {
              GradientSnackBar.showMessage(
                  context, "Provide location for the garage!");
            }
          } else {
            GradientSnackBar.showMessage(
                context, "Provide current address for the garage!");
          }
        } else {
          GradientSnackBar.showMessage(context, "Provide open & close time!");
        }
      } else {
        GradientSnackBar.showMessage(
            context, "Provide contact number of garage!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Provide name for the garage!");
    }
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

                                  setState(() {
                                    media.add(image);
                                    mediaType.add("image");
                                  });
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

                                  setState(() {
                                    media.add(video);
                                    mediaType.add("video");
                                  });
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

                              imgList.forEach((element) {
                                String type;
                                if (element.type.toString() ==
                                    "AssetType.image") {
                                  type = "image";
                                } else {
                                  type = "video";
                                }

                                element.file.then((file) {
                                  if (type == "image") {
                                    setState(() {
                                      media.add(file);
                                      mediaType.add(type);
                                    });
                                  } else {
                                    setState(() {
                                      media.add(file);
                                      mediaType.add(type);
                                    });
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

  Widget textField(String textHint, TextEditingController _controller,
      int maxLines, bool isReadOnly) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      maxLines: maxLines,
      readOnly: isReadOnly,
      onTap: !isReadOnly ? null : () {},
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        suffix: Padding(
          padding: EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.clear();
              });
            },
            child: Image.asset(
              "assets/Icons/close.png",
              width: 20,
              height: 20,
            ),
          ),
        ),
        hintText: textHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Color.fromRGBO(129, 165, 168, 1),
          fontSize: 18,
        ),
      ),
    );
  }

  Widget phoneNumberField(String textHint, TextEditingController _controller,
      int maxLines, bool isReadonly) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      maxLines: maxLines,
      readOnly: isReadonly,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        suffix: Padding(
          padding: EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.clear();
              });
            },
            child: Image.asset(
              "assets/Icons/close.png",
              width: 20,
              height: 20,
            ),
          ),
        ),
        hintText: textHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Color.fromRGBO(129, 165, 168, 1),
          fontSize: 18,
        ),
      ),
    );
  }

  Widget conatinerOfTextField(
    double width,
    double height,
    String hint,
    TextEditingController _controller,
    int maxLines,
    bool isReadOnly,
    bool isPhone,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.03,
        right: width * 0.1,
        left: width * 0.1,
      ),
      child: Center(
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Color.fromRGBO(129, 165, 168, 1),
                width: 1,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: height * 0.01,
                bottom: height * 0.01,
                // right: width * 0.4,
              ),
              child: Center(
                child: isPhone
                    ? phoneNumberField(hint, _controller, maxLines, isReadOnly)
                    : textField(hint, _controller, maxLines, isReadOnly),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget conatinerOfLocation(
    double width,
    double height,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.03,
        right: width * 0.1,
        left: width * 0.1,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            List<double> reCoord = [];
            reCoord.add(latitude);
            reCoord.add(longitude);
            List<double> locationCoord = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Location(
                          locationCoord: latitude != null ? reCoord : null,
                        )));
            if (locationCoord != null) {
              if (locationCoord.isNotEmpty) {
                setState(() {
                  latitude = locationCoord[0];
                  longitude = locationCoord[1];
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Color.fromRGBO(129, 165, 168, 1),
                width: 1,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: height * 0.03,
                bottom: height * 0.03,
                // right: width * 0.4,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: latitude != null
                          ? Colors.black
                          : Color.fromRGBO(129, 165, 168, 1),
                      size: 30,
                    ),
                    latitude != null
                        ? Text(
                            "Location placed",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          )
                        : Text(
                            "Set location for the garage",
                            style: TextStyle(
                              color: Color.fromRGBO(129, 165, 168, 1),
                              fontSize: 18,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget openAndClose(double width, double height, bool isOpen,
      TextEditingController _controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.01,
      ),
      child: Center(
        child: Container(
          width: width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Color.fromRGBO(129, 165, 168, 1),
              width: 1,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: height * 0.01,
              bottom: height * 0.01,
              // right: width * 0.4,
            ),
            child: Center(
              child: DateTimeField(
                format: format,
                controller: _controller,
                onChanged: (value) {
                  if (isOpen) {
                    setState(() {
                      open = value;
                    });
                  } else {
                    setState(() {
                      close = value;
                    });
                  }
                },
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: isOpen ? 'Open At' : 'Close At',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(129, 165, 168, 1),
                    fontSize: 18,
                  ),
                ),
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );

                  return DateTimeField.convert(time);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  priceBottomSheet(List vehicleType, double width, double height, int inNum) {
    TextEditingController current = allRepairForPrice[inNum][0];
    String currentVehicleType = vehicleType[0];
    String currentVehicleTypeHint = "Enter cost for " + vehicleType[0];
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            useRootNavigator: true,
            clipBehavior: Clip.hardEdge,
            enableDrag: true,
            context: context,
            isScrollControlled: true,
            builder: (BuildContext bc) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: new BoxDecoration(
                      color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(50.0),
                          topRight: const Radius.circular(50.0))),
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 3,
                    top: 30,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: new Wrap(
                      children: <Widget>[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Add rough cost for the repair",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: height * 0.1,
                                child: ListView.builder(
                                    itemCount: vehicleType.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentVehicleType =
                                                vehicleType[index];

                                            List<TextEditingController>
                                                allTextSi =
                                                allRepairForPrice[inNum];

                                            int indexOf = allTextSi.indexOf(
                                                priceControllers[inNum][index]);
                                            current = allRepairForPrice[inNum]
                                                [indexOf];
                                            currentVehicleTypeHint =
                                                "Enter cost for " +
                                                    vehicleType[index];
                                          });
                                        },
                                        child: Container(
                                          width: width * 0.30,
                                          height: height * 0.1,
                                          child: Card(
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            child: Container(
                                              width: width * 0.30,
                                              height: height * 0.1,
                                              color: currentVehicleType ==
                                                      vehicleType[index]
                                                  ? Palette.appColor
                                                  : Colors.white,
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      height * 0.01),
                                                  child: Text(
                                                    vehicleType[index],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            elevation: 5,
                                            margin: EdgeInsets.all(5),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Color.fromRGBO(129, 165, 168, 1),
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: height * 0.01,
                                    bottom: height * 0.01,
                                    // right: width * 0.4,
                                  ),
                                  child: Center(
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: current,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      maxLines: 1,
                                      autofocus: true,
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20,
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        suffix: Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                current.clear();
                                              });
                                            },
                                            child: Image.asset(
                                              "assets/Icons/close.png",
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                        ),
                                        prefix: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            currentCurrencyType,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        hintText: currentVehicleTypeHint,
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }) ??
        false;
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
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            "Make the garage",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          leading: IconButton(
              icon: Image.asset(
                'assets/Icons/left-arrow.png',
                width: width * 0.07,
                height: height * 0.07,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  await done();
                },
                child: Center(
                    child: Text("Done",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ))),
                color: Palette.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Palette.appColor,
                    )),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.03,
              ),
              Text(
                "Add images & video about your garage",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              media.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            pickMedia();
                          },
                          child: Container(
                            width: width * 0.30,
                            height: height * 0.15,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                width: width * 0.30,
                                height: height * 0.15,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(height * 0.01),
                                    child: Image.asset(
                                      'assets/Icons/add.png',
                                      width: 60,
                                      height: 60,
                                      color: Color.fromRGBO(129, 165, 168, 1),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 10,
                              margin: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: height * 0.3,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: media.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  index == 0
                                      ? GestureDetector(
                                          onTap: () {
                                            pickMedia();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.30,
                                              height: height * 0.15,
                                              child: Card(
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                child: Container(
                                                  width: width * 0.30,
                                                  height: height * 0.15,
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          height * 0.01),
                                                      child: Image.asset(
                                                        'assets/Icons/add.png',
                                                        width: 60,
                                                        height: 60,
                                                        color: Color.fromRGBO(
                                                            129, 165, 168, 1),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                elevation: 10,
                                                margin: EdgeInsets.all(5),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  Stack(
                                    children: <Widget>[
                                      Container(
                                        width: width * 0.5,
                                        height: height * 0.3,
                                        color: Colors.white,
                                        child: Card(
                                          semanticContainer: true,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: mediaType[index] == "image"
                                              ? GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenFile(
                                                                file: media[
                                                                    index],
                                                                isImage: true,
                                                              )),
                                                    );
                                                  },
                                                  child: Image.file(
                                                    media[index],
                                                    fit: BoxFit.fill,
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {},
                                                  child: VideoPlayerFile(
                                                    isVolume: false,
                                                    video: media[index],
                                                    isSmall: true,
                                                  ),
                                                ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 15,
                                          margin: EdgeInsets.all(10),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.35),
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            if (mediaType[index] == "image") {
                                              cropImageFile(media[index])
                                                  .then((croppedImage) {
                                                if (croppedImage != null) {
                                                  setState(() {
                                                    media[index] = croppedImage;
                                                  });
                                                }
                                              });
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoTrimmer(
                                                            videoFile:
                                                                media[index],
                                                          ))).then((video) {
                                                setState(() {
                                                  media[index] = video;
                                                });
                                              });
                                            }
                                          },
                                          backgroundColor: Palette.appColor,
                                          child: Image.asset(
                                            'assets/Icons/cut.png',
                                            width: 30,
                                            height: 30,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      FloatingActionButton(
                                        heroTag: index + 3,
                                        onPressed: () {
                                          setState(() {
                                            media.removeAt(index);
                                            mediaType.removeAt(index);
                                          });
                                        },
                                        backgroundColor: Palette.appColor,
                                        child: Image.asset(
                                          'assets/Icons/close.png',
                                          width: 30,
                                          height: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Fill the details boxes",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
              conatinerOfTextField(
                  width, height, "Garage name", garageName, 1, false, false),
              conatinerOfTextField(width, height, "Garage contact number",
                  garagePhone, 1, false, true),
              SizedBox(
                height: 20,
              ),
              Text(
                "Enter open and close time of the garage",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  openAndClose(width, height, true, openController),
                  openAndClose(width, height, false, closeController),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Mention days of close your garage",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                  height: height * 0.1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysOfAWeek.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (daysOfAWeek[index] == "Monday") {
                                if (selectedClosingDays.contains("Monday")) {
                                  setState(() {
                                    closingDays.remove(1);
                                    selectedClosingDays.remove("Monday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(1);
                                    selectedClosingDays.add("Monday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Tuesday") {
                                if (selectedClosingDays.contains("Tuesday")) {
                                  setState(() {
                                    closingDays.remove(2);
                                    selectedClosingDays.remove("Tuesday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(2);
                                    selectedClosingDays.add("Tuesday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Wednesday") {
                                if (selectedClosingDays.contains("Wednesday")) {
                                  setState(() {
                                    closingDays.remove(3);
                                    selectedClosingDays.remove("Wednesday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(3);
                                    selectedClosingDays.add("Wednesday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Thursday") {
                                if (selectedClosingDays.contains("Thursday")) {
                                  setState(() {
                                    closingDays.remove(4);
                                    selectedClosingDays.remove("Thursday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(4);
                                    selectedClosingDays.add("Thursday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Friday") {
                                if (selectedClosingDays.contains("Friday")) {
                                  setState(() {
                                    closingDays.remove(5);
                                    selectedClosingDays.remove("Friday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(5);
                                    selectedClosingDays.add("Friday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Saturday") {
                                if (selectedClosingDays.contains("Saturday")) {
                                  setState(() {
                                    closingDays.remove(6);
                                    selectedClosingDays.remove("Saturday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(6);
                                    selectedClosingDays.add("Saturday");
                                  });
                                }
                              }
                              if (daysOfAWeek[index] == "Sunday") {
                                if (selectedClosingDays.contains("Sunday")) {
                                  setState(() {
                                    closingDays.remove(7);
                                    selectedClosingDays.remove("Sunday");
                                  });
                                } else {
                                  setState(() {
                                    closingDays.add(7);
                                    selectedClosingDays.add("Sunday");
                                  });
                                }
                              }
                            },
                            child: Container(
                              width: width * 0.3,
                              height: height * 0.1,
                              color: Colors.white,
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                color: selectedClosingDays
                                        .contains(daysOfAWeek[index])
                                    ? Colors.red
                                    : Colors.white,
                                child: Center(
                                  child: Text(daysOfAWeek[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selectedClosingDays
                                                .contains(daysOfAWeek[index])
                                            ? Colors.white
                                            : Color.fromRGBO(129, 165, 168, 1),
                                        fontSize: 17,
                                      )),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                              ),
                            ),
                          );
                        }),
                  )),
              conatinerOfTextField(width, height, "Garage current address",
                  garageAddress, 2, false, false),
              conatinerOfLocation(width, height),
              SizedBox(
                height: 30,
              ),
              Text(
                "Repairs that your garage perform,",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
              Text(
                "(optional add rough cost for each)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: height * 0.23,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Container(
                    color: Colors.white,
                    child: FutureBuilder(
                        future: DefaultAssetBundle.of(context)
                            .loadString('assets/json/garage_repairs.json'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return circularProgress();
                          }
                          List myData = json.decode(snapshot.data);
                          // myData.shuffle();

                          return ListView.builder(
                              itemCount: myData.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (repairsType
                                        .contains(myData[index]['repair'])) {
                                      setState(() {
                                        repairsType
                                            .remove(myData[index]['repair']);
                                        priceControllers.removeAt(index);
                                        allRepairForPrice.removeAt(index);
                                      });
                                    } else {
                                      List<TextEditingController> priceEach =
                                          [];
                                      vehicleTypes.forEach((element) {
                                        priceEach.add(TextEditingController());
                                      });
                                      setState(() {
                                        repairsType
                                            .add(myData[index]['repair']);
                                        priceControllers.add(priceEach);
                                        allRepairForPrice.add(priceEach);
                                      });
                                    }

                                    // var repairIs = repairsType.firstWhere(
                                    //     (element) =>
                                    //         element["repair"] ==
                                    //         myData[index]['repair'],
                                    //     orElse: () => null);
                                    // if (repairIs != null) {
                                    //   setState(() {
                                    //     repairsType.removeWhere((item) =>
                                    //         item['repair'] ==
                                    //         myData[index]['repair']);
                                    //     priceControllers.removeAt(index);
                                    //     allRepairForPrice.removeAt(index);
                                    //   });
                                    // } else {
                                    //   var repair = {
                                    //     "repair": myData[index]['repair'],
                                    //     "priceForEach": null
                                    //   };
                                    //   List<TextEditingController> priceEach =
                                    //       [];
                                    //   vehicleTypes.forEach((element) {
                                    //     priceEach.add(TextEditingController());
                                    //   });
                                    //   setState(() {
                                    //     repairsType.add(repair);
                                    //     priceControllers.add(priceEach);
                                    //     allRepairForPrice.add(priceEach);
                                    //   });
                                    // }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Container(
                                      width: width * 0.5,
                                      height: height * 0.23,
                                      color: Colors.white,
                                      child: Card(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: Container(
                                          width: width * 0.5,
                                          height: height * 0.23,
                                          color: repairsType.contains(
                                            myData[index]['repair'],
                                          )
                                              ? Palette.appColor
                                              : Colors.white,
                                          child: Column(
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      10,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        myData[index]['repair'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: repairsType
                                                                  .contains(
                                                            myData[index]
                                                                ['repair'],
                                                          )
                                                              ? Colors.black
                                                              : Color.fromRGBO(
                                                                  129,
                                                                  165,
                                                                  168,
                                                                  1),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        !repairsType.contains(
                                                      myData[index]['repair'],
                                                    )
                                                            ? null
                                                            : () {
                                                                priceBottomSheet(
                                                                    vehicleTypes,
                                                                    width,
                                                                    height,
                                                                    index);
                                                              },
                                                    child: Image.asset(
                                                        'assets/Icons/price.png',
                                                        width: 60,
                                                        height: 60,
                                                        color: !repairsType
                                                                .contains(
                                                          myData[index]
                                                              ['repair'],
                                                        )
                                                            ? Color.fromRGBO(
                                                                129,
                                                                165,
                                                                168,
                                                                1)
                                                            : Colors.black),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        elevation: 15,
                                        margin: EdgeInsets.all(10),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ));
  }
}
