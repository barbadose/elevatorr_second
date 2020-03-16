import 'package:flutter/material.dart';

class FlickerProvider with ChangeNotifier {
  double changingElevationDiff = 0.0;
  double slowChangingElevationDiff = 0.0;

  Stream<String> directionStream() async* {
    while (true) {
      await Future.delayed((const Duration(seconds: 1)), () {});
      if (changingElevationDiff > slowChangingElevationDiff) {
        // print('ascending');
        yield "Ascending";
      }
      else if (changingElevationDiff < slowChangingElevationDiff) {
        // print('descending');
        yield "Descending";
      } else {
        // print('equilibrium');
        yield "Equilibrium";
      }
      // print("changing...: $changingElevationDiff");
      // print("slowChanging/...: $slowChangingElevationDiff");

      slowChangingElevationDiff = changingElevationDiff;
    }
  }
}
