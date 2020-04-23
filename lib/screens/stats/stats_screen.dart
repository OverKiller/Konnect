import 'package:flutter/material.dart';
import 'package:konnect/screens/stats/stats_card.dart';
import 'package:konnect/socket_manager.dart';

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
          "value": _getStatsDataKey("currentuser"),
        },
        {
          "key": "Máquina",
          "value": _getStatsDataKey("machinename"),
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
          "value": _getStatsDataKey("processorname"),
        },
        {
          "key": "Velocidad",
          "value": _getStatsDataKey("processorclock"),
        },
        {
          "key": "Núcleos",
          "value": _getStatsDataKey("processorcores"),
        },
        {
          "key": "Hilos",
          "value": _getStatsDataKey("processorthreads"),
        }
      ],
    );
    var totalram = _getStatsDataKey("totalram");
    var ramusage = _getStatsDataKey("ramusage");
    double ramPercetange = 0.0;
    if (totalram != null && ramusage != null) {
      ramPercetange = ramusage / totalram;
    }

    StatsCardModel ramInfo = StatsCardModel(
        title: "Memoria RAM",
        icon: Icon(
          Icons.memory,
          color: Colors.green,
        ),
        info: <Map>[
          {
            "key": "Número de procesos",
            "value": _getStatsDataKey("nofprocess"),
          },
          {
            "key": "Total",
            "value": _getStatsDataKey("totalram"),
          },
          {
            "key": "Uso",
            "value": _getStatsDataKey("ramusage"),
          },
        ],
        extraWidgets: <Widget>[
          LinearProgressIndicator(
            value: ramPercetange,
          )
        ]);

    cards.add(generalInfo);
    cards.add(processorInfo);
    cards.add(ramInfo);

    var disks = _getStatsDataKey("disks");
    if (disks != null && disks.length > 0) {
      for (Map disk in disks) {
        double percetange = (disk["free"] / disk["totalsize"]);
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
                "value": disk["totalsize"],
              },
              {
                "key": "Libre",
                "value": disk["free"],
              },
            ],
            extraWidgets: <Widget>[
              LinearProgressIndicator(
                value: percetange,
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
    print("llama getData");
    Map data = {"action": _action};
    sockets.send(data);
  }

  @override
  void initState() {
    super.initState();
    sockets.addListener(_onMessageReceived);
    getData();
  }

  _getStatsDataKey(String key) {
    if (_statsData != null && _statsData.containsKey(key)) {
      return _statsData[key];
    } else {
      return null;
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
