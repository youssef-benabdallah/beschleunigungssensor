// import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

// import 'package:path_provider/path_provider.dart';
//
// import 'package:csv/csv.dart';
// import 'package:share_extend/share_extend.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> _accelerometerValues = [0, 0, 0];
  double _gravity = 0;

  bool isRecording = false;

  List<double> _X = [];
  List<double> _Y = [];
  List<double> _Z = [];
  List<double> _G = [];
  List<int> _Time = [];
  List<int> _Intervall = [0];

  // List<List<String>> records = [
  //   ["Datum;X;Y;Z\n"]
  // ];

  String records = "Nummer;Datum;X;Y;Z;Gravity;Intervall\n";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < 3; i++)
            Padding(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(String.fromCharCode(i + 88) +
                      ':' +
                      _accelerometerValues[i].toStringAsFixed(5)),
                  RangeSlider(
                    min: -30,
                    max: 30,
                    key: null,
                    onChanged: null,
                    // value: (_accelerometerValues[i]).clamp(-10, 10),

                    values: getRangeValues(_accelerometerValues[i]),

                    // value: (-1.0).clamp(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Gravitation :' + _gravity.toStringAsFixed(5)),
                Slider(
                  key: null,
                  onChanged: null,
                  value: (_gravity / 20).clamp(0, 1),
                )
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: startStopRecord,
                    child: Text(
                        isRecording ? 'Stop Recording' : 'Start Recording'),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  void startStopRecord() {
    if (isRecording) {
      generateCsv();
      print(records);
      // isRecording = !isRecording;
      records = "Nummer;Datum;X;Y;Z;Gravity;Intervall\n";
      _X = [];
      _Y = [];
      _Z = [];
      _G = [];
      _Intervall = [0];
      _Time = [];
    }
    // else {
    isRecording = !isRecording;
    //   const intervall = Duration(seconds: 1);
    //   Timer.periodic(
    //       intervall,
    //       (Timer t) => {
    //             if (!isRecording)
    //               {t.cancel()}
    //             else
    //               {
    //                 records.add([
    //                   DateTime.now().toString(),
    //                   _accelerometerValues[0].toStringAsFixed(3),
    //                   _accelerometerValues[1].toStringAsFixed(3),
    //                   _accelerometerValues[2].toStringAsFixed(3)
    //                 ]),
    //                 // print(records.last),
    //               }
    //           });
    // }
  }

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _gravity = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        if (isRecording) {
          _X.add(_accelerometerValues[0]);
          _Y.add(_accelerometerValues[1]);
          _Z.add(_accelerometerValues[2]);
          _G.add(_gravity);
          _Time.add(DateTime.now().millisecondsSinceEpoch);
          if (_Time.length > 1) {
            _Intervall.add(_Time.last - _Time.elementAt(_Time.length - 2));
          }

          records += _X.length.toString() +
              ';' +
              _Time.last.toString() +
              ';' +
              _accelerometerValues[0].toStringAsFixed(5) +
              ';' +
              _accelerometerValues[1].toStringAsFixed(5) +
              ';' +
              _accelerometerValues[2].toStringAsFixed(5) +
              ';' +
              _gravity.toStringAsFixed(5) +
              ';' +
              _Intervall.last.toString() +
              '\n';
          // print(records.last),
        }
      });
    });
  }

  RangeValues getRangeValues(double x) {
    if (x < 0) {
      return RangeValues(x, 0);
    } else if (x > 0) {
      return RangeValues(0, x);
    } else {
      return const RangeValues(0, 0);
    }
  }

  String getMaxValueXYZG() {
    double maxValueX = _X[0];
    double maxValueY = _Y[0];
    double maxValueZ = _Z[0];
    double maxValueG = _G[0];

    for (int i = 1; i < _X.length; i++) {
      if (maxValueX < _X[i]) {
        maxValueX = _X[i];
      }
      if (maxValueY < _Y[i]) {
        maxValueY = _Y[i];
      }
      if (maxValueZ < _Z[i]) {
        maxValueZ = _Z[i];
      }
      if (maxValueG < _G[i]) {
        maxValueG = _G[i];
      }
    }

    String X = maxValueX.toStringAsFixed(5);
    String Y = maxValueY.toStringAsFixed(5);
    String Z = maxValueZ.toStringAsFixed(5);
    String G = maxValueG.toStringAsFixed(5);

    return (';MAX Value;$X;$Y;$Z;$G\n');
  }

  String getMinValueXYZG() {
    double minValueX = _X[0];
    double minValueY = _Y[0];
    double minValueZ = _Z[0];
    double minValueG = _G[0];

    for (int i = 1; i < _X.length; i++) {
      if (minValueX > _X[i]) {
        minValueX = _X[i];
      }
      if (minValueY > _Y[i]) {
        minValueY = _Y[i];
      }
      if (minValueZ > _Z[i]) {
        minValueZ = _Z[i];
      }
      if (minValueG > _G[i]) {
        minValueG = _G[i];
      }
    }

    String X = minValueX.toStringAsFixed(5);
    String Y = minValueY.toStringAsFixed(5);
    String Z = minValueZ.toStringAsFixed(5);
    String G = minValueG.toStringAsFixed(5);



    return (';MIN Value;$X;$Y;$Z;$G\n');
  }

  List<double> getAverageXYZG() {
    double sumValueX = 0;
    double sumValueY = 0;
    double sumValueZ = 0;
    double sumValueG = 0;

    for (int i = 0; i < _X.length; i++) {
      sumValueX += _X[i];
      sumValueY += _Y[i];
      sumValueZ += _Z[i];
      sumValueG += _G[i];
    }

    double averageX = sumValueX / _X.length;
    double averageY = sumValueY / _Y.length;
    double averageZ = sumValueZ / _Z.length;
    double averageG = sumValueG / _G.length;

    return ([averageX, averageY, averageZ, averageG]);

    // return ('Average Value;$averageX;$averageY;$averageZ');
  }

  String getVarianceXYZG() {
    double varValueX = 0;
    double varValueY = 0;
    double varValueZ = 0;
    double varValueG = 0;

    List<double> averageXYZG = getAverageXYZG();

    double averageX = averageXYZG[0];
    double averageY = averageXYZG[1];
    double averageZ = averageXYZG[2];
    double averageG = averageXYZG[3];

    for (int i = 0; i < _X.length; i++) {
      varValueX += (pow(_X[i] - averageX, 2) as double?)!;
      varValueY += (pow(_Y[i] - averageY, 2) as double?)!;
      varValueZ += (pow(_Z[i] - averageZ, 2) as double?)!;
      varValueG += (pow(_G[i] - averageG, 2) as double?)!;
    }
    varValueX = varValueX / (_X.length - 1);
    varValueY = varValueY / (_Y.length - 1);
    varValueZ = varValueZ / (_Z.length - 1);
    varValueG = varValueG / (_G.length - 1);

    String X = varValueX.toStringAsFixed(5);
    String Y = varValueY.toStringAsFixed(5);
    String Z = varValueZ.toStringAsFixed(5);
    String G = varValueG.toStringAsFixed(5);

    return (';Variance Value;$X;$Y;$Z;$G\n');
  }

  generateCsv() async {
    // String csvData = ListToCsvConverter().convert(records);
    // final String directory = (await getApplicationSupportDirectory()).path;
    String minValueXYZG = getMinValueXYZG();
    String maxValueXYZG = getMaxValueXYZG();
    String varianceValueXYZG = getVarianceXYZG();
    List<double> averageXYZG = getAverageXYZG();

    String average = ';Average Value;' +
        averageXYZG.elementAt(0).toStringAsFixed(5) +
        ';' +
        averageXYZG.elementAt(1).toStringAsFixed(5) +
        ';' +
        averageXYZG.elementAt(2).toStringAsFixed(5) +
        ';' +
        averageXYZG.elementAt(3).toStringAsFixed(5) +
        '\n';

    const String directory =
        '/storage/emulated/0/Android/data/com.example.beschleunigungssensor/files';

    final path = "$directory/csv-${DateTime.now().millisecondsSinceEpoch}.csv";
    print(path);
    final File file = File(path);
    await file.writeAsString(
        records + minValueXYZG + maxValueXYZG + average + varianceValueXYZG);
    // ShareExtend.share(file.path, "file");
  }
}
