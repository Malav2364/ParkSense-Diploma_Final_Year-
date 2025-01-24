import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_parking/utils/my_print.dart';

class ConnectionProvider extends ChangeNotifier {
  bool isInternet = true;
  StreamSubscription<ConnectivityResult>? subscription;

  ConnectionProvider() {
    try {
      MyPrint.printOnConsole("Connection Subscription Started");
      subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        isInternet = result == ConnectivityResult.none ? false : true;
        MyPrint.printOnConsole("Connection Status Changed:$isInternet");
        notifyListeners();
      });
    }
    catch (E) {
      MyPrint.printOnConsole("Error in Connectivity Subscription:  $E");
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
  }
}