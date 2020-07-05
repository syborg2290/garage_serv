import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/call.dart';
import 'package:garage/messenger/resources/call_methods.dart';
import 'package:garage/messenger/screens/callScreens/videocall_screen.dart';
import 'package:garage/messenger/screens/callScreens/voicecall_screen.dart';
import 'package:garage/messenger/screens/chatScreens/widgets/cached_image.dart';
import 'package:garage/messenger/utills/permissions.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 15),
            Text(
              call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.call_end,
                    size: 32,
                  ),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 64),
                IconButton(
                  icon: Icon(
                    Icons.call,
                    size: 32,
                  ),
                  color: Colors.green,
                  // onPressed: () async =>
                  //     await Permissions.cameraandmicrophonePermissionsGranted()
                  //         ? call.isCall == "video"
                  //             ? Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       VideoCallScreen(call: call),
                  //                 ),
                  //               )
                  //             : Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       VoiceCallScreen(call: call),
                  //                 ),
                  //               )
                  //         : {},
                  onPressed: () async => call.isCall == "video"
                      ? await Permissions
                              .cameraandmicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoCallScreen(call: call),
                              ),
                            )
                          : {}
                      : await Permissions.microphonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VoiceCallScreen(call: call),
                              ),
                            )
                          : {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
