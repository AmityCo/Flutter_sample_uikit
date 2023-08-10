import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view/social/create_post_screen.dart';
import '../viewmodel/amity_viewmodel.dart';
import '../viewmodel/community_viewmodel.dart';
import '../viewmodel/configuration_viewmodel.dart';
import 'custom_list_tile.dart';

class SelectPostDialog {
  bool isOpenDialog = false;
  BuildContext? contextDialog;
  BuildContext? mContext;
  Future<void> open({required BuildContext context}) async {
    if (isOpenDialog) {
      return;
    }
    mContext = context;
    return await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) {
        contextDialog = context;
        isOpenDialog = true;
        return _CustomWidget(
          close: (callback) {
            _close(callback);
          },
        );
      },
    );
  }

  void close() {
    _close(_SelectPostModel.initial());
  }

  Future<void> _close(_SelectPostModel callback) async {
    if (isOpenDialog && contextDialog != null) {
      isOpenDialog = false;

      switch (callback.type) {
        case _SelectPostType.my:
          Navigator.pushReplacement(
              contextDialog!,
              MaterialPageRoute(
                builder: (_) => const CreatePostScreen2(),
              ));
          break;
        case _SelectPostType.community:
          Navigator.of(contextDialog!).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen2(
                communityID: callback.community?.communityId,
              ),
            ),
          );
          break;
        case _SelectPostType.none:
          Navigator.pop(contextDialog!);
          break;
      }
    }
  }
}

class _CustomWidget extends StatefulWidget {
  const _CustomWidget({
    required this.close,
  });

  final Function(_SelectPostModel) close;

  @override
  State<_CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<_CustomWidget> {
  @override
  void initState() {
    setup();
    super.initState();
  }

  Future<void> setup() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      context.read<CommunityVM>().initAmityMyCommunityList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            context.watch<AmityUIConfiguration>().appbarConfig.backgroundColor,
        title: Text(
          'Post to',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context
                    .watch<AmityUIConfiguration>()
                    .appbarConfig
                    .textColor,
              ),
        ),
        leading: IconButton(
          onPressed: () {
            widget.close(_SelectPostModel.initial());
          },
          icon: Icon(
            Icons.close,
            color: context
                .watch<AmityUIConfiguration>()
                .appbarConfig
                .iconBackColor,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<AmityVM>(builder: (_, vm, __) {
              return CustomListTitle(
                title: 'My Timeline',
                url: vm.currentamityUser?.avatarUrl,
                iconNoImage: Icon(
                  Icons.person,
                  color: context
                      .watch<AmityUIConfiguration>()
                      .buttonConfig
                      .textColor,
                ),
                onPressed: () {
                  widget.close(
                    const _SelectPostModel(type: _SelectPostType.my),
                  );
                },
              );
            }),
            const Divider(),
            Row(
              children: [
                Text(
                  'My Community',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Consumer<CommunityVM>(builder: (_, vm, __) {
                final data = vm.getAmityMyCommunities();
                return ListView(
                  children: List.generate(
                    data.length,
                    (index) {
                      final community = data[index];
                      return CustomListTitle(
                        title: community.displayName ?? "Community",
                        url: community.avatarImage?.fileUrl,
                        onPressed: () {
                          widget.close(
                            _SelectPostModel(
                              type: _SelectPostType.community,
                              community: community,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}


enum _SelectPostType {
  my,
  community,
  none,
}

class _SelectPostModel extends Equatable {
  final _SelectPostType type;
  final AmityCommunity? community;

  const _SelectPostModel({
    required this.type,
    this.community,
  });

  factory _SelectPostModel.initial() {
    return const _SelectPostModel(type: _SelectPostType.none);
  }

  @override
  List<Object?> get props => [type, community];

  @override
  bool get stringify => true;

  _SelectPostModel copyWith({
    _SelectPostType? type,
    AmityCommunity? community,
  }) {
    return _SelectPostModel(
      type: type ?? this.type,
      community: community ?? this.community,
    );
  }
}
