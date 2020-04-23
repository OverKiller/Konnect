import 'package:flutter/material.dart';
import 'package:konnect/screens/mediaplayer/mediaplayer_max.dart';
import 'package:konnect/socket_manager.dart';
import 'package:konnect/utils.dart';

class MediaPlayerMinimized extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MediaPlayerMinimized({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _MediaPlayerMinimizedState createState() => _MediaPlayerMinimizedState();
}

class _MediaPlayerMinimizedState extends State<MediaPlayerMinimized> {
  final String _action = "get_media_status";
  Map mediaPlayerData;

  @override
  Widget build(BuildContext context) {
    if (mediaPlayerData == null) {
      return Container(width: 0.0, height: 0.0);
    }
    var currentSecond = mediaPlayerData["currentsecond"];
    var total = mediaPlayerData["duration"];
    if (currentSecond != null && total == null) {
      return Container(width: 0.0, height: 0.0);
    }
    double progress = currentSecond / total;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaPlayerMax(
                  parentScaffoldKey: widget.parentScaffoldKey,
                  mediaPlayerData: mediaPlayerData,
                ),
          ),
        );
      },
      child: Container(
        height: 50.0,
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 1.0,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Hero(
                      tag: 'media_player_image',
                      child: ClipOval(
                        clipper: CircleClipper(),
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          color: Colors.deepOrange,
                          child: Image.network(
                            mediaPlayerData["image"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        mediaPlayerData["title"],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.play_arrow),
                      Icon(Icons.keyboard_arrow_up),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sockets.removeListener(_onMessageReceived);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    sockets.addListener(_onMessageReceived);
  }

  _onMessageReceived(message) {
    if (!mounted) {
      return;
    }
    if (message.containsKey("action") && message["action"] == _action) {
      setState(() {
        mediaPlayerData = message;
      });
    }
  }
}
