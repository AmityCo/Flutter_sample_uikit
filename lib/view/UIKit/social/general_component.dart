import 'package:flutter/material.dart';

class AmityGeneralCompomemt {
  static void showOptionsBottomSheet(
      BuildContext context, List<Widget> listTiles) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: listTiles,
          ),
        );
      },
    );
  }
}
