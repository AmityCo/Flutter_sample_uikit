import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CommunityViewModelState extends Equatable {
  final int currentIndex;
  
  const CommunityViewModelState({
    required this.currentIndex,
  });

  @override
  List<Object?> get props => [currentIndex];

  @override
  bool get stringify => true;

  factory CommunityViewModelState.initial() {
    return const CommunityViewModelState(
      currentIndex: 0,
    );
  }

  CommunityViewModelState copyWith({
    int? currentIndex,
  }) {
    return CommunityViewModelState(
      currentIndex: currentIndex ?? this.currentIndex,
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
    notifyListeners();
  }
}
