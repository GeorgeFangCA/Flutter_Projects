// My sample Flutter code
import 'dart:async';
import 'dart:convert';
import 'networking/url.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    VideoPlayerApp(),
  );
}

class VideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Video Player Demo',
        home: Center(
          child: VideoPlayerScreen(),
        ));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  List chatData;

  Future<String> getChatData() async {
    http.Response response = await http
        .get(Uri.encodeFull(jsonUrl), headers: {"Accept": "application/json"});

    this.setState(() {
      chatData = json.decode(response.body);
    });
    return "Success!";
  }

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      videoUrl,
    );
    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(true);
    super.initState();
    this.getChatData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var padding = 30.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player Demo'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(padding, padding, padding, 0),
              child: Text('Moment from meeting with Tow Pillars'),
            ),
            Container(
              margin: EdgeInsets.all(padding),
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0)
                  ]),
            ),
            Container(
              width: screenWidth - padding * 2,
              height: 300,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.blue[200],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0)
                  ]),
              child: SafeArea(
                child: new ListView.builder(
                  itemCount: chatData == null ? 0 : chatData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Card(
                      child: new Text(chatData[index]["snippet"]),
                      color: Colors.blue[200],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey.shade200,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
