import 'dart:async';
import 'dart:io' as io;

import 'package:konnect/models/server.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  static Database _db;

  final String serverTable = 'serverTable';
  final String columnId = 'id';
  final String columnColor = 'color';
  final String columnIp = 'ip';
  final String columnPort = 'port';
  final String columnUsername = 'username';
  final String columnPassword = 'password';
  final String columnB64Image = 'b64Image';

  final String configTable = 'config';

  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<int> deleteServer(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(serverTable, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $serverTable WHERE $columnId = $id');
  }

  Future<List> getAllServers() async {
    var dbClient = await db;
    var result = await dbClient.query(serverTable);
    //var result = await dbClient.query(serverTable, columns: [columnId, columnTitle, columnDescription]);
//    var result = await dbClient.rawQuery('SELECT * FROM $serverTable');

    return result.toList();
  }

  Future<String> getConfig(String name) async {
    var dbClient = await db;
    List<Map> result =
        await dbClient.query(configTable, where: 'name = ?', whereArgs: [name]);

    if (result.length > 0) {
      return result.first["value"];
    }

    return null;
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $serverTable'));
  }

  Future<Server> getServer(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient
        .query(serverTable, where: '$columnId = ?', whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $serverTable WHERE $columnId = $id');

    if (result.length > 0) {
      return Server.fromMap(result.first);
    }

    return null;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "konnect.db");

    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> saveConfig(String name, String value, [String id]) async {
    var dbClient = await db;

    List<Map> result = await dbClient
        .query(configTable, where: 'name = ?', whereArgs: [name]);
    if (result.length > 0){
      return await dbClient.rawUpdate('UPDATE $configTable SET value = \'$value\' WHERE name = $name');
    }else{
      return await dbClient.rawInsert('INSERT INTO $configTable (name, value) VALUES (\'$name\', \'$value\')');
    }
    
  }

  Future<int> saveServer(Server server) async {
    var dbClient = await db;
    var result = await dbClient.insert(serverTable, server.toMap());
    return result;
  }

  Future<int> updateServer(Server server) async {
    var dbClient = await db;
    return await dbClient.update(serverTable, server.toMap(),
        where: "$columnId = ?", whereArgs: [server.id]);
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $serverTable($columnId INTEGER PRIMARY KEY, $columnColor TEXT, $columnIp TEXT, $columnPort TEXT, $columnUsername TEXT, $columnPassword TEXT, $columnB64Image TEXT)');

    await db.execute(
        'CREATE TABLE  $configTable(id INTEGER PRIMARY KEY, name TEXT, value TEXT)');
  }
}
