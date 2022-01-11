import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (BuildContext ca,
                      AsyncSnapshot<List<BluetoothDevice>> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      return Column(
                        children: snapshot.data!
                            .map(
                              (d) => ListTile(
                                title: Text(d.name ?? ''),
                                subtitle: Text(d.address ?? 'Not available XX'),
                                onTap: () async {
                                  setState(() {
                                    _device = d;
                                  });
                                },
                                trailing: _device != null &&
                                        _device?.address == d.address
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                            )
                            .toList(),
                      );
                    }
                  },
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('connect'),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device?.address != null) {
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      print('please select device');
                                    }
                                  },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('disconnect'),
                            onPressed: _connected
                                ? () async {
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      OutlinedButton(
                        child: Text('print receipt(Text)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();
                                config['width'] =
                                    40; // 标签宽度，单位mm Label width, unit mm
                                config['height'] =
                                    70; // 标签高度，单位mm Label height, unit mm
                                // config['gap'] = 2; // 标签间隔，单位mm Label interval, unit mm
                                config['gap'] =
                                    5; // 标签间隔，单位mm Label interval, unit mm
                                List<LineText> list = [];
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Pernod Ricard India',
                                    align: LineText.ALIGN_CENTER,
                                    weight: 3,
                                    size: 5,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Visitor Pass',
                                    weight: 1,
                                    size: 10,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Pass No: 37',
                                    weight: 0,
                                    x: 5,
                                    align: LineText.ALIGN_LEFT,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Visitor Name: Deepak',
                                    align: LineText.ALIGN_LEFT,
                                    x: 10,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Visitor Mobile: 9312000496',
                                    align: LineText.ALIGN_LEFT,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Entry Date: 30-12-2021 07:30PM',
                                    align: LineText.ALIGN_LEFT,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                // ByteData data = await rootBundle
                                //     .load('assets/images/bluetooth_print.png');
                                // // ByteData data = await AssetImage.
                                // List<int> imageBytes = data.buffer.asUint8List(
                                //     data.offsetInBytes, data.lengthInBytes);
                                // String base64Image = base64Encode(imageBytes);
                                // list.add(LineText(
                                //     type: LineText.TYPE_IMAGE,
                                //     content: base64Image,
                                //     align: LineText.ALIGN_CENTER,
                                //     linefeed: 1));

                                await bluetoothPrint.printReceipt(config, list);
                              }
                            : null,
                      ),
                      OutlinedButton(
                        child: Text('print (Picture)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();
                                config['width'] =
                                    40; // 标签宽度，单位mm Label width, unit mm
                                config['height'] =
                                    70; // 标签高度，单位mm Label height, unit mm
                                // config['gap'] = 2; // 标签间隔，单位mm Label interval, unit mm
                                config['gap'] =
                                    5; // 标签间隔，单位mm Label interval, unit mm

                                // x、y坐标位置，单位dpi，1mm=8dpi
                                List<LineText> list = [];
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 10,
                                    content: 'A Title\n'));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 40,
                                    content: 'this is content\n\n'));
                                // list.add(LineText(
                                //     type: LineText.TYPE_QRCODE,
                                //     x: 10,
                                //     y: 70,
                                //     content: 'qrcode i\n'));
                                // list.add(LineText(
                                //     type: LineText.TYPE_BARCODE,
                                //     x: 10,
                                //     y: 190,
                                //     content: 'qrcode i\n'));

                                List<LineText> list1 = [];
                                ByteData data = await rootBundle
                                    .load("assets/images/bluetooth_print.png");
                                List<int> imageBytes = data.buffer.asUint8List(
                                    data.offsetInBytes, data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                list.add(LineText(
                                  type: LineText.TYPE_IMAGE,
                                  content: base64Image,
                                  align: LineText.ALIGN_CENTER,
                                  x: 10,
                                  y: 10,
                                ));
                                // ByteData data = await rootBundle
                                //     .load('assets/images/bluetooth_print.png');
                                // // ByteData data = await AssetImage.
                                // List<int> imageBytes = data.buffer.asUint8List(
                                //     data.offsetInBytes, data.lengthInBytes);
                                // String base64Image = base64Encode(imageBytes);
                                // list.add(LineText(
                                //     type: LineText.TYPE_IMAGE,
                                //     content: base64Image,
                                //     align: LineText.ALIGN_CENTER,
                                //     linefeed: 1));

                                await bluetoothPrint.printLabel(config, list);
                                // await bluetoothPrint.printLabel(config, list1);
                              }
                            : null,
                      ),
                      // OutlinedButton(
                      //   child: Text('print selftest'),
                      //   onPressed: _connected
                      //       ? () async {
                      //           await bluetoothPrint.printTest();
                      //         }
                      //       : null,
                      // )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (BuildContext c, AsyncSnapshot snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () =>
                      bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}
