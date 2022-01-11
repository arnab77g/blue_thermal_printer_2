import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  PrintPage(this.data);
  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => initPrinter());
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 3));
    if (!mounted) return;
    bluetoothPrint.scanResults.listen((event) {
      if (!mounted) return;
      setState(() {
        _devices = event;
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "No Devices";
          });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Printer'),
          backgroundColor: Colors.redAccent,
        ),
        body: _devices.isEmpty
            ? Center(
                child: Text(_devicesMsg.toString() ?? ''),
              )
            : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.print),
                    title: Text(_devices[index].name.toString()),
                    subtitle: Text(_devices[index].address.toString()),
                    onTap: () {
                      _startPrint(_devices[index]);
                      // bluetoothPrint.connect(_devices[index]);
                      // bluetoothPrint.printTest();
                    },
                  );
                },
              ));
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);
      Map<String, dynamic> config = Map();
      List<LineText> list = [];
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: "Gravery",
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      await bluetoothPrint.printReceipt(config, list);
    }
  }
}
