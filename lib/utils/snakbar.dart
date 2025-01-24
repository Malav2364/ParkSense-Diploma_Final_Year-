import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Snakbar{
  static Snakbar? _instance;

  factory Snakbar() {
    if(_instance == null) {
      _instance = Snakbar._();
    }
    return _instance!;
  }

  Snakbar._();

  void show_success_snakbar(BuildContext context, String success_message){
    showTopSnackBar(
      context,
      CustomSnackBar.success(
        message:success_message,
      ),
    );

  }
  void show_info_snakbar(BuildContext context, String info_message){
    showTopSnackBar(
      context,
      CustomSnackBar.info(
        message:info_message,
      ),
    );

  }
  void show_error_snakbar(BuildContext context, String error_message){
    showTopSnackBar(
      context,
      CustomSnackBar.error(
        message: error_message,
      ),
    );

  }
}