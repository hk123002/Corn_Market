// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:math';

import 'package:banner_carousel/banner_carousel.dart';
import 'package:boiler_time/constants/routes.dart';
import 'package:boiler_time/services/auth/auth_service.dart';
import 'package:boiler_time/views/boiler/myPost.dart';

import 'package:boiler_time/views/home/about/academic_schedule.dart';
import 'package:boiler_time/views/home/about/bus_schedule.dart';
import 'package:boiler_time/views/home/about/dining_menu.dart';
import 'package:boiler_time/views/home/about/library_schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flat_banners/flat_banners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'dart:developer' as devtools show log;

import '../../enums/menu_action.dart';
import '../auth/login_view.dart';
import '../boiler/boiler.dart';
import '../community/post.dart';
import '../main_view.dart';
import '../community/post.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeViewState();
}

class _homeViewState extends State<home> {
  List<String> classList = [];
  List<String> hourList = [];

  // List<String> hotPostTitle = ["hi", "hi1", "hi2", "hi3"];
  // List<String> hotPostContent = [];
  // List<String> hotPostID = [];

  String? name;
  var date;
  var dayHint;

  List<String> welcomeMessage = [
    "Welcome to Boiler Time",
  ];
  // void _getTodayPost() async {
  //   var usercollection = FirebaseFirestore.instance.collection('hotPost');

  //   var docSnapshot =
  //       await usercollection.doc(FirebaseAuth.instance.currentUser?.uid).get();

  //   if (docSnapshot.exists) {
  //     Map<String, dynamic> data = docSnapshot.data()!;

  //     // You can then retrieve the value from the Map like this:

  //     setState(() {
  //       name = data['name'];
  //     });
  //     devtools.log(name.toString());
  //   }

  //   //fetch data for calendar
  //   setState(() {
  //     date = DateTime.now();
  //   });
  // }

  void _getUserData() async {
    var usercollection = FirebaseFirestore.instance.collection('users');

    var docSnapshot =
        await usercollection.doc(FirebaseAuth.instance.currentUser?.uid).get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:

      setState(() {
        name = data['name'];
      });
      devtools.log(name.toString());
    }

    //fetch data for calendar
    setState(() {
      date = DateTime.now();
    });
    devtools.log(DateFormat('EEEE').format(date));
    if (DateFormat('EEEE').format(date) == "Monday") {
      dayHint = 0;
    } else if (DateFormat('EEEE').format(date) == "Tuesday") {
      dayHint = 1;
    } else if (DateFormat('EEEE').format(date) == "Wednesday") {
      dayHint = 2;
    } else if (DateFormat('EEEE').format(date) == "Thursday") {
      dayHint = 3;
    } else if (DateFormat('EEEE').format(date) == "Friday") {
      dayHint = 4;
    }
    {
      dayHint = -1;
    }
    var calenarcollection = FirebaseFirestore.instance.collection('calendar');

    docSnapshot = await calenarcollection
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      var schedule = data['schedule'];
      for (String item in schedule) {
        var split = item.split(":");
        int day = int.parse(split[1]);
        String schedule = split[0];
        int hour = int.parse(split[2]);
        int minute = int.parse(split[3]);
        int duration = int.parse(split[4]);
        if (day == dayHint) {
          String startTimeHint;
          int modifiedStartHour = 0;

          if (hour > 12) {
            modifiedStartHour = hour - 12;
            devtools.log(hour.toString());
            startTimeHint = modifiedStartHour.toString() + ":";
            if (minute.toString() == "0") {
              startTimeHint += "0" + "0";
            } else {
              startTimeHint += minute.toString();
            }
          } else {
            startTimeHint = hour.toString() + ":";

            if (minute.toString() == "0") {
              startTimeHint += "0" + "0";
            } else {
              startTimeHint += minute.toString();
            }
          }
          int endTimeHintInt = hour * 60 + minute + duration;

          String endTimeHint;
          if (((endTimeHintInt / 60).floor()) > 12) {
            endTimeHint = ((endTimeHintInt / 60).floor() - 12).toString() + ":";
            if ((endTimeHintInt % 60).toString() == "0") {
              endTimeHint += "0" + "0";
            } else {
              endTimeHint += (endTimeHintInt % 60).toString();
            }
          } else {
            endTimeHint = ((endTimeHintInt / 60).floor()).toString() + ":";

            if ((endTimeHintInt % 60).toString() == "0") {
              endTimeHint += "0" + "0";
            } else {
              endTimeHint += (endTimeHintInt % 60).toString();
            }
          }

          setState(() {
            classList.add(schedule);
            hourList.add(startTimeHint.toString() + " - " + endTimeHint);
          });
        }
      }
    }
  }

  late final _random;
  @override
  void initState() {
    super.initState();
    _random = new Random();

    _getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // backgroundColor: Color.fromARGB(255, 46, 46, 46),
          elevation: 0.0,

          toolbarHeight: 40,
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Image(
                image: AssetImage('assets/bt_logo_white.png'),
              ),
            ),
          ),
          // backgroundColor: Color(0x44000000),
          // elevation: 0,
          // title: Text(
          //   "Boiler Time",
          //   // style: TextStyle(fontSize: 15),
          // ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(5),
            ),
          ),

          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return LoginView();
                          },
                        ),
                        (route) => false,
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text("Log out"),
                  )
                ];
              },
            )
          ],
        ),
        body: ListView(
          children: [
            Wrap(children: [
              //banner
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // const SizedBox(height: 20),

                        /// Carousel FullScreen
                        BannerCarousel.fullScreen(
                          activeColor: Color.fromARGB(255, 15, 223, 207),

                          banners: BannerImages.listBanners,
                          height: 80,
                          animation: false,
                          initialPage: 0,
                          indicatorBottom: false,
                          // OR pageController: PageController(initialPage: 6),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          welcomeMessage[
                              _random.nextInt(welcomeMessage.length)],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          name.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 189, 189, 189),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),

              // card when there's no class
              Visibility(
                visible: classList.isEmpty,
                child: Center(
                  child: Container(
                    width: 330,
                    child: Card(
                      // color: Color.fromARGB(255, 71, 71, 71),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Color.fromARGB(
                                255, 43, 43, 43)), // color for borderline
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Text(
                                  "\u{1F4CB}  Today's class",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                                Text(
                                  "You have no class today! \u{1F389}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(children: [
                              SizedBox(
                                width: 35,
                              ),
                            ]),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //card when there's class today
              Visibility(
                visible: classList.isNotEmpty,
                child: SizedBox(
                  height: 170, // card height
                  child: PageView.builder(
                    itemCount: classList.length,
                    controller: PageController(viewportFraction: 0.85),
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemBuilder: (_, i) {
                      return Transform.scale(
                        scale: i == _index ? 1 : 0.9,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Color.fromARGB(255, 43, 43, 43)),

                            /// color for borderline
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "\u{1F4CB}  Today's class",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                    ),
                                    Text(
                                      DateFormat('EEEE')
                                          .format(date)
                                          .toLowerCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                    ),
                                    Text(
                                      classList[i],
                                      style: TextStyle(
                                        fontSize: 15,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(children: [
                                  SizedBox(
                                    width: 35,
                                  ),
                                  Text(
                                    hourList[i],
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(
                height: 180,
              ),
              //row for button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // button for my post
                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "mypost",
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: MyPost(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Center(
                          child: Icon(
                            size: 20,
                            Icons.my_library_add,
                            color: Color.fromARGB(180, 51, 255, 51),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "my post",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  //button for bus schedule

                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "bus",
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: BusSchedule(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Center(
                          child: Icon(
                            size: 20,
                            Icons.bus_alert_outlined,
                            color: Color.fromARGB(180, 255, 255, 0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "bus schedule",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  //button for library

                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "library",
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: LibraryTime(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Center(
                          child: Icon(
                            size: 20,
                            Icons.school,
                            color: Color.fromARGB(180, 15, 223, 207),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "library",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  //button for menu
                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "menu",
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: DiningMenu(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Center(
                          child: Icon(
                            size: 20,
                            Icons.dining,
                            color: Color.fromARGB(180, 223, 15, 135),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "menu",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  //button for academic schedule
                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "holiday",
                        elevation: 0,
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AcademicSchedule(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Center(
                          child: Icon(
                            size: 20,
                            Icons.schedule,
                            color: Color.fromARGB(180, 103, 15, 223),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "holidays",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 80,
              ),

              //most viewed

              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 40, 40, 40),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(
                          5.0) //                 <--- border radius here
                      ),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 3,
                    ),
                    Row(children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 13,
                            ),
                            Text(
                              "\u{2714}    Most viewed",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            primary: Colors.red.withOpacity(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                                side: BorderSide(
                                    color: Colors.red.withOpacity(0))),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return MainView(
                                    index: 1,
                                  );
                                },
                              ),
                              (_) => false,
                            );
                          },
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text(
                              //   'see more',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //   ),
                              // ), // <-- Text

                              Icon(
                                // <-- Icon
                                Icons.navigate_next_outlined,
                                color: Colors.white,

                                size: 24.0,
                                // color: Color.fromARGB(255, 193, 155, 200),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ]),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exam',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Internship',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Freshman',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate My Professor',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),

              //hot pots

              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 43, 43, 43)),
                  borderRadius: BorderRadius.all(Radius.circular(
                          5.0) //                 <--- border radius here
                      ),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 3,
                    ),
                    Row(children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 13,
                            ),
                            // Icon(
                            //   Icons.view_agenda,
                            //   size: 15,
                            // ),
                            // SizedBox(
                            //   width: 10,
                            // ),
                            Text(
                              "\u{1F525}   Hot post",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(children: [
                        // SizedBox(
                        //   width: 110,
                        // ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            primary: Colors.red.withOpacity(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                                side: BorderSide(
                                    color: Colors.red.withOpacity(0))),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return MainView(
                                    index: 1,
                                  );
                                },
                              ),
                              (_) => false,
                            );
                          },
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text(
                              //   'see more',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //   ),
                              // ), // <-- Text

                              Icon(
                                // <-- Icon
                                Icons.navigate_next_outlined,
                                color: Colors.white,

                                size: 24.0,
                                // color: Color.fromARGB(255, 193, 155, 200),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ]),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exam',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Internship',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Freshman',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TextButton(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate My Professor',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Post(),
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          )
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class BannerImages {
  static const String banner1 =
      "https://static.semrush.com/blog/uploads/media/c2/52/c2521160ece538cfdbfb218788caf9ea/mDWwN6GNJt_lE7-pGth6IXsdxvqVmPeaGHw-F_dHXiKN8p3FGgIVicwvbdShvLirF5slOvKUkxpfMkaVdne2a6do6vHWdLZSfy1i-lGmfZL9-FyS162K6P-QGbZbk1vKp9YjNSil%3Ds0.png";
  static const String banner2 =
      "https://www.kukinews.com/data/kuk/cache/2022/06/14/kuk202206140165.680x.0.jpg";
  static const String banner3 =
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";

  static const String banner4 =
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";

  static List<BannerModel> listBanners = [
    BannerModel(imagePath: banner1, id: "1"),
    BannerModel(imagePath: banner2, id: "2"),
    BannerModel(imagePath: banner3, id: "3"),
    BannerModel(imagePath: banner4, id: "4"),
  ];
}

class BannerClass {
  static const String banner1 =
      "https://static.semrush.com/blog/uploads/media/c2/52/c2521160ece538cfdbfb218788caf9ea/mDWwN6GNJt_lE7-pGth6IXsdxvqVmPeaGHw-F_dHXiKN8p3FGgIVicwvbdShvLirF5slOvKUkxpfMkaVdne2a6do6vHWdLZSfy1i-lGmfZL9-FyS162K6P-QGbZbk1vKp9YjNSil%3Ds0.png";
  static const String banner2 =
      "https://www.kukinews.com/data/kuk/cache/2022/06/14/kuk202206140165.680x.0.jpg";
  static const String banner3 =
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";

  static const String banner4 =
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";

  static List<BannerModel> listBanners = [
    BannerModel(imagePath: banner1, id: "1"),
    BannerModel(imagePath: banner2, id: "2"),
    BannerModel(imagePath: banner3, id: "3"),
    BannerModel(imagePath: banner4, id: "4"),
  ];
}
