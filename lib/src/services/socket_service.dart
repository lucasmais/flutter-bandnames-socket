import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  OnLine,
  OffLine,
  Connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => this._socket.emit;

  SocketService() {
    _iniConfig();
  }

  void _iniConfig() {
    _socket = IO.io('http://172.22.32.12:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.OnLine;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.OffLine;
      notifyListeners();
    });
  }
}
