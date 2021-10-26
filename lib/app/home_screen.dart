library home;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visual_search/app/home_controller.dart';
import 'package:visual_search/app/unsplash.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async => controller.random(),
      child: SafeArea(
        child: Obx(
          () => CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: 20),
                    _SearchField(
                      controller: controller.searchKeyword,
                      onSubmitted: (value) => controller.searchByKeyword(),
                      onPressedImage: () => _showBottomSheetPickImage(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: _SearchQuery(
                        value: controller.searchQuery.value,
                        image: controller.searchImageQuery.value,
                      ),
                    ),
                    Divider(thickness: 1, height: 50),
                    (controller.isLoading.value)
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ))
                        : (controller.unsplashData.value == null)
                            ? Text("no result")
                            : Column(
                                children: controller.unsplashData.value!
                                    .map((e) => _PostingCard(e))
                                    .toList(),
                              ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  _showBottomSheetPickImage() {
    Get.bottomSheet(
      Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "select image from",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          if (Get.isBottomSheetOpen ?? false) Get.back();
                          controller.searchByImage(source: ImageSource.camera);
                        }),
                    Text("Camera")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          if (Get.isBottomSheetOpen ?? false) Get.back();
                          controller.searchByImage(source: ImageSource.gallery);
                        }),
                    Text("Gallery")
                  ],
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      isDismissible: true,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField(
      {required this.controller,
      required this.onSubmitted,
      required this.onPressedImage,
      Key? key})
      : super(key: key);

  final TextEditingController controller;
  final Function(String value) onSubmitted;
  final Function() onPressedImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                hintText: "search post",
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(Get.context!).primaryColor),
                ),
              ),
              onSubmitted: (value) => onSubmitted(value),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.image_search),
          onPressed: () => onPressedImage(),
          tooltip: "search by image",
        ),
      ],
    );
  }
}

class _SearchQuery extends StatelessWidget {
  const _SearchQuery({this.image, this.value, Key? key}) : super(key: key);

  final File? image;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (image != null && value != null) {
      return Row(
        children: [
          _searchImage(image!),
          SizedBox(width: 10),
          _searchText("Searching for similar images '$value'"),
        ],
      );
    } else if (image != null) {
      return _searchImage(image!);
    } else if (value != null) {
      return _searchText("Searching for '$value'");
    } else {
      return Container();
    }
  }

  Widget _searchImage(File fileImage) {
    return Image.file(
      fileImage,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  Widget _searchText(String value) {
    return Text(
      value,
      style: Theme.of(Get.context!).textTheme.caption!.copyWith(
            fontStyle: FontStyle.italic,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _PostingCard extends StatelessWidget {
  const _PostingCard(this.data, {Key? key}) : super(key: key);

  final Unpslash data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 0,
        child: Column(
          children: [
            _userWidget(
                profileImage: data.user.image,
                name: data.user.name,
                postingDate: data.imagePost.createdAt),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: _imageWidget(
                  image: data.imagePost.image,
                  totalLikes: data.imagePost.totalLikes,
                  description: data.imagePost.description),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _userWidget({
    required ImageProvider profileImage,
    required String name,
    required DateTime postingDate,
  }) {
    final format = DateFormat('dd MMM yyyy');

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profileImage,
      ),
      title: Text(name),
      subtitle: Text(format.format(postingDate)),
    );
  }

  Widget _imageWidget(
      {required ImageProvider image,
      String? description,
      required int totalLikes}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(description, textAlign: TextAlign.left),
          ),
        Image(
          image: image,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null)
              return child;
            else
              return Center(child: CircularProgressIndicator());
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink),
            SizedBox(width: 10),
            Text("$totalLikes likes")
          ],
        )
      ],
    );
  }
}
