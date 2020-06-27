import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:garage/config/collections.dart';
import 'package:garage/config/settings.dart';
import 'package:garage/models/user.dart';
import 'package:garage/modified_lib/google_places/lib/flutter_google_places.dart';
import 'package:garage/modified_lib/photo-0.4.8/lib/src/entity/options.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/compressMedia.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:garage/widgets/imageCropper.dart';
import 'package:garage/widgets/openGallery.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EditProfile extends StatefulWidget {
  final User user;
  EditProfile({this.user, Key key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File profileImage;
  TextEditingController username = TextEditingController();
  TextEditingController aboutYou = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController location = TextEditingController();
  DateTime dobDateTime;
  ProgressDialog pr;
  // String defaultCountryCode = "LK";

  @override
  void initState() {
    super.initState();
    username.text = widget.user.username;
    aboutYou.text = widget.user.aboutYou;
    phoneNumber.text = widget.user.contactNumber;
    dobDateTime = widget.user.dob.toDate();
    dob.text = widget.user.dob.toDate().year.toString() +
        "-" +
        widget.user.dob.toDate().month.toString() +
        "-" +
        widget.user.dob.toDate().day.toString();
    location.text = widget.user.location;
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
          child: circularProgress(),
        ),
      ),
      showLogs: false,
    );
  }

  done() async {
    pr.show();
    String imageUrl;
    String thumbnailUrl;
    if (profileImage != null) {
      File compressImage = await compressImageFile(profileImage, 90);
      File thumbnailImage = await getThumbnailForImage(profileImage, 45);

      imageUrl = await uploadImageProfilePic(widget.user.id, compressImage);
      thumbnailUrl =
          await uploadImageProfilePicThumbnail(widget.user.id, thumbnailImage);
      updateUserImage(widget.user.id, imageUrl, thumbnailUrl);

      var obj = {
        "id": widget.user.id,
        "firstname": widget.user.firstname,
        "lastname": widget.user.lastname,
        "username": username.text == "" ? widget.user.username : username.text,
        "contactNumber": phoneNumber.text == ""
            ? widget.user.contactNumber
            : phoneNumber.text,
        "location": location.text == "" ? widget.user.location : location.text,
        "dob": dob.text == ""
            ? widget.user.dob
            : Timestamp.fromMillisecondsSinceEpoch(
                dobDateTime.millisecondsSinceEpoch),
        "userPhotoUrl": imageUrl == "" ? widget.user.userPhotoUrl : imageUrl,
        "thumbnailUserPhotoUrl": thumbnailUrl == ""
            ? widget.user.thumbnailUserPhotoUrl
            : thumbnailUrl,
        "aboutYou": aboutYou.text == "" ? widget.user.aboutYou : aboutYou.text,
        "email": widget.user.email,
        "services": null,
        "isOnline": true,
        "recentOnline": timestamp,
        "active": true,
        "timestamp": timestamp,
      };
      await updateProfile(widget.user.id, obj);
      pr.hide().whenComplete(() {
        Navigator.pop(context);
      });
    } else {
      var obj = {
        "id": widget.user.id,
        "firstname": widget.user.firstname,
        "lastname": widget.user.lastname,
        "username": username.text == "" ? widget.user.username : username.text,
        "contactNumber": phoneNumber.text == ""
            ? widget.user.contactNumber
            : phoneNumber.text,
        "location": location.text == "" ? widget.user.location : location.text,
        "dob": dob.text == ""
            ? widget.user.dob
            : Timestamp.fromMillisecondsSinceEpoch(
                dobDateTime.millisecondsSinceEpoch),
        "userPhotoUrl": imageUrl == "" ? widget.user.userPhotoUrl : imageUrl,
        "thumbnailUserPhotoUrl": thumbnailUrl == ""
            ? widget.user.thumbnailUserPhotoUrl
            : thumbnailUrl,
        "aboutYou": aboutYou.text == "" ? widget.user.aboutYou : aboutYou.text,
        "email": widget.user.email,
        "services": null,
        "isOnline": true,
        "recentOnline": timestamp,
        "active": true,
        "timestamp": timestamp,
      };
      await updateProfile(widget.user.id, obj);
      pr.hide().whenComplete(() {
        Navigator.pop(context);
      });
    }
  }

  pickProfilePictures() async {
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
                          left: 30,
                          right: 30,
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
                                  if (croppedImage != null) {
                                    setState(() {
                                      profileImage = croppedImage;
                                    });
                                  } else {
                                    setState(() {
                                      profileImage = image;
                                    });
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
                            Text("Camera",
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
                          List<AssetEntity> imgList =
                              await openGalleryWindow(context, 1, PickType.onlyImage);

                          if (imgList != null) {
                            if (imgList.isNotEmpty) {
                              Navigator.pop(context);

                              File croppedImage =
                                  await cropImageFile(await imgList[0].file);
                              if (croppedImage != null) {
                                setState(() {
                                  profileImage = croppedImage;
                                });
                              } else {
                                imgList[0].file.then((image) {
                                  setState(() {
                                    profileImage = image;
                                  });
                                });
                              }
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
      int maxLines, bool isReadOnly, bool isLocation) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      maxLines: maxLines,
      readOnly: isReadOnly,
      onTap: !isReadOnly
          ? null
          : () async {
              if (isLocation) {
                Prediction p = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: PlacesAutocompleteApiKey,
                    mode: Mode.overlay, // Mode.fullscreen
                    language: "en",
                    radius: 10000000,
                    components: []);
                if (p != null) {
                  if (mounted) {
                    setState(() {
                      location.text = p.structuredFormatting.mainText;
                    });
                  }
                }
              } else {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(1920, 3, 5),
                    maxTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ), onChanged: (date) {
                  // print('change $date');
                }, onConfirm: (date) {
                  setState(() {
                    dobDateTime = date;
                    dob.text = date.year.toString() +
                        "-" +
                        date.month.toString() +
                        "-" +
                        date.day.toString();
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              }
            },
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

  // Widget phoneNumberField(
  //     String textHint, TextEditingController _controller, int maxLines) {
  //   return IntlPhoneField(
  //     initialCountryCode: defaultCountryCode,
  //     controller: _controller,
  //     textAlign: TextAlign.justify,
  //     decoration: InputDecoration(
  //       hintText: 'Phone Number',
  //       border: InputBorder.none,
  //       hintStyle: TextStyle(
  //         color: Colors.black,
  //       ),
  //     ),
  //     onChanged: (phone) {
  //       print(phone.completeNumber);
  //     },
  //   );
  // }

  Widget conatinerOfTextField(
      double width,
      double height,
      String hint,
      TextEditingController _controller,
      int maxLines,
      bool phone,
      bool isReadOnly,
      bool isLocation) {
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
                child: phone
                    ? phoneNumberField(hint, _controller, maxLines, isReadOnly)
                    : textField(
                        hint, _controller, maxLines, isReadOnly, isLocation),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;
    // print((width * 0.6).round());
    // print((height * 0.302).round());
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
            "Customize your profile",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
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
          child: Padding(
            padding: EdgeInsets.only(bottom: height * 0.02),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: height * 0.02,
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.01,
                        left: width * 0.1,
                        right: width * 0.1,
                      ),
                      child: Container(
                        width: (width * 0.6).round().toDouble(),
                        height: (height * 0.302).round().toDouble(),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromRGBO(129, 165, 168, 1),
                            width: 5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.6),
                            child: profileImage == null
                                ? widget.user.thumbnailUserPhotoUrl == null
                                    ? Image.asset(
                                        'assets/Icons/user.png',
                                        width: (width * 0.6).round().toDouble(),
                                        height:
                                            (height * 0.302).round().toDouble(),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.user.thumbnailUserPhotoUrl,
                                        width: (width * 0.6).round().toDouble(),
                                        height:
                                            (height * 0.302).round().toDouble(),
                                        fit: BoxFit.cover,
                                      )
                                : Image.file(profileImage,
                                    width: (width * 0.6).round().toDouble(),
                                    height: (height * 0.302).round().toDouble(),
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.64,
                        top: height * 0.05,
                      ),
                      child: FloatingActionButton(
                        heroTag: 'profile_change',
                        onPressed: () {
                          pickProfilePictures();
                        },
                        backgroundColor: Palette.appColor,
                        child: Image.asset(
                          'assets/Icons/edit.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    profileImage != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              right: width * 0.64,
                              top: height * 0.05,
                            ),
                            child: FloatingActionButton(
                              heroTag: 'profile_revert',
                              onPressed: () {
                                setState(() {
                                  profileImage = null;
                                });
                              },
                              backgroundColor: Palette.appColor,
                              child: Image.asset(
                                'assets/Icons/redo.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                conatinerOfTextField(width, height, "Your username", username,
                    1, false, false, false),
                conatinerOfTextField(
                    width,
                    height,
                    "Tell your friends who you are",
                    aboutYou,
                    5,
                    false,
                    false,
                    false),
                conatinerOfTextField(width, height, "Your contact number",
                    phoneNumber, 1, true, false, false),
                conatinerOfTextField(width, height, "Your date of birth", dob,
                    1, false, true, false),
                conatinerOfTextField(width, height, "Your location", location,
                    1, false, true, true),
              ],
            ),
          ),
        ));
  }
}
