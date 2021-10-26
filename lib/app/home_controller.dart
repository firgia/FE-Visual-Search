import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:visual_search/app/unsplash.dart';
import 'package:visual_search/app/unsplash_service.dart';

class HomeController extends GetxController {
  final _unsplashService = UnsplashService();
  final searchKeyword = TextEditingController();
  final isLoading = false.obs;
  final Rx<String?> searchQuery = Rx(null);
  final Rx<File?> searchImageQuery = Rx(null);
  final unsplashData = Rx<List<Unpslash>?>(null);

  @override
  void onInit() {
    random();
    _loadModel();
    super.onInit();
  }

  void searchByImage({ImageSource source = ImageSource.camera}) async {
    var image = await ImagePicker().pickImage(source: source);

    if (image != null) {
      final _image = await ImageCropper.cropImage(
        sourcePath: image.path,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'adjust image',
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        maxHeight: 224,
        maxWidth: 224,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (_image != null) {
        // update the current search image query information
        searchImageQuery.value = File(_image.path);

        // get label from picked image
        _getImageClassificationLabel(searchImageQuery.value!).then((value) {
          // search by label when image is fine :D
          if (value != null) _search(value);
        });
      } else {
        searchImageQuery.value = null;
      }
    } else {
      searchImageQuery.value = null;
    }
  }

  void searchByKeyword() {
    // remove previous search query by image
    searchImageQuery.value = null;

    _search(searchKeyword.text);

    // reset keyword field value when request processed
    searchKeyword.text = "";
  }

  /// get data from `Unsplash` by search
  void _search(String value) async {
    // update the current search query information
    searchQuery.value = value;

    isLoading.value = true;
    unsplashData.value = await _unsplashService.search(value, perPage: 20);
    isLoading.value = false;
  }

  /// get random data from `Unsplash`
  void random() async {
    // remove all previous search queries
    searchQuery.value = null;
    searchImageQuery.value = null;

    isLoading.value = true;
    unsplashData.value = await _unsplashService.random();
    isLoading.value = false;
  }

  /// load custom model
  void _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_classification.tflite",
      labels: "assets/label.txt",
    );
  }

  /// get label from image, using image classification tensorflow lite
  Future<String?> _getImageClassificationLabel(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      imageMean: 0,
      imageStd: 255,
    );

    print(res);
    return res?[0]['label'];
  }

  @override
  void onClose() {
    Tflite.close();
    super.onClose();
  }
}
