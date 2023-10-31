import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerVM with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];

  List<File> get selectedFiles => _selectedFiles;

  Future<void> pickMultipleImages() async {
    try {
      List<XFile>? pickedImages = await _picker.pickMultiImage();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        for (var image in pickedImages) {
          _selectedFiles.add(File(image.path));
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        _selectedFiles.add(File(video.path));
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
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          _selectedFiles.add(File(file.path!));
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking files: $e");
      // Handle the error as appropriate for your app
    }
  }
}
