class Server {
  int _id;
  String _color = "#fff";
  String _ip;
  String _port;
  String _username;
  String _password;
  String _b64Image;

  Server(this._ip, this._port, this._username, this._password, this._b64Image);

  Server.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._color = map['color'];
    this._ip = map['ip'];
    this._port = map['port'];
    this._username = map['username'];
    this._password = map['password'];
    this._b64Image = map['b64Image'];
  }

  Server.map(dynamic obj) {
    this._id = obj['id'];
    this._color = obj['color'];
    this._ip = obj['ip'];
    this._port = obj['port'];
    this._username = obj['username'];
    this._password = obj['password'];
    this._b64Image = obj['b64Image'];
  }
  String get b64Image => _b64Image;
  String get color => _color;
  int get id => _id;
  String get ip => _ip;
  String get password => _password;
  String get port => _port;

  String get username => _username;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['color'] = _color;
    map['ip'] = _ip;
    map['port'] = _port;
    map['username'] = _username;
    map['password'] = _password;
    map['b64Image'] = _b64Image;

    return map;
  }
}
