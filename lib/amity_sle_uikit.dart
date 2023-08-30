// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/constans/app_text_style.dart';
import 'package:amity_uikit_beta_service/viewmodel/category_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_view_model.dart';
import 'package:amity_uikit_beta_service/viewmodel/notification_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/pending_request_viewmodel.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'viewmodel/amity_viewmodel.dart';
import 'viewmodel/channel_list_viewmodel.dart';
import 'viewmodel/community_viewmodel.dart';
import 'viewmodel/configuration_viewmodel.dart';
import 'viewmodel/create_post_viewmodel.dart';
import 'viewmodel/custom_image_picker.dart';
import 'viewmodel/feed_viewmodel.dart';
import 'viewmodel/post_viewmodel.dart';
import 'viewmodel/user_feed_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'utils/env_manager.dart';

class AmitySLEUIKit {
  static Future<void> initUIKit(String apikey, String region) async {
    env = ENV(apikey, region);
    AmityRegionalHttpEndpoint? amityEndpoint;
    if (region.isNotEmpty) {
      switch (region) {
        case "":
          {
            log("REGION is not specify Please check .env file");
          }

          break;
        case "sg":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.SG;
          }

          break;
        case "us":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.US;
          }

          break;
        case "eu":
          {
            amityEndpoint = AmityRegionalHttpEndpoint.EU;
          }
      }
    } else {
      throw "REGION is not specify Please check .env file";
    }

    await AmityCoreClient.setup(
        option:
            AmityCoreClientOption(apiKey: apikey, httpEndpoint: amityEndpoint!),
        sycInitialization: true);
  }

  static Future<void> registerDevice(
      {required BuildContext context,
      required String userId,
      String? displayName,
      String? authToken,
      Function(bool isSuccess, String? error)? callback}) async {
    await Provider.of<AmityVM>(context, listen: false)
        .login(userID: userId, displayName: displayName, authToken: authToken)
        .then((value) async {
      await Provider.of<UserVM>(context, listen: false)
          .initAccessToken()
          .then((value) {
        if (Provider.of<UserVM>(context, listen: false).accessToken != null ||
            Provider.of<UserVM>(context, listen: false).accessToken != "") {
          if (callback != null) {
            callback(true, null);
          }
        } else {
          if (callback != null) {
            callback(false, "❌ Initialize accesstoken fail...");
          }
        }
      });
    }).onError((error, stackTrace) {
      log("registerDevice...Error:$error");
    });
  }

  static Future<void> registerNotification(
      String fcmToken, Function(bool isSuccess, String? error) callback) async {
    // example of getting token from firebase
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    // final fcmToken = await messaging.getToken();
    // await AmityCoreClient.unregisterDeviceNotification();
    // log("unregisterDeviceNotification");\
    await Future.delayed(Duration.zero);
    await AmityCoreClient.registerDeviceNotification(fcmToken).then((value) {
      debugPrint("registerNotification succesfully ✅");
      callback(true, null);
    }).onError((error, stackTrace) {
      callback(false, "Initialize push notification fail...❌");
    });
  }

  static void configAmityThemeColor(
      BuildContext context, Function(AmityUIConfiguration config) config) {
    var provider = Provider.of<AmityUIConfiguration>(context, listen: false);
    config(provider);
    AppTextStyle.mainStyle = provider.textStyle ?? const TextStyle();
  }

  static AmityUser getCurrentUser() {
    return AmityCoreClient.getCurrentUser();
  }

  static void unRegisterDevice() {
    AmityCoreClient.unregisterDeviceNotification();
    AmityCoreClient.logout();
  }

  static Future<void> joinInitialCommunity(List<String> communityIds) async {
    for (var i = 0; i < communityIds.length; i++) {
      AmitySocialClient.newCommunityRepository()
          .joinCommunity(communityIds[i])
          .then((value) {
        log("join community:${communityIds[i]} success");
      }).onError((error, stackTrace) {
        log('ERROR AmitySLEUIKit joinInitialCommunity:$error');
      });
    }
  }

  static Future<void> updateProfile(
    BuildContext context, {
    String? displayName,
    String? description,
    String? url,
  }) async {
    await context.read<AmityVM>().updateProfile(
          displayName: displayName,
          description: description,
          url: url,
        );
  }

  static Future<void> joinCommunity(String communityId) async {
    final community = await AmitySocialClient.newCommunityRepository()
        .getCommunity(communityId);
    final isJoined = community.isJoined ?? false;
    
    log('joinCommunity community:$community');
    if(!isJoined){
      await AmitySocialClient.newCommunityRepository()
                        .joinCommunity(communityId).then((value) {
        log("join community:$communityId success");
      }).onError((error, stackTrace) {
        log('ERROR AmitySLEUIKit joinInitialCommunity:$error');
      });
    }
  }
}

class AmitySLEProvider extends StatelessWidget {
  final Widget child;
  const AmitySLEProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVM>(create: ((context) => UserVM())),
        ChangeNotifierProvider<AmityVM>(create: ((context) => AmityVM())),
        ChangeNotifierProvider<FeedVM>(create: ((context) => FeedVM())),
        ChangeNotifierProvider<CategoryVM>(create: ((context) => CategoryVM())),
        ChangeNotifierProvider<CommunityVM>(
            create: ((context) => CommunityVM())),
        ChangeNotifierProvider<PostVM>(create: ((context) => PostVM())),
        ChangeNotifierProvider<UserFeedVM>(create: ((context) => UserFeedVM())),
        ChangeNotifierProvider<ImagePickerVM>(
            create: ((context) => ImagePickerVM())),
        ChangeNotifierProvider<CreatePostVM>(
            create: ((context) => CreatePostVM())),
        ChangeNotifierProvider<ChannelVM>(create: ((context) => ChannelVM())),
        ChangeNotifierProvider<AmityUIConfiguration>(
            create: ((context) => AmityUIConfiguration())),
        ChangeNotifierProvider<NotificationVM>(
            create: ((context) => NotificationVM())),
        ChangeNotifierProvider<PendingVM>(create: ((context) => PendingVM())),
        ChangeNotifierProvider<CommunityViewModel>(
            create: ((context) => CommunityViewModel())),
      ],
      child: Builder(
        builder: (context) => child,
      ),
    );
  }
}
