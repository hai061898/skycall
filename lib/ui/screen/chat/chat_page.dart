// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/enum/view_state.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/data/firebase/chat_methods.dart';
import 'package:skype_c/data/firebase/storage_methods.dart';
import 'package:skype_c/data/models/message_response.dart';
import 'package:skype_c/provider/image_upload_provider.dart';
import 'package:skype_c/ui/helpers/call_utilities.dart';
import 'package:skype_c/ui/helpers/permissions.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';
import 'package:skype_c/ui/widgets/appbar_c.dart';
import 'package:skype_c/ui/widgets/tile_c.dart';
import 'package:skype_c/utils/string_c.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;
import 'package:http/http.dart' as http;
import 'package:skype_c/utils/utils.dart';

import 'components/cached_image.dart';

String? key = dotenv.env['SERVER_KEY'];

class ChatScreen extends StatefulWidget {
  final model.User? receiver;

  const ChatScreen({Key? key, this.receiver}):super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final StorageMethods _storageMethods = StorageMethods();

  final ScrollController _listScrollController = ScrollController();

  late ImageUploadProvider _imageUploadProvider;

  late model.User sender;
  late String _currentUserId;

  FocusNode textFiledFocus = FocusNode();

  bool isWriting = false;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = model.User(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
        );
      });
    });
  }

  showKeyboard() => textFiledFocus.requestFocus();
  hideKeyboard() => textFiledFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: [
          Flexible(
            child: messageList(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: 15),
                  child: const CircularProgressIndicator(),
                )
              : Container(),
          chatController(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blackColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, catogory) {
        if (mounted) {
          setState(() {
            isWriting = true;
          });
        }
        textEditingController.text = textEditingController.text + emoji.emoji;
      },
      recommendKeywords: const ['face', 'happy', 'party', 'sad'],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGE_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver!.uid!)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        //SchedulerBinding.instance.addPostFrameCallback((_) {
        //  _listScrollController.animateTo(
        //    _listScrollController.position.minScrollExtent,
        //    duration: Duration(milliseconds: 250),
        //    curve: Curves.easeInOut,
        //  );
        //});

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snapshot.data!.docs.length,
          reverse: true,
          controller: _listScrollController,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data()as Map<String,dynamic>);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    if (message.type != MESSAGE_TYPE_IMAGE) {
      return Text(
            message.message!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          );
    } else {
      return CachedImage(
            message.photoUrl!,
            height: 250,
            width: 250,
            radius: 10,
          );
    }
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget chatController() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: UniversalVariables.blackColor,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    TextButton(
                      child: const Icon(Icons.close),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:  Text(
                          'Content and tools',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                  child: ListView(
                children: [
                  ModalTile(
                    title: 'Media',
                    subtitle: 'Share Photos and Video',
                    icon: Icons.image,
                    onTap: () => pickImage(source: ImageSource.gallery),
                  ),
                    ModalTile(
                    title: "File",
                    subtitle: "Share files",
                    icon: Icons.tab,
                  ),
                  ModalTile(
                    title: "Contact",
                    subtitle: "Share contacts",
                    icon: Icons.contacts,
                  ),
                   ModalTile(
                    title: "Location",
                    subtitle: "Share a location",
                    icon: Icons.add_location,
                  ),
                   ModalTile(
                    title: "Schedule Call",
                    subtitle: "Arrange a skype call and get reminders",
                    icon: Icons.schedule,
                  ),
                   ModalTile(
                    title: "Create Poll",
                    subtitle: "Share polls",
                    icon: Icons.poll,
                  )
                ],
              ))
            ],
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textEditingController,
                  focusNode: textFiledFocus,
                  onTap: () => hideEmojiContainer(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.isNotEmpty && val.trim() != '')
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      // keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: const Icon(Icons.face),
                )
              ],
            ),
          ),
          isWriting
              ? Container()
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(source: ImageSource.camera),
                  child: const Icon(Icons.camera_alt),
                ),
          isWriting
              ? Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => sendMessage(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  sendMessage() {
    var text = textEditingController.text;

    Message _message = Message(
      receiverId: widget.receiver!.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      isWriting = false;
    });

    textEditingController.text = '';

    _chatMethods.addMessageToDb(_message, sender, widget.receiver);

    try {
      http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$key',
        },
        body: jsonEncode({
          'to': widget.receiver!.fcmToken,
          'priority': 'high',
          'notification': {
            'title': 'skype',
            'body': _message.message,
          },
          'data': {'user_uid': sender.uid}
        }),
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  pickImage({required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
      image: selectedImage,
      receiverId: widget.receiver!.uid!,
      senderId: _currentUserId,
      imageUploadProvider: _imageUploadProvider,
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver!.name!,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.video_call,
          ),
          onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: widget.receiver!,
                      context: context,
                      type: CALL_TYPE_VIDEO)
                  : {},
        ),
        IconButton(
          icon: const Icon(
            Icons.phone,
          ),
          onPressed: () async => await Permissions.microphonePermissonsGranted()
              ? CallUtils.dial(
                  from: sender,
                  to: widget.receiver!,
                  context: context,
                  type: CALL_TYPE_VOICE)
              : {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const ModalTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}