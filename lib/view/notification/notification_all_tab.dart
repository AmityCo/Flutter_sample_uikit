import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/notification_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';

class NotificationAllTabScreen extends StatefulWidget {
  const NotificationAllTabScreen({super.key});

  @override
  State<NotificationAllTabScreen> createState() =>
      _NotificationAllTabScreenState();
}

class _NotificationAllTabScreenState extends State<NotificationAllTabScreen> {
  @override
  void initState() {
    print("init NotificationVM");
    Provider.of<NotificationVM>(context, listen: false).initVM();
    super.initState();
  }

  String getDateTime(int epochTime) {
    var dateTime = DateTime.fromMicrosecondsSinceEpoch(epochTime * 1000);

    var result = GetTimeAgo.parse(
      dateTime,
    );

    if (result == "0 seconds ago") {
      return "just now";
    } else {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<NotificationVM>(builder: (context, vm, _) {
      return Container(
        color: Colors.grey[200],
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.updateNotification();
          },
          child: vm.notificationsObject == null
              ? Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: const [
                        Expanded(child: CircularProgressIndicator())
                      ],
                    ))
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.notificationsObject?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    var notificationItem = vm.notificationsObject?.data?[index];
                    return FadeAnimation(
                      child: Card(
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 16, right: 10),
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                        amityUser:
                                            AmityCoreClient.getCurrentUser(),
                                      )));
                            },
                            child: FadedScaleAnimation(
                                child: getAvatarImage(
                                    notificationItem!.actors![0].imageUrl)),
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: theme.textTheme.subtitle1!.copyWith(
                                letterSpacing: 0.5,
                              ),
                              children: [
                                TextSpan(
                                    text: vm.prefixStringBuilder(
                                        notificationItem.actors ?? []),
                                    style: theme.textTheme.subtitle2!
                                        .copyWith(fontSize: 12)),
                                TextSpan(
                                    text: " ${vm.verbStringBuilder(
                                      notificationItem.verb!,
                                    )} ",
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12)),
                                TextSpan(
                                    text: vm.suffixStringBuilder(
                                        notificationItem.verb!,
                                        notificationItem.targetDisplayName),
                                    style: theme.textTheme.subtitle2!.copyWith(
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            getDateTime(vm
                                .notificationsObject!.data![index].lastUpdate!),
                            style: theme.textTheme.subtitle2!.copyWith(
                              fontSize: 9,
                              color: theme.hintColor,
                            ),
                          ),
                          trailing: notificationItem.targetImageUrl == null
                              ? null
                              : Container(
                                  margin: const EdgeInsets.all(0),
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: OptimizedCacheImage(
                                        imageUrl:
                                            notificationItem.targetImageUrl ??
                                                "",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    });
  }
}
