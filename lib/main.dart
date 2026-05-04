import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MyTube());

class MyTube extends StatefulWidget {
  @override
  _MyTubeState createState() => _MyTubeState();
}

class _MyTubeState extends State<MyTube> {
  List videos = [];
  bool loading = true;
  final String apiKey = "AIzaSyALTXjfFT-jE7wjllZmghVEVb6WS_OeNwQ";
  String searchQuery = "flutter";

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() => loading = true);