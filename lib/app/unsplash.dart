import 'package:flutter/material.dart';

class Unpslash {
  final UnsplashImagePost imagePost;
  final UnsplashUser user;

  Unpslash({required this.imagePost, required this.user});

  factory Unpslash.create(Map<String, dynamic> object) {
    return Unpslash(
      imagePost: UnsplashImagePost(
        image: NetworkImage(object['urls']['small']),
        description: object['description'],
        totalLikes: object['likes'],
        createdAt: DateTime.parse(object['created_at']),
      ),
      user: UnsplashUser(
        image: NetworkImage(object['user']['profile_image']['large']),
        name: object['user']['name'],
      ),
    );
  }
}

class UnsplashUser {
  final ImageProvider image;
  final String name;

  UnsplashUser({
    required this.image,
    required this.name,
  });
}

class UnsplashImagePost {
  final ImageProvider image;
  final String? description;
  final int totalLikes;
  final DateTime createdAt;

  UnsplashImagePost({
    required this.image,
    required this.description,
    required this.totalLikes,
    required this.createdAt,
  });
}
