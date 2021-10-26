import 'dart:convert';

import 'package:visual_search/app/unsplash.dart';
import 'package:http/http.dart' as http;

const kUnsplashBaseUrl = "https://api.unsplash.com";
// TODO: Please use your Access Key
const kUnsplashClientId = "HpMJb14GjCX-w589Fjeqs3wTdCaR-Rm4BVeiBXcxhCA";

class UnsplashService {
  static final UnsplashService _unsplashService = UnsplashService._internal();

  factory UnsplashService() {
    return _unsplashService;
  }

  UnsplashService._internal();

  Future<List<Unpslash>?> random({int count = 20}) async {
    var uri = Uri.parse(
        "$kUnsplashBaseUrl/photos/random?client_id=$kUnsplashClientId&count=$count");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonDecode = json.decode(response.body);

      List results = jsonDecode;
      List<Unpslash> unsplashList = [];
      results.forEach((element) {
        unsplashList.add(Unpslash.create(element));
      });
      return unsplashList;
    }

    return null;
  }

  Future<List<Unpslash>?> search(String value,
      {int page = 1, int perPage = 50}) async {
    var uri = Uri.parse(
        "$kUnsplashBaseUrl/search/photos?client_id=$kUnsplashClientId&query=$value&page=$page&per_page=$perPage");
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      var jsonDecode = json.decode(response.body);

      List results = jsonDecode['results'];
      List<Unpslash> unsplashList = [];
      results.forEach((element) {
        unsplashList.add(Unpslash.create(element));
      });
      return unsplashList;
    }

    return null;
  }
}
