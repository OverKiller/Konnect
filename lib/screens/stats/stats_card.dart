import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final StatsCardModel cardModel;

  StatsCard({Key key, @required this.cardModel})
      : assert(cardModel != null && cardModel.isValid),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    widgets.add(
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                cardModel.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cardModel.icon
          ],
        ),
      ),
    );
    widgets.add(Divider());

    widgets.addAll(
      cardModel.info.map((Map data) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  data["key"] + ":",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: Text(
                data["value"].toString(),
                softWrap: true,
                textAlign: TextAlign.right,
              ))
            ],
          ),
        );
      }),
    );
    widgets.addAll(cardModel.extraWidgets);
    return SafeArea(
      top: false,
      bottom: false,
      child: Card(
        child: Column(children: widgets),
      ),
    );
  }
}

class StatsCardModel {
  final String title;

  final List<Map> info;
  final Icon icon;
  final List<Widget> extraWidgets;
  const StatsCardModel(
      {this.title, this.info, this.icon, this.extraWidgets = const <Widget>[]});

  bool get isValid => title != null;
}
