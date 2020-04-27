import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class AddScreen extends StatefulWidget {
  const AddScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  var qrText = "";
  var flashState = flash_on;
  var cameraState = front_camera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                // Max Size
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
                Positioned(
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    top: statusBarHeight + 15,
                    left: 5),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Escanea el código QR",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      IconButton(
                        icon: _isFlashOn(flashState)
                            ? Icon(Icons.flash_on, size: 30,)
                            : Icon(Icons.flash_off, size: 30,),
                        color: Colors.white,
                        tooltip: _isFlashOn(flashState)
                            ? 'Encender flash'
                            : 'Apagar flash',
                        onPressed: () {
                          if (controller != null) {
                            controller.toggleFlash();
                            if (_isFlashOn(flashState)) {
                              setState(() {
                                flashState = flash_off;
                              });
                            } else {
                              setState(() {
                                flashState = flash_on;
                              });
                            }
                          }
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                )
              ],
            ),
            flex: 4,
          ),
        ],
      ),
    );
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }

  _isBackCamera(String current) {
    return back_camera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
