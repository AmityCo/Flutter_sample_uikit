import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/post_viewmodel.dart';

// ignore: must_be_immutable
class EditCommentScreen extends StatefulWidget {
  AmityComment? comment; // Must extract children post from parent post

  EditCommentScreen({Key? key, this.comment}) : super(key: key);
  @override
  EditCommentScreenState createState() => EditCommentScreenState();
}

class EditCommentScreenState extends State<EditCommentScreen> {
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    CommentTextData commentTextData = widget.comment!.data! as CommentTextData;
    setState(() {
      controller.text = commentTextData.text!;
    });
    log("check edit comment data ${commentTextData.text!}");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<PostVM>(builder: (context, vm, m) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text("Edit",
                style: theme.textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.w500)),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.indicatorColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (widget.comment != null) {
                      final result = await vm.editComment(
                          widget.comment!, controller.text);
                      if (result == true) {
                        if(mounted){
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: const Text("Save"))
            ],
          ),
          body: SafeArea(
            child: FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: Container(
                // height: bheight,
                color: Colors.white,
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: controller,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Write something to Post",
                  ),
                  // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
                ),
              ),
            ),
          ));
    });
  }
}
