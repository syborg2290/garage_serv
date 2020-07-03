import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/config/settings.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/models/user.dart';
import 'package:garage/modified_lib/giphy_picker-1.0.4/lib/giphy_picker.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class GarageComments extends StatefulWidget {
  final Garage garage;
  final String docId;
  GarageComments({this.garage, this.docId, Key key}) : super(key: key);

  @override
  _GarageCommentsState createState() => _GarageCommentsState();
}

class _GarageCommentsState extends State<GarageComments> {
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 50.0);
  TextEditingController _textController = TextEditingController();
  String currentUserId;
  User currentUser;
  User useObj;
  String mediaUrl;
  String mediaType;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    User user = User.fromDocument(await getUserObj(pref.getString('userid')));
    setState(() {
      currentUser = user;
      currentUserId = pref.getString('userid');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    if (_scrollController.hasClients) {
      Timer(
        Duration(seconds: 1),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent),
      );
    }

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
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream: streamingSingleGarage(widget.garage.id),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    } else {
                      if (snapshot.data.documents.length == 0) {
                        return Center(
                            child: EmptyListWidget(
                                title: 'No Comments',
                                subTitle: 'No Comments available yet',
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
                        List comments = [];
                        snapshot.data.documents.forEach((doc) {
                          Garage ga = Garage.fromDocument(doc);
                          if (ga.comments != null) {
                            comments = json.decode(ga.comments);
                          }
                        });

                        if (comments.isEmpty) {
                          return Center(
                              child: EmptyListWidget(
                                  title: 'No Comments',
                                  subTitle: 'No Comments available yet',
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
                          return ListView.builder(
                              controller: _scrollController,
                              itemCount: comments.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                getUserObj(comments[index]["userId"])
                                    .then((user) {
                                  useObj = User.fromDocument(user);
                                });

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    ListTile(
                                      title: GestureDetector(
                                          child: Text(
                                              useObj == null
                                                  ? ""
                                                  : useObj.username,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                      leading: GestureDetector(
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          padding: const EdgeInsets.all(
                                              2.0), // borde width
                                          decoration: new BoxDecoration(
                                            color: Palette
                                                .appColor, // border color
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: useObj == null
                                                ? AssetImage(
                                                    'assets/Icons/user.png')
                                                : useObj.thumbnailUserPhotoUrl ==
                                                        null
                                                    ? AssetImage(
                                                        'assets/Icons/user.png')
                                                    : CachedNetworkImageProvider(
                                                        useObj
                                                            .thumbnailUserPhotoUrl),
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Palette.appColor,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(timeago.format(
                                          DateTime.parse(
                                              comments[index]["timestamp"]))),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: width * 0.1,
                                        left: width * 0.2,
                                      ),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                            color: Color(0xffe0e0e0)
                                                .withOpacity(0.5),
                                            borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(20.0),
                                              topRight:
                                                  const Radius.circular(20.0),
                                              bottomLeft:
                                                  const Radius.circular(20.0),
                                              bottomRight:
                                                  const Radius.circular(20.0),
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: comments[index]["type"] ==
                                                  "media"
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0)),
                                                  child: CachedNetworkImage(
                                                    color: Color(0xffe0e0e0),
                                                    imageUrl: comments[index]
                                                        ["comment"],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      height: height * 0.3,
                                                      width: width * 0.5,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.fill),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            circularProgress(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    useOldImageOnUrlChange:
                                                        true,
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: ExpandText(
                                                      comments[index]
                                                          ["comment"],
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 18,
                                                      )),
                                                ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              });
                        }
                      }
                    }
                  }),
            ),
            Divider(),
            Center(
              child: Container(
                width: width * 0.96,
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
                  padding: const EdgeInsets.only(
                    left: 5,
                    bottom: 5,
                    top: 5,
                    right: 5,
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    maxLines: null,
                    autofocus: true,
                    controller: _textController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () async {
                          String commentText = _textController.text.trim();
                          _textController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          await commentsToGarage(widget.docId, widget.garage.id,
                              currentUserId, commentText, "text");

                          if (currentUserId == widget.garage.addedId) {
                            commentAddToAcivityFeed(
                                currentUserId,
                                widget.garage.addedId,
                                currentUser.username,
                                currentUser.thumbnailUserPhotoUrl,
                                widget.docId);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: new BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0),
                                bottomLeft: const Radius.circular(40.0),
                                bottomRight: const Radius.circular(40.0),
                              )),
                          child: Image(
                            image: AssetImage(
                              'assets/Icons/plane.png',
                            ),
                            color: Palette.appColor,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                          top: 4.0,
                          bottom: 4.0,
                          left: 4.0,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final gif = await GiphyPicker.pickGif(
                              searchText: 'Type here for pick a gif',
                              context: context,
                              apiKey: GiphyApi_key,
                              showPreviewPage: false,
                              onError: (error) {
                                print(error);
                              },
                            );
                            if (gif != null) {
                              _textController.clear();
                              setState(() {
                                _textController.text = null;
                                mediaUrl = gif.images.original.url;
                                mediaType = "gif";
                              });
                              await commentsToGarage(
                                  widget.docId,
                                  widget.garage.id,
                                  currentUserId,
                                  mediaUrl,
                                  "media");
                              if (currentUserId != widget.garage.addedId) {
                                commentAddToAcivityFeed(
                                    currentUserId,
                                    widget.garage.addedId,
                                    currentUser.username,
                                    currentUser.thumbnailUserPhotoUrl,
                                    widget.docId);
                              }
                            }
                            ;
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                              5,
                            ),
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(40.0),
                                  topRight: const Radius.circular(40.0),
                                  bottomLeft: const Radius.circular(40.0),
                                  bottomRight: const Radius.circular(40.0),
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: Image(
                                image: AssetImage(
                                  'assets/Icons/gif.png',
                                ),
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      hintText: "Type on your mind",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(129, 165, 168, 1),
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
