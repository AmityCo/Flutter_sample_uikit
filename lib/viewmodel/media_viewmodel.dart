import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerVM with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];

  List<XFile> get selectedFiles => _selectedFiles;

  Future<void> pickMultipleImages() async {
    try {
      List<XFile>? pickedImages = await _picker.pickMultiImage();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        _selectedFiles.addAll(pickedImages);
        notifyListeners();
      }
    } catch (e) {
      print("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickMultipleVideos() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        _selectedFiles.add(video);
        notifyListeners();
      }
    } catch (e) {
      print("Error picking video: $e");
      // Handle the error as appropriate for your app
    }
  }

  void clearFiles() {
    _selectedFiles.clear();
  }

  bool get hasSelectedFiles => _selectedFiles.isNotEmpty;

  Future<void> pickFile() async {
    // Implement your file picker logic here
  }
}
