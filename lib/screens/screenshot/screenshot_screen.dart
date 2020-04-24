import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:konnect/socket_manager.dart';
import 'package:photo_view/photo_view.dart';

class ScreenShotScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ScreenShotScreen({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _ScreenShotScreenState createState() => _ScreenShotScreenState();
}

class _ScreenShotScreenState extends State<ScreenShotScreen> {
  Map _screenShotData;
  final String _action = "get_screenshot";
  @override
  Widget build(BuildContext context) {
    Uint8List bytes;
    String b64img = _getScreenShotDataKey("b64img");

    if (b64img != null) {
      try {
        bytes = base64Decode(b64img);
      } catch (e) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Captura de pantalla"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            widget.parentScaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getData();
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getData();
        },
        child: _screenShotData == null || bytes == null
            ? Center(child: CircularProgressIndicator())
            : PhotoView(
                imageProvider: MemoryImage(bytes),
                enableRotation: true,
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() {
    Map data = {"action": _action};
    sockets.send(data);
  }

  @override
  void initState() {
    super.initState();
    sockets.addListener(_onMessageReceived);
    getData();
  }

  _getScreenShotDataKey(String key, [dynamic defaultOption]) {
    if (_screenShotData != null && _screenShotData.containsKey(key)) {
      return _screenShotData[key];
    } else {
      return defaultOption;
    }
  }

  _onMessageReceived(message) {
    if (!mounted) {
      return;
    }
    if (message.containsKey("action") && message["action"] == _action) {
      setState(() {
        _screenShotData = message;
      });
    }
  }
}
