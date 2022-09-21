import '../model/amity_message_model.dart';

class AmityNotificationRepo {
  void initRepo(String accessToken) {}

  Future<void> fetchNotification(
      Function(String? data, String? error) callback) async {}

  Future<void> markLastRead(
      Function(String? data, String? errpr) callback) async {}

  Future<void> readNotification(
      {String? targetId,
      String? targetGroup,
      required Function(String? data, String? errpr) callback}) async {}
}
