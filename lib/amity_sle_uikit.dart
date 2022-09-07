// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'chat_viewmodel/amity_viewmodel.dart';
import 'chat_viewmodel/channel_list_viewmodel.dart';
import 'chat_viewmodel/channel_viewmodel.dart';
import 'chat_viewmodel/configuration_viewmodel.dart';
import 'chat_viewmodel/custom_image_picker.dart';
import 'chat_viewmodel/user_viewmodel.dart';
import 'model/amity_channel_model.dart';
import 'utils/env_manager.dart';

class AmitySLEUIKit {
  Future<void> initUIKit(String apikey, String region) async {
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

  Future<void> registerDevice(BuildContext context, String userId) async {
    await Provider.of<AmityVM>(context, listen: false)
        .login(userId)
        .then((value) {
      Provider.of<UserVM>(context, listen: false).initAccessToken();
    });
  }

  void configAmityThemeColor(
      BuildContext context, Function(AmityUIConfiguration config) config) {
    var provider = Provider.of<AmityUIConfiguration>(context, listen: false);
    config(provider);
  }

  static Future<void> openChatRoomPage(
      BuildContext context, String channelId) async {
    await Future.delayed(Duration.zero, () async {
      String token = "";
      if (Provider.of<UserVM>(context, listen: false).accessToken == "") {
        token =
            await Provider.of<UserVM>(context, listen: false).initAccessToken();
      } else {
        token = Provider.of<UserVM>(context, listen: false).accessToken;
      }
      // ignore: use_build_context_synchronously
      Provider.of<ChannelVM>(context, listen: false).initVM();
    });

    await Provider.of<ChannelVM>(context, listen: false)
        .openChatRoomPageByID(context, channelId);
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
        ChangeNotifierProvider<ImagePickerVM>(
            create: ((context) => ImagePickerVM())),
        ChangeNotifierProvider<ChannelVM>(create: ((context) => ChannelVM())),
        ChangeNotifierProvider<AmityUIConfiguration>(
            create: ((context) => AmityUIConfiguration())),
      ],
      child: Builder(
        builder: (context) => child,
      ),
    );
  }
}
