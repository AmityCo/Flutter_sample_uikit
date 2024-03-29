import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class CategoryVM extends ChangeNotifier {
  var _categories = <AmityCommunityCategory>[];
  var _allCategories = <AmityCommunityCategory>[];
  var _selectedCategories = <String>[];
  final _categoryIds = <String>[];
  var _community = AmityCommunity();
  List<AmityCommunityCategory> getCategories() {
    return _categories;
  }
List<AmityCommunityCategory> getAllCategories() {
    return _allCategories;
  }

  AmityCommunity getCommunity() {
    return _community;
  }

  void setCommunity(AmityCommunity community) {
    _community = community;
  }

  List<String> getCategoryIds() {
    return _categoryIds;
  }

  void addCategoryId(String id) {
    _categoryIds.add(id);
    notifyListeners();
  }

  List<String> getSelectedCategory() {
    return _selectedCategories;
  }

  String getSelectedCommunityName(String id) {
    for (var category in _categories) {
      if (category.categoryId! == id) {
        return category.name!;
      }
    }
    return "";
  }

  void setSelectedCategory(String id) {
    _selectedCategories.clear();
    _selectedCategories.add(id);

    notifyListeners();
  }

  void initAllCategoryList() async {
    if (_allCategories.isNotEmpty) {
      _allCategories.clear();
      notifyListeners();
    }
    AmitySocialClient.newCommunityRepository()
        .getCategories()
        .sortBy(AmityCommunityCategorySortOption.NAME)
        .includeDeleted(false)
        .getPagingData(limit: 100)
        .then((communityCategories) {
      _allCategories = communityCategories.data;

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void initCategoryList(List<String> ids) async {
    log("initAmityTrendingCommunityList");

    if (_categories.isNotEmpty) {
      _categories.clear();
      notifyListeners();
    }

    AmitySocialClient.newCommunityRepository()
        .getCategories()
        .sortBy(AmityCommunityCategorySortOption.NAME)
        .includeDeleted(false)
        .getPagingData()
        .then((communityCategories) {
      _categories = communityCategories.data;
      for (var category in _categories) {
        _categoryIds.add(category.categoryId!);
      }
      _selectedCategories = ids;

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    // .onError((error, stackTrace) {
    //   handle error
    // });
  }

  bool checkIfSelected(String id) {
    return _selectedCategories.contains(id);
  }

  void selectCategory() async {}
}
