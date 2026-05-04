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
    final url = Uri.parse(
      "https://www.googleapis.com/youtube/v3/search"
      "?part=snippet&q=$searchQuery&type=video&key=$apiKey&maxResults=10",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        videos = data['items'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTube',
      home: Scaffold(
        appBar: AppBar(
          title: Text('MyTube'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  setState(() => searchQuery = value);
                  fetchVideos();
                },
              ),
            ),
          ),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final videoId = video['id']['videoId'];
                  final title = video['snippet']['title'];
                  final thumbnail = video['snippet']['thumbnails']['high']['url'];
                  return ListTile(
                    leading: Image.network(thumbnail, width: 100, fit: BoxFit.cover),
                    title: Text(title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(videoId: videoId),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  const VideoPlayerPage({required this.videoId});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: true),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Now Playing')),
      body: YoutubePlayer(controller: _controller),
    );
  }
}