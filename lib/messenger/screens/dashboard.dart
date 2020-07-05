import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:garage/messenger/enum/user_state.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';
import 'package:garage/messenger/screens/pageViews/chat_list/chat_list_screen.dart';
import 'package:garage/messenger/screens/pageViews/contact_list/contact_list_screen.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/utills/utilities.dart';
import 'package:garage/messenger/widgets/mainAppBar.dart';
import 'package:garage/models/user.dart';
import 'package:provider/provider.dart';

import 'callScreens/pickup/pickup_layout.dart';

class Dashboard extends StatelessWidget {
  final User currentuserMain;

  const Dashboard({Key key, this.currentuserMain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyDashboard(
        title: 'Hi there!',
        currentUserMain: currentuserMain,
      ),
    );
  }
}

class MyDashboard extends StatefulWidget {
  final User currentUserMain;
  MyDashboard({Key key, this.currentUserMain, this.title}) : super(key: key);

  final String title;
  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;

  UserProvider userProvider;

  String currentUserId;
  String initials;

  final AuthenticationMethods _authenticationMethods = AuthenticationMethods();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authenticationMethods.setUserState(
        userId: userProvider.getUser.uid,
        userState: UserState.Online,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();

    setState(() {
      currentUserId = widget.currentUserMain.id;
      if (widget.currentUserMain.username.isNotEmpty) {
        initials = Utils.getInitials(widget.currentUserMain.username);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authenticationMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authenticationMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authenticationMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authenticationMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    double _labelFontSize = 10;

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.whiteColor,
        appBar: PreferredSize(
          child: MainAppBar(
            title: widget.title,
            back: "dashboard",
            initials: initials,
            currentMainUser: widget.currentUserMain,
          ),
          preferredSize: Size.fromHeight(media.height),
        ),
        body: PageView(
          children: <Widget>[
            Container(
              child: ChatListScreen(),
            ),
            // Container(child: GroupListScreen()),

            Container(child: ContactListScreen()),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: UniversalVariables.bottomBarNavigation,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  backgroundColor: _page == 0
                      ? UniversalVariables.whiteColor
                      : UniversalVariables.appBar,
                  icon: Icon(
                    Icons.chat,
                    color: UniversalVariables.whiteColor,
                    size: _page == 0 ? 32.0 : 18.0,
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: 0.0, height: 0.0),
                  ),
                ),
                BottomNavigationBarItem(
                  backgroundColor: _page == 1
                      ? UniversalVariables.whiteColor
                      : UniversalVariables.appBar,
                  icon: Icon(
                    Icons.call,
                    color: UniversalVariables.whiteColor,
                    size: _page == 1 ? 32.0 : 18.0,
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: 0.0, height: 0.0),
                  ),
                ),
                BottomNavigationBarItem(
                  backgroundColor: _page == 2
                      ? UniversalVariables.whiteColor
                      : UniversalVariables.appBar,
                  icon: Icon(
                    Icons.contact_phone,
                    color: UniversalVariables.whiteColor,
                    size: _page == 2 ? 32.0 : 16.0,
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: 0.0, height: 0.0),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }
}
