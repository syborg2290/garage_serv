import 'package:cached_network_image/cached_network_image.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/models/activityFeed.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/activityFeed.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  final User currentUser;
  ActivityFeed({this.currentUser, Key key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
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
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: StreamBuilder(
          stream: streamingActivityFeed(widget.currentUser.id),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: EmptyListWidget(
                      title: 'No Notification',
                      subTitle: 'No  notification available yet',
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
                          .copyWith(color: Color(0xffabb8d6))),
                );
              } else {
                List<ActivityFeedNotify> feedItems = [];

                snapshot.data.documents.forEach((doc) {
                  feedItems.add(ActivityFeedNotify.fromDocument(doc));
                });
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: feedItems.length,
                    itemBuilder: (context, index) {
                      return NotificationFeed(
                        feed: feedItems[index],
                        height: height,
                        width: width,
                      );
                    });
              }
            }
          },
        ),
      ),
    );
  }
}

class NotificationFeed extends StatelessWidget {
  final ActivityFeedNotify feed;
  final double width;
  final double height;
  const NotificationFeed({this.feed, this.width, this.height, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String activityItemText = "";

    if (feed.type == "rateGarage") {
      activityItemText = "rate on your garage";
    }

    if (feed.type == "follow") {
      activityItemText = "started following you";
    }

    if (feed.type == "likeGarage") {
      activityItemText = "liked your garage";
    }

    if (feed.type == "commentGarage") {
      activityItemText = "commented on your garage";
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0, top: 10),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: feed.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                  text: ' $activityItemText',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black.withOpacity(0.8),
          backgroundImage: feed.userImage == null
              ? AssetImage('assets/Icons/user.png')
              : CachedNetworkImageProvider(
                  feed.userImage,
                ),
        ),
        subtitle: Text(
          timeago.format(feed.timestamp.toDate()),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () async {
              // await deleteActivityFeed(
              //   userId,
              //   documentId,
              // );
              // Fluttertoast.showToast(
              //     msg: "Feed item removed",
              //     toastLength: Toast.LENGTH_SHORT,
              //     gravity: ToastGravity.CENTER,
              //     backgroundColor: Palette.appColor,
              //     textColor: Colors.white,
              //     fontSize: 16.0);
            },
            child: Image.asset(
              'assets/Icons/close.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }
}
