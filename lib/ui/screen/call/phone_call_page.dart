// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, duplicate_ignore, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, unused_field

import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/configs/agora_configs.dart';
import 'package:skype_c/data/firebase/call_methods.dart';
import 'package:skype_c/data/models/call_response.dart';
import 'package:skype_c/provider/user_provider.dart';

class PhoneCallScreen extends StatefulWidget {
  final Call call;
  final ClientRole role = ClientRole.Broadcaster;

  
  PhoneCallScreen({required this.call});
  @override
  _PhoneCallScreenState createState() => _PhoneCallScreenState();
}

class _PhoneCallScreenState extends State<PhoneCallScreen> {
  bool _joined = false;
  late int _remoteUid ;
  final bool _switch = false;
  bool muted = false;
  late RtcEngine _engine;
  CallMethods callMethods = CallMethods();

  late UserProvider userProvider;
  late StreamSubscription callStreamSubscription;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    itializeAgora();
  }

  // Initialize the app
  Future<void> itializeAgora() async {
    // Create RTC client instance
    _engine = await RtcEngine.create(APP_ID);
    // Define event handler
    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    // ignore: duplicate_ignore
    }, userJoined: (int uid, int elapsed) {
      // ignore: avoid_print
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      // ignore: avoid_print
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Join channel 123
    await _engine.joinChannel(null, widget.call.channelId!, null, 0);
  }

  @override
  void dispose() {
    super.dispose();
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        switch (ds.data) {
          case :
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;
          default:
            break;
        }

        if (ds.data() == null) {
          Navigator.pop(context);
        }
      });
    });
  }

  // Create a simple chat UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Audio quickstart',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.call.receiverName!,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 25),
            _toolbar()
          ],
        )),
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => callMethods.endCall(call: widget.call),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ),
    );
  }
}