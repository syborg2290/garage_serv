import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/main/main_pages/sub/edit_profile.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage/initials/home.dart';
import 'package:garage/utils/shimmers/profile_shimmers.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId, Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int posts = 0;
  int following = 0;
  int followers = 0;
  String currentUserId;
  User currentUser;

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
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: currentUserId != widget.profileId
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(60))),
                    child: IconButton(
                        icon: Image.asset(
                          'assets/Icons/edit.png',
                          width: width * 0.07,
                          height: height * 0.07,
                          color: Colors.white,
                        ),
                        onPressed: currentUser == null
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                              user: currentUser,
                                            )));
                              }),
                  ),
                ),
          actions: <Widget>[
            currentUserId != widget.profileId
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(60))),
                      child: IconButton(
                          icon: Image.asset(
                            'assets/Icons/more.png',
                            width: width * 0.07,
                            height: height * 0.07,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final act = CupertinoActionSheet(
                              actions: <Widget>[
                                CupertinoActionSheetAction(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/logout.png',
                                        width: width * 0.07,
                                        height: height * 0.07,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    await logoutUser();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home()));
                                  },
                                )
                              ],
                            );
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) => act);
                          }),
                    ),
                  )
          ],
        ),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: StreamBuilder(
            stream: streamingUser(widget.profileId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return shimmerEffectLoadingProfile(context);
              } else {
                User user = User.fromDocument(snapshot.data.documents[0]);

                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      height * 0.0001,
                      height * 0.0001,
                      height * 0.0001,
                      height * 0.0001,
                    ),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(35.0),
                              child: Image.asset(
                                'assets/designs/profile_cover.png',
                                fit: BoxFit.cover,
                                height: height * 0.3,
                                width: width,
                              ),
                            ),
                            Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: height * 0.2,
                                    left: width * 0.3,
                                    right: width * 0.1,
                                  ),
                                  child: Container(
                                    width: width * 0.38,
                                    height: height * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 10,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(70.0),
                                      child: user.thumbnailUserPhotoUrl == null
                                          ? Image.asset(
                                              'assets/Icons/user.png',
                                              width: width * 0.38,
                                              height: height * 0.2,
                                            )
                                          : Image.network(
                                              user.thumbnailUserPhotoUrl,
                                              width: width * 0.38,
                                              height: height * 0.2,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          user.username,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        user.aboutYou == null
                            ? SizedBox.shrink()
                            : Padding(
                                padding: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                child: Text(
                                  user.aboutYou,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(129, 165, 168, 1),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        user.location == null
                            ? SizedBox.shrink()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    size: 30,
                                    color: Color.fromRGBO(129, 165, 168, 1),
                                  ),
                                  Text(
                                    user.location,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(129, 165, 168, 1),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            PostFollower(
                              number: posts,
                              title: 'Posts',
                            ),
                            PostFollower(
                              number: followers,
                              title: 'Followers',
                            ),
                            PostFollower(
                              number: following,
                              title: 'Following',
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                );
              }
            }));
  }
}

class PostFollower extends StatelessWidget {
  final int number;
  final String title;

  PostFollower({@required this.number, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          number.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
