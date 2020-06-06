import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:enviro_sensors/enviro_sensors.dart';
import './data/barometer_provider.dart';
import './data/flicker_provider.dart';

import './widgets/elevation_streambuilder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromRGBO(246, 246, 246, 1),
        statusBarColor: Color.fromRGBO(246, 246, 246, 1)));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: BarometerProvider()),
        ChangeNotifierProvider.value(value: FlickerProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ElevaTorr',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'ElevaTorr'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<BarometerEvent> _tryStream;
  Stream<String> _flickerStream;
  double pZeroMock = 1013.25;
  bool hasPlatformException = false;
  bool hasOtherError = false;

  _PatternVibrate() {
    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 500),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );
    HapticFeedback.mediumImpact();
  }

  @override
  void initState() {
    super.initState();
    try {
      _tryStream = barometerEvents.asBroadcastStream();
    } on PlatformException {
      hasPlatformException = true;
    } catch (error) {
      hasOtherError = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBarometerDisplay(
      Stream<BarometerEvent> stream, double pZero, BarometerProvider provider) {
    if (hasPlatformException) {
      return Text(
        'Platform Exception!',
        style: Theme.of(context).textTheme.display1,
      );
    } else if (hasOtherError) {
      return Text(
        'Unexpected Error!',
        style: Theme.of(context).textTheme.display1,
      );
    } else {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Image(
              height: 220,
              width: 220,
              image: AssetImage('assets/elevator_new.jpg'),
              // TODO: edit image to center along the horizontal line
            ),
            ElevationDifferenceStreamBuilder(
              pressureStream: stream,
              pZero: provider.previousReading ?? pZero,
              flickerStream: _flickerStream,
            ),
            Builder(
                builder: (BuildContext ctx) => RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                              color: Color.fromRGBO(246, 246, 246, 1.0),
                              fontSize: 20),
                        ),
                      ),
                      color: Color.fromRGBO(96, 99, 240, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0)),
                      onPressed: () {
                        try {
                          provider.resetPZeroValue();
                          HapticFeedback.vibrate();
                        } catch (e) {
                          final snackBar = SnackBar(
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {
                                Scaffold.of(ctx).hideCurrentSnackBar();
                              },
                            ),
                            backgroundColor: Theme.of(ctx).errorColor,
                            content: Row(
                              children: <Widget>[
                                Icon(Icons.error),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Something went wrong!"),
                              ],
                            ),
                          );
                          Scaffold.of(ctx).showSnackBar(snackBar);
                        }
                      },
                    )),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barometerProvider =
        Provider.of<BarometerProvider>(context, listen: true);
    FlickerProvider flickProvider =
        Provider.of<FlickerProvider>(context, listen: false);
    _flickerStream = flickProvider.directionStream().asBroadcastStream();
    return Scaffold(
      // appBar: AppBar(
      //   brightness: Brightness.light,
      // ),
      backgroundColor: Color.fromRGBO(246, 246, 246, 1.0),
      body: Center(
        child: Column(
          children: <Widget>[
            _buildBarometerDisplay(_tryStream, pZeroMock, barometerProvider),
          ],
        ),
      ),
    );
  }

  int transform(int value) {
    return value;
  }

  bool condition(int value) {
    return value < 99;
  }
}


