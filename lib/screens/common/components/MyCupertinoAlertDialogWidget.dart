import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_parking/utils/styles.dart';

class MyCupertinoAlertDialogWidget extends StatelessWidget {
  String title, description;
  String? positiveText, neagtiveText;
  Function? positiviCallback, negativeCallback;
  Color? posotivetextColor;

  MyCupertinoAlertDialogWidget({
    required this.title, required this.description,
    this.positiveText,
    this.positiviCallback,
    this.posotivetextColor,
    this.neagtiveText,
    this.negativeCallback,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Text(
          description,
          style: const TextStyle(
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(
            neagtiveText ?? "Cancel",
            style: const TextStyle(
              color: Styles.primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3),
          ),
          onPressed: () {
            if(negativeCallback != null) {
              negativeCallback!();
            }
            else {
              Navigator.pop(context);
            }
          },
        ),
        CupertinoDialogAction(
          child: Text(
            positiveText ?? "Ok",
            style: TextStyle(
              color: posotivetextColor != null ? posotivetextColor : Styles.primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3),),
          onPressed: () {
            if(positiviCallback != null) {
              positiviCallback!();
            }
          },
        ),
      ],
    );
  }
}