import 'dart:math';

import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/call.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/resources/call_methods.dart';
import 'package:garage/messenger/screens/callScreens/videocall_screen.dart';
import 'package:garage/messenger/screens/callScreens/voicecall_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dialVideo({ChatUser from, ChatUser to, context, String callis}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeVideoCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(call: call),
          ));
    }
  }

  static dialVoice({ChatUser from, ChatUser to, context, String callis}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeVoiceCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallScreen(call: call),
          ));
    }
  }
}
