import 'package:flutter/material.dart';

class BottomControls extends StatelessWidget {
  final Function(String) changeMediaFunction;
  final Map mediaPlayerData;

  BottomControls({this.changeMediaFunction, this.mediaPlayerData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Material(
        shadowColor: const Color(0x44000000),
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 50.0),
          child: Column(
            children: <Widget>[
              RichText(
                text: TextSpan(text: '', children: [
                  TextSpan(
                    text: mediaPlayerData["title"] + '\n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: mediaPlayerData["artist"],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12.0,
                      letterSpacing: 3.0,
                      height: 1.5,
                    ),
                  ),
                ]),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Container()),
                    PreviousButton(changeMediaFunction: changeMediaFunction),
                    Expanded(child: Container()),
                    PlayPauseButton(
                        changeMediaFunction: changeMediaFunction,
                        playerState: mediaPlayerData["state"]),
                    Expanded(child: Container()),
                    NextButton(changeMediaFunction: changeMediaFunction),
                    Expanded(child: Container()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final Function(String) changeMediaFunction;

  NextButton({this.changeMediaFunction});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.deepPurple,
      highlightColor: Colors.blue,
      icon: Icon(
        Icons.skip_next,
        color: Colors.white,
        size: 35.0,
      ),
      onPressed: () {
        this.changeMediaFunction("next");
      },
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final Function(String) changeMediaFunction;
  final String playerState;

  PlayPauseButton({this.changeMediaFunction, this.playerState});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.music_note;
    Color buttonColor = Colors.deepOrangeAccent;
    String button;
    if (playerState == "playing") {
      icon = Icons.pause;
      button = 'pause';
    } else if (playerState == "paused" || playerState == "completed") {
      icon = Icons.play_arrow;
      button = 'play';
    }
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: buttonColor,
      splashColor: buttonColor.withOpacity(0.1),
      highlightColor: buttonColor.withOpacity(0.5),
      elevation: 10.0,
      highlightElevation: 5.0,
      onPressed: () {
        this.changeMediaFunction(button);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: Colors.white,
          size: 35.0,
        ),
      ),
    );
  }
}

class PreviousButton extends StatelessWidget {
  final Function(String) changeMediaFunction;

  PreviousButton({this.changeMediaFunction});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.blue,
      highlightColor: Colors.transparent,
      icon: Icon(
        Icons.skip_previous,
        color: Colors.white,
        size: 35.0,
      ),
      onPressed: () {
        this.changeMediaFunction("previous");
      },
    );
  }
}
