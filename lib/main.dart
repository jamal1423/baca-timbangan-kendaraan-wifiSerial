// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CekTimbangan(),
    );
  }
}

class CekTimbangan extends StatefulWidget {
  @override
  _CekTimbanganState createState() => _CekTimbanganState();
}

class _CekTimbanganState extends State<CekTimbangan> {
  late Socket socket;
  String statusSocket = '';
  bool statusConnect = false;
  String wifiSerialIp = '10.16.46.252';
  String wifiSerialPort = '8899';
  double hasiltimbang = 0;
  double hasiltimbangTmp = 0;

  // double tempN = 58.50;

  int samplingData = 0;
  int samplingDataTotal = 3;
  
  // List<dynamic> aa = [83, 212, 172, 71, 83, 172, 43, 48, 48, 184, 51, 46, 184, 53, 160, 231, 141, 10];
  // List<dynamic> aa = [83, 212, 172, 71, 83, 172, 43, 48, 48, 183, 54, 46, 177, 48, 160, 231, 141, 10];
  List<dynamic> aa = [83, 212, 172, 71, 83, 172, 43, 48, 48, 183, 54, 46, 184, 52, 160, 231, 141, 10];
  cekManual(){
    int target1 = 183;
    int target2 = 184;
    int newNumber1 = 55;
    int newNumber2 = 56;

    aa = aa.map((number) {
      if (number == target1) return newNumber1;
      if (number == target2) return newNumber2;
      return number;
    }).toList();
    late Uint8List uint8List = Uint8List.fromList(aa.map((item) => item as int).toList());
    parseListUint8(uint8List);
  }

  socketConnect() async {
    setState(() {
      samplingData = 0;
    });
    debugPrint("Mulai");
    try {
      socket = await Socket.connect(
        wifiSerialIp,
        int.parse(wifiSerialPort),
        timeout: const Duration(seconds: 5),
      );
      setState(() {
        statusSocket = 'Connected';
      });
      socket.listen(
        (event) {
          print("DATA ARRAY : "+event.toString());
          // int target1 = 183;
          // int target2 = 184;
          // // int target3 = 178;
          // int newNumber1 = 55;
          // int newNumber2 = 56;
          // // int newNumber3 = 50;

          // List<dynamic> xx = event.map((number) {
          //   if (number == target1) return newNumber1;
          //   if (number == target2) return newNumber2;
          //   // if (number == target3) return newNumber3;
          //   return number;
          // }).toList();
          // print(xx.toString());
          // late Uint8List uint8List = Uint8List.fromList(xx.map((item) => item as int).toList());
          // parseListUint8(uint8List);
          parseListUint8(event);
        },
        onError: (error) {
          setState(() {
            statusSocket = error.toString();
            statusConnect = false;
          });
          socket.destroy();
          debugPrint("Gagal Konek");
        },
        onDone: () {
          setState(() {
            statusSocket = 'Done';
            statusConnect = false;
          });
          socket.destroy();
          debugPrint("Sukses");
        },
      );
    } catch (e) {
      setState(() {
        statusSocket = e.toString();
        statusConnect = false;
      });
      debugPrint("Gagal Catch");
    }
  }

  parseListUint8(Uint8List xuint8list) async {
    String xstr = '';
    for (var i = 0; i < 18; i++) {
      if (xuint8list[i].toInt() >= 46 && xuint8list[i].toInt() <= 57) {
        xstr = xstr + String.fromCharCode(xuint8list[i].toInt());
      }
      debugPrint("DATA : "+xstr);
    }
    setState(() {
      hasiltimbang = double.parse(xstr.trim());
      // hasiltimbangTmp = double.parse(xstr.trim());
    });
    setState(() {
      samplingData++;
    });
    if (samplingData >= samplingDataTotal) {
      setState(() {
        statusConnect = false;
      });
      socket.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timbangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  if (!statusConnect) {
                    setState(() {
                      statusConnect = !statusConnect;
                    });
                    socketConnect();
                  }
                  // cekManual();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Load Cell", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Data Timbang", style: TextStyle(fontSize: 20)),
              Text(hasiltimbang.toString(), style: const TextStyle(fontSize: 40)),
              // Text(hasiltimbangTmp.toString(), style: const TextStyle(fontSize: 40)),
            ],
          ),
        ),
      ),
    );
  }
}