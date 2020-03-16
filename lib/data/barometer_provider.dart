import 'package:flutter/material.dart';

class BarometerProvider with ChangeNotifier {
  double _previousReading;
  double _pZero;

  
  double get pZero {
    if (_pZero == null) {
      _pZero = _previousReading;
    }
    return _pZero;
  }

  double get previousReading {
    return _previousReading;
  }
  
  void setPreviousReading(double value){
    _previousReading = value;
  }

  void resetPZeroValue(){
    _pZero = _previousReading;
    notifyListeners();
  }


}