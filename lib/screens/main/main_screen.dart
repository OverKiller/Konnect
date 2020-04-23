import 'package:flutter/material.dart';
import 'package:konnect/database_helper.dart';
import 'package:konnect/models/server.dart';
import 'package:konnect/screens/mediaplayer/mediaplayer_min.dart';
import 'package:konnect/screens/stats/stats_screen.dart';
import 'package:konnect/socket_manager.dart';

class DrawerItem {
  String title;
  IconData icon;
  String route;

  DrawerItem(this.title, this.icon, {this.route});
}

class MainScreen extends StatefulWidget {
  final drawerItems = [
    DrawerItem("Estadísticas", Icons.insert_chart),
    DrawerItem("Administrador de procesos", Icons.code),
    DrawerItem("Captura de pantalla", Icons.image),
    DrawerItem("Reproducción remota", Icons.music_video),
    DrawerItem("Entrada remota", Icons.mouse),
    DrawerItem("Agregar Equipo", Icons.add_to_queue, route: "/add-screen")
  ];

  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _selectedDrawerIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseHelper dbHelper;

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i, d),
      ));
    }
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage('assets/drawerBackground.png'),
                      fit: BoxFit.cover),
                ),
                accountName: Text("WIP"),
                accountEmail: null),
            Column(children: drawerOptions)
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: MediaPlayerMinimized(parentScaffoldKey: _scaffoldKey),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  void initApp() async{
    dbHelper = DatabaseHelper();
    String currentServerId = await dbHelper.getConfig("current_server");
    if (currentServerId != null){
      Server currentServer = await dbHelper.getServer(int.parse(currentServerId));
      sockets.initCommunication(currentServer);
      print("Cargó el server de la db");
    }else{
      //Tutorial and scan PC

      Server s = Server("72.44.68.171", "3567", "testing", "testing", "55555");
      int id = await dbHelper.saveServer(s);
      await dbHelper.saveConfig("current_server", id.toString());
      print("Creó server en la db");
      await sockets.initCommunication(s);
    }
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return StatsScreen(parentScaffoldKey: _scaffoldKey);
      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index, DrawerItem item) {
    Navigator.of(context).pop(); // close the drawer

    if (item.route != null) {
      Navigator.of(_scaffoldKey.currentContext).pushNamed(item.route);
    } else {
      setState(() => _selectedDrawerIndex = index);
    }
  }
}
