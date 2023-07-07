import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photos_server_flutter/api_key.dart';
import 'package:photos_server_flutter/model.dart';

class DataSingletonProvider extends ChangeNotifier {
  Future<Folder> folders = FolderHelper.getFolders();
  Future<Map<DateTime, int>> allDates = FolderHelper.getNbPhotosForAllDates();
}

class FolderHelper {
  static Future<Folder> getFolders() async {
    var resp = await http.get(Uri.parse("$endpoint/rootFolders"),
        headers: {HttpHeaders.cookieHeader: "token=$apiKey"});
    var content = jsonDecode(resp.body);
    var folder = Folder.fromJSON(content);
    return folder.children[0];
  }

  static Future<Map<DateTime, int>> getNbPhotosForAllDates() async {
    var resp = await http.get(Uri.parse("$endpoint/allDates"),
        headers: {HttpHeaders.cookieHeader: "token=$apiKey"});
    var content = jsonDecode(resp.body);
    Map<DateTime, int> m = {};
    (content as List<dynamic>)
        .map((m) => NbPhotosByDate.fromJSON(m))
        .forEach((element) {
      m[element.date] = element.nb;
    });
    return m;
  }

  static String formatDate(DateTime date) {
    return "${date.year}${date.month >= 10 ? date.month : "0${date.month}"}${date.day >= 10 ? date.day : "0${date.day}"}";
  }

  static Future<List<Picture>> getPhotosByDate(String date) async {
    var resp = await http.get(Uri.parse("$endpoint/getByDate?date=$date"),
        headers: {HttpHeaders.cookieHeader: "token=$apiKey"});
    return extractPhotosFromData(resp.body);
  }

  static Future<List<Picture>> getPhotosOfFolder(String searchKey) async {
    var resp = await http.get(Uri.parse("$endpoint$searchKey"),
        headers: {HttpHeaders.cookieHeader: "token=$apiKey"});
    return extractPhotosFromData(resp.body);
  }

  static List<Picture> extractPhotosFromData(String body) {
    if (body.isEmpty) {
      return [];
    }
    var content = jsonDecode(body);
    var files = content["Files"] as List;
    var data = files
        .where((d) => (d as Map<String, dynamic>).containsKey("ThumbnailLink"))
        .map((f) => Picture.fromJSON(f))
        .toList();
    data.sort((a, b) => a.date.compareTo(b.date));
    return data;
  }

  Image getImage(String url) {
    return Image.network("$endpoint$url",
        fit: BoxFit.fill,
        headers: const {HttpHeaders.cookieHeader: "token=$apiKey"});
  }

  Image getImageNoFit(String url) {
    return Image.network("$endpoint$url",
        headers: const {HttpHeaders.cookieHeader: "token=$apiKey"});
  }

  Image getImageWithSize(String url, double width, double height) {
    return Image.network("$endpoint$url",
        width: width,
        height: height,
        fit: BoxFit.fill,
        headers: const {HttpHeaders.cookieHeader: "token=$apiKey"});
  }
}
