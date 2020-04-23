import 'dart:math';

import 'package:flutter/material.dart';
import 'package:konnect/screens/mediaplayer/bottom_controls.dart';
import 'package:konnect/socket_manager.dart';
import 'package:konnect/utils.dart';
import 'package:meta/meta.dart';

class MediaPlayerMax extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Map mediaPlayerData;

  MediaPlayerMax({Key key, this.parentScaffoldKey, this.mediaPlayerData})
      : super(key: key);

  @override
  _MediaPlayerMaxState createState() => _MediaPlayerMaxState();
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.progressPercent = 0.0,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child,
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;

  RadialSeekBarPainter(
      {@required this.trackWidth,
      @required trackColor,
      @required this.progressWidth,
      @required progressColor,
      @required this.progressPercent})
      : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, 10.0));
    Size constrainedSize = Size(
      size.width - outerThickness,
      size.height - outerThickness,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;

    // Paint track.
    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    // Paint progress.
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _MediaPlayerMaxState extends State<MediaPlayerMax> {
  final String _action = "get_media_status";
  Map mediaPlayerData;

  @override
  Widget build(BuildContext context) {
    double progress;
    if (mediaPlayerData == null) {
      return Container(child: Text("nada"));
    }
    var currentSecond = mediaPlayerData["currentsecond"];
    var total = mediaPlayerData["duration"];
    if (currentSecond != null && total == null) {
      progress = 0.0;
    } else {
      progress = currentSecond / total;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(' '),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
            ),
            color: Colors.grey,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Seek bar
          Expanded(
            child: Center(
                child: Container(
              width: 140.0,
              height: 140.0,
              child: RadialProgressBar(
                trackColor: const Color(0xFFDDDDDD),
                progressPercent: progress,
                progressColor: Colors.deepOrange,
                innerPadding: const EdgeInsets.all(10.0),
                child: Hero(
                  tag: 'media_player_image',
                  child: ClipOval(
                    clipper: CircleClipper(),
                    child: Container(
                      color: Colors.deepOrange,
                      child: Image.network(
                        mediaPlayerData["image"],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ),
          // Song title, artist name, and controls
          BottomControls(
              changeMediaFunction: changeMedia,
              mediaPlayerData: mediaPlayerData)
        ],
      ),
    );
  }

  changeMedia(String button) {
    Map data = {
      "action": "change_media",
      "params": {"button": button}
    };
    sockets.send(data);
  }

  @override
  void dispose() {
    sockets.removeListener(_onMessageReceived);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    mediaPlayerData = widget.mediaPlayerData;

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

class _RadialProgressBarState extends State<RadialProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
        ),
        child: Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }

  EdgeInsets _insetsForPainter() {
    final outerThickness = max(
          widget.trackWidth,
          max(
            widget.progressWidth,
            10.0,
          ),
        ) /
        2.0;
    return EdgeInsets.all(outerThickness);
  }
}
