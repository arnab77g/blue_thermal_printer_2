import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:blue_thermal_printer_2/screen_other/print_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {'title': 'Milk', 'price': 25, 'qty': 1},
    {'title': 'Potato', 'price': 35, 'qty': 500},
  ];

  // final f = NumberFormat("###,###.00", "en_US");
  @override
  Widget build(BuildContext context) {
    int _total = 0;
    // _total= data.map((e)=>e['price'] * e['qty']).reduce((value, element) => value+element)
    return Scaffold(
        appBar:
            AppBar(title: Text('Print App'), backgroundColor: Colors.redAccent),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (c, i) {
                      return ListTile(
                        title: Text(
                          data[i]['title'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    })),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Print button:'),
                  SizedBox(
                    width: 80,
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PrintPage(data)));
                      },
                      icon: Icon(Icons.print),
                      label: Text('Print'),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Text("2nd element"),
            )
          ],
        ));
  }
}
