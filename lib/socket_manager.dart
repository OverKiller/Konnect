import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:konnect/models/server.dart';
import 'package:web_socket_channel/io.dart';


SocketManager sockets = SocketManager();

class SocketManager {
  static final SocketManager _sockets = SocketManager._internal();
  Server currentServer;

  IOWebSocketChannel _channel;
  bool _isOn = false;

  ObserverList<Function> _listeners = ObserverList<Function>();

  factory SocketManager() {
    return _sockets;
  }

  SocketManager._internal();


  addListener(Function callback) {
    _listeners.add(callback);
  }


  initCommunication(Server server) async {

    reset();


    try {
      currentServer = server;
      String serverAddress = "ws://${currentServer.ip}:${currentServer.port}";
      _channel = IOWebSocketChannel.connect(serverAddress);
      _isOn = true;
      send(json.encode(
        {
          "action": "login",
          "params": {
            "username": "testing",
            "password": "testing",
          },
        },
      ));


      _channel.stream.listen(_onReceptionOfMessageFromServer,
          onError: (error, StackTrace stackTrace) {
        print(error);
      }, onDone: () {
        _isOn = false;
      });
    } catch (e) {
      print("[SocketManagerGeneral] ${e.toString()}");
    }
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        _isOn = false;
      }
    }
  }

  send(dynamic message) {
    if (message is Map) {
      message = json.encode(message);
    }

    if (message is String) {
      if (_channel != null) {
        if (_channel.sink != null && _isOn) {
          _channel.sink.add(message);
        }else{
          print("[SocketManager][Send] _channel sink null");  
        }
      }else{
        print("[SocketManager][Send] _channel null");  
      }
    } else {
      print("[SocketManager][Send] Invalid type");
    }
  }

  _onReceptionOfMessageFromServer(message) {
    try {
      Map jmessage = json.decode(message);
      _listeners.forEach((Function callback) {
        callback(jmessage);
      });
    } catch (e) {
      print("[SocketManager][_onReceptionOfMessageFromServer] ${e.toString()}");
    }
  }
}
