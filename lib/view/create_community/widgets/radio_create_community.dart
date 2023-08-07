import 'package:flutter/material.dart';

import '../../../components/custom_radio_box.dart';
import '../../../viewmodel/community_viewmodel.dart';

class RadioCreateCommunity extends StatelessWidget {
  const RadioCreateCommunity({
    super.key,
    required this.current,
    required this.onChanged,
  });
  final CommunityType current;
  final ValueChanged<CommunityType?> onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomRadioBox(
          title: 'Public',
          description: 'Anyone can join, view and search this community',
          icon: const Icon(Icons.public),
          value: CommunityType.public,
          groupValue: current,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        CustomRadioBox(
          title: 'Private',
          description:
              'Only members invited by the moderators can join, view and search this community',
          icon: const Icon(Icons.lock),
          value: CommunityType.private,
          groupValue: current,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
