import 'package:flutter/material.dart';

class AmityUIConfiguration extends ChangeNotifier {
  Color primaryColor = Colors.grey;
  IconData placeHolderIcon = Icons.chat;
  Color displaynameColor = Colors.black;

  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();
  ButtonConfig buttonConfig = ButtonConfig();
  AppbarConfig appbarConfig = AppbarConfig();
  
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

class AppbarConfig{
  final Color backgroundColor;
  final Color textColor;
  final Color iconBackColor;
  AppbarConfig({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconBackColor =Colors.white,
  });
}

class ButtonConfig{
  final Color backgroundColor;
  final Color textColor;
  ButtonConfig({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });
}