import 'package:flutter/material.dart';

import '../../controllers/authentication_controller.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/my_print.dart';
import '../../utils/styles.dart';
import '../common/components/MyCupertinoAlertDialogWidget.dart';

class HomeScreenTemp extends StatefulWidget {
  const HomeScreenTemp({Key? key}) : super(key: key);

  @override
  State<HomeScreenTemp> createState() => _HomeScreenTempState();
}

class _HomeScreenTempState extends State<HomeScreenTemp> {
  Future<void> logout() async {
    MyPrint.printOnConsole("logout");
    bool? isLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyCupertinoAlertDialogWidget(
          title: "Logout",
          description: "Are you sure want to logout?",
          negativeCallback: () {
            Navigator.pop(context, false);
          },
          positiviCallback: () {
            Navigator.pop(context, true);
          },
        );
      },
    );

    if(isLogout != null && isLogout) {
      await AuthenticationController().logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Home Screen"),
              SizedBox(height: 40),
              singleOption1(
                iconData: Icons.logout,
                option: "Logout",
                ontap: () async {
                  logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget singleOption1({required IconData iconData, required String option, Function? ontap}) {
    return InkWell(
      onTap: ()async {
        if(ontap != null) ontap();
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: MySize.size10!),
        decoration: BoxDecoration(
          color: Styles.bottomAppbarColor,
          borderRadius: BorderRadius.circular(MySize.size10!),
        ),
        padding: EdgeInsets.symmetric(vertical: MySize.size16!, horizontal: MySize.size10!),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                iconData,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: MySize.size16!),
                child: Text(option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              child: Icon(Icons.arrow_forward_ios_rounded,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
