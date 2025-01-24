import 'package:flutter/material.dart';
import 'package:smart_parking/controllers/providers/user_provider.dart';
import 'package:smart_parking/screens/home_screen/home_screen.dart';
import 'package:smart_parking/screens/home_screen/user_profile_screen.dart';
import 'package:smart_parking/utils/SizeConfig.dart';
import 'package:smart_parking/utils/my_print.dart';
import 'package:smart_parking/utils/styles.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const String routeName = "/MainPage";
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late TabController _tabController;

  Widget? postListWidget, profileWidget;

  bool isNotificationSet=true;

  _handleTabSelection() {
    FocusScope.of(context).requestFocus(new FocusNode());

    MyPrint.printOnConsole("_handleTabSelection called");
    UserProvider dataProvider = Provider.of<UserProvider>(context, listen: false);
    _currentIndex = _tabController.index;
    dataProvider.selectedScreen = _tabController.index;

    //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);
  }

  _handleTabSelectionInAnimation() {
    final double? aniValue = _tabController.animation?.value;
    //MyPrint.printOnConsole("Animation Value:$aniValue");
    //MyPrint.printOnConsole("Current Value:$_currentIndex");

    if(aniValue != null) {
      double diff = aniValue - _currentIndex;

      //MyPrint.printOnConsole("Current Before:$_currentIndex");
      if (aniValue - _currentIndex > 0.5) _currentIndex++;
      else if (aniValue - _currentIndex < -0.5) _currentIndex--;
      //MyPrint.printOnConsole("Current After:$_currentIndex");

      //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);

      //For Direct Tap
      if(diff != 1 && diff != -1 && diff != 2 && diff != -2 && diff != 3 && diff != -3) {
        setState(() {});
      }
    }
  }

  onTapped(value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  initState() {
    super.initState();
    MyPrint.printOnConsole("Main Page INIT Called");

    _tabController = TabController(length: 2, vsync: this,initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _tabController.animation!.addListener(_handleTabSelectionInAnimation);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setScreen(0);
    });
  }

  dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    _tabController.index = userProvider.selectedScreen;

    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: getBottomBar(userProvider),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              getHome(),
              getUserProfile()
            ],
          ),
        ),
      ),
    );
  }

  Widget getHome() {
    postListWidget ??= const HomeScreen();

    return postListWidget!;
  }

  Widget getUserProfile() {
    profileWidget ??= const UserProfileScreen();

    return profileWidget!;
  }

  Widget getBottomBar(UserProvider userProvider) {
    return BottomAppBar(
      color: Colors.transparent.withOpacity(0),
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      notchMargin: 5,
      child: Container(
        height: MySize.size60,
        decoration: const BoxDecoration(
          color: Styles.bottomAppbarColor,
        ),
        child: TabBar(
          onTap: (int val) {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          controller: _tabController,
          indicator: const BoxDecoration(),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Styles.primaryColor,
          labelColor: Styles.primaryColor,
          unselectedLabelColor: Styles.onBackground.withOpacity(0.4),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: MySize.getScaledSizeHeight(11),
          ),
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home, size: MySize.size28,),
              iconMargin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.person, size: MySize.size28,),
              iconMargin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              text: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget getBottomBarButton({required String text, required int index, required IconData iconData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData, size: MySize.size20, color: Styles.primaryColor,),
        index != _currentIndex
            ? Text(
          text,
          style: TextStyle(
            fontSize: MySize.size10,
            fontWeight: FontWeight.w700,
            color: Styles.primaryColor,
          ),
        )
            : const SizedBox.shrink(),
      ],
    );
  }
}
