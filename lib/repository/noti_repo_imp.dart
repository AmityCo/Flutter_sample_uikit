import 'package:dio/dio.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

import '../utils/env_manager.dart';
import 'noti_repo.dart';

class AmityNotificationRepoImp implements AmityNotificationRepo {
  String? accessToken;

  @override
  void initRepo(String accessToken) {
    this.accessToken = accessToken;
  }

  @override
  Future<void> fetchNotification(
      Function(String? data, String? error) callback) async {
    var dio = Dio();
    final response = await dio.post(
      "https://beta.amity.services/notifications/history",
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken" // set content-length
        },
      ),
    );
    if (response.statusCode == 200) {
      callback(response.data, null);
    } else {
      callback(
        null,
        response.data,
      );
    }
  }

  @override
  Future<void> markLastRead(Function(String? data, String? errpr) callback) {
    // TODO: implement markLastRead
    throw UnimplementedError();
  }

  @override
  Future<void> readNotification(
      {String? targetId,
      String? targetGroup,
      required Function(String? data, String? errpr) callback}) {
    // TODO: implement readNotification
    throw UnimplementedError();
  }
}
