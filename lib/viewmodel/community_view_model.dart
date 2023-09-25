import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../view/community/community_view.dart';

class CommunityViewModelState extends Equatable {
  final int currentIndex;
  final BottomAppBarController controller;
  const CommunityViewModelState({
    required this.currentIndex,
    required this.controller,
  });

  @override
  List<Object?> get props => [currentIndex];

  @override
  bool get stringify => true;

  factory CommunityViewModelState.initial() {
    return CommunityViewModelState(
      currentIndex: 0,
      controller: BottomAppBarController(),
    );
  }

  CommunityViewModelState copyWith({
    int? currentIndex,
    BottomAppBarController? controller,
  }) {
    return CommunityViewModelState(
      currentIndex: currentIndex ?? this.currentIndex,
      controller: controller ?? this.controller,
    );
  }
}

class CommunityViewModel with ChangeNotifier {
  CommunityViewModelState _state = CommunityViewModelState.initial();
  CommunityViewModelState get state => _state;

  final items = const <String>['Newsfeed', 'Explore'];

  void selectTab(int index) {
    _state = _state.copyWith(
      currentIndex: index,
    );
    state.controller.selectIndex = index;
    notifyListeners();
  }
}
