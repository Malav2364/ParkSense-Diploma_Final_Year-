import 'package:flutter/material.dart';
import 'package:smart_parking/screens/home_screen/main_page.dart';

import '../../utils/SizeConfig.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';

class LocationSelectionScreen extends StatefulWidget {
  static const String routeName = "/LocationSelectionScreen";

  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Select Location", backbtnVisible: false, color: Colors.white,),
              Expanded(
                child: getMainBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMainBody() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MySize.size10!, vertical: MySize.size5!),
        child: Column(
           mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getLocationButton(name: "Inorbit Mall"),
            getLocationButton(name: "Vadodara Central"),
            getLocationButton(name: "Eve Mall"),
            getLocationButton(name: "Vadodara Railway Station"),
          ],
        ),
      ),
    );
  }

  Widget getLocationButton({required String name}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: InkWell(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false,);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Styles.primaryColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
