import 'package:flutter/material.dart';
import 'package:konnect/screens/stats/stats_card.dart';
import 'package:konnect/socket_manager.dart';
import 'package:filesize/filesize.dart';

class StatsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  StatsScreen({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StatsScreenState();
  }
}

class _StatsScreenState extends State<StatsScreen> {
  Map _statsData;
  final String _action = "get_stats";

  @override
  Widget build(BuildContext context) {
    List<StatsCardModel> cards = <StatsCardModel>[];
    StatsCardModel generalInfo = StatsCardModel(
      title: "Información General",
      icon: Icon(Icons.laptop, color: Colors.deepOrange),
      info: <Map>[
        {
          "key": "Usuario",
          "value": _getStatsDataKey("currentUser"),
        },
        {
          "key": "Máquina",
          "value": _getStatsDataKey("machineName"),
        },
        {
          "key": "Sistema Operativo",
          "value": _getStatsDataKey("os"),
        },
        {
          "key": "IP",
          "value": _getStatsDataKey("ip"),
        }
      ],
    );

    StatsCardModel processorInfo = StatsCardModel(
      title: "Procesador",
      icon: Icon(Icons.developer_board, color: Colors.deepPurple),
      info: <Map>[
        {
          "key": "Procesador",
          "value": _getStatsDataKey("processorName"),
        },
        {
          "key": "Velocidad",
          "value": _getStatsDataKey("processorClock"),
        },
        {
          "key": "Núcleos",
          "value": _getStatsDataKey("processorCores"),
        },
        {
          "key": "Hilos",
          "value": _getStatsDataKey("processorThreads", ''),
        }
      ],
    );

    double ramPercentage = _getStatsDataKey("ramUsedPercent",0) / 100; 
    StatsCardModel ramInfo = StatsCardModel(
        title: "Memoria RAM",
        icon: Icon(
          Icons.memory,
          color: Colors.green,
        ),
        info: <Map>[
          {
            "key": "Número de procesos",
            "value": _getStatsDataKey("nofProcess"),
          },
          {
            "key": "Total",
            "value": filesize(_getStatsDataKey("ramTotal", 0)),
          },
          {
            "key": "Uso",
            "value": filesize(_getStatsDataKey("ramUsed",0)),
          },
        ],
        extraWidgets: <Widget>[
          LinearProgressIndicator(
            value: ramPercentage,
          )
        ]);

    cards.add(generalInfo);
    cards.add(processorInfo);
    cards.add(ramInfo);

    var disks = _getStatsDataKey("disks");
    if (disks != null && disks.length > 0) {
      for (Map disk in disks) {
        double diskPercent = disk["usedPercent"] != null ? disk["usedPercent"] / 100: 0;
        cards.add(StatsCardModel(
            title: "Disco " + disk["letter"],
            icon: Icon(
              Icons.storage,
              color: Colors.blueGrey,
            ),
            info: <Map>[
              {
                "key": "Unidad",
                "value": disk["letter"],
              },
              {
                "key": "Nombre",
                "value": disk["label"],
              },
              {
                "key": "Total",
                "value": filesize(disk["total"]),
              },
              {
                "key": "Libre",
                "value": filesize(disk["free"]),
              },
            ],
            extraWidgets: <Widget>[
              LinearProgressIndicator(
                value:  diskPercent,
              )
            ]));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Estadísticas"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            widget.parentScaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getData();
        },
        child: _statsData == null
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                children: cards.map((StatsCardModel cardModel) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: StatsCard(
                      cardModel: cardModel,
                    ),
                  );
                }).toList()),
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

  _getStatsDataKey(String key, [dynamic defaultOption]) {
    if (_statsData != null && _statsData.containsKey(key)) {
      return _statsData[key];
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
        _statsData = message;
      });
    }
  }
}
