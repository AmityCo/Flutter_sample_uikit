import 'package:flutter/material.dart';

class AmityUIConfiguration extends ChangeNotifier {
  Color primaryColor = Colors.grey;
  Color secondaryColor = Colors.black;
  IconData placeHolderIcon = Icons.chat;
  Color displaynameColor = Colors.black;
  TextStyle? textStyle;

  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();
  ButtonConfig buttonConfig = ButtonConfig();
  DeleteButtonConfig deleteButtonConfig = DeleteButtonConfig();
  AcceptButtonConfig acceptButtonConfig = AcceptButtonConfig();
  CancelButtonConfig cancelButtonConfig = CancelButtonConfig();
  AppbarConfig appbarConfig = AppbarConfig();
  UserProfileConfig userProfileConfig = UserProfileConfig();
  ExploreConfig exploreConfig = ExploreConfig();
  SearchCommunitiesFilter searchCommunitiesFilter = SearchCommunitiesFilter.all;

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

class AppbarConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color iconBackColor;
  final bool isOpenAddCommunity;
  AppbarConfig({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconBackColor = Colors.white,
    this.isOpenAddCommunity = true,
  });
}

class ButtonConfig {
  final Color backgroundColor;
  final Color textColor;
  ButtonConfig({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class AcceptButtonConfig extends ButtonConfig {
  AcceptButtonConfig({
    super.backgroundColor = Colors.blue,
    super.textColor = Colors.white,
  });
}

class DeleteButtonConfig extends ButtonConfig {
  DeleteButtonConfig({
    super.backgroundColor = Colors.red,
    super.textColor = Colors.white,
  });
}

class CancelButtonConfig extends ButtonConfig {
  CancelButtonConfig({
    super.backgroundColor = Colors.grey,
    super.textColor = Colors.white,
  });
}

class UserProfileConfig {
  final bool isOpenTabView;
  final bool isOpenEditProfile;

  UserProfileConfig({
    this.isOpenTabView = true,
    this.isOpenEditProfile = true,
  });
}

class ExploreConfig {
  final bool isOpenRecommended;
  final bool isOpenTrending;
  final bool isOpenCategories;
  final bool isShowCategoryOnRecommended;
  final bool isShowCategoryOnTrending;

  ExploreConfig({
    this.isOpenRecommended = true,
    this.isOpenTrending = true,
    this.isOpenCategories = true,
    this.isShowCategoryOnRecommended = true,
    this.isShowCategoryOnTrending = true,
  });
}

enum SearchCommunitiesFilter{
  private,
  public,
  all,
}