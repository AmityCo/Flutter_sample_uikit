import 'package:flutter/material.dart';

class AmityUIConfiguration extends ChangeNotifier {
  Color primaryColor = Color(0xFF1054DE);
  IconData placeHolderIcon = Icons.chat;
  Color displaynameColor = Colors.black;

  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();

  TextStyle titleTextStyle = const TextStyle(
    fontSize: 17,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  TextStyle hintTextStyle = const TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w400,
  );

  void updateUI() {
    notifyListeners();
  }
}

class ChannelListConfig {
  Color cardColor = Colors.white;
  Color backgroundColor = Colors.grey[200]!;
  Color latestMessageColor = Colors.grey[500]!;
  Color latestTimeColor = Colors.grey[500]!;
  Color channelDisplayname = Colors.black;
}

class MessageRoomConfig {
  Color backgroundColor = Colors.white;
  Color appbarColor = Colors.white;
  Color textFieldBackGroundColor = Colors.white;
  Color textFieldHintColor = Colors.grey[500]!;
}
