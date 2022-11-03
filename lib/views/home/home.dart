// ignore_for_file: prefer_const_constructors

import 'package:banner_carousel/banner_carousel.dart';
import 'package:boiler_time/constants/routes.dart';
import 'package:boiler_time/services/auth/auth_service.dart';
import 'package:boiler_time/views/home/about/academic_schedule.dart';
import 'package:boiler_time/views/home/about/bus_schedule.dart';
import 'package:boiler_time/views/home/about/dining_menu.dart';
import 'package:boiler_time/views/home/about/library_schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flat_banners/flat_banners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../../enums/menu_action.dart';
import '../community/exam.dart';
import '../main_view.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeViewState();
}

class _homeViewState extends State<home> {
  List<String> classList = [];
  List<String> hourList = [];

  String? name;
  var date;
  var dayHint;

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
    } else {
      dayHint = 4;
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

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 40,
        centerTitle: true,
        // elevation: 0,
        // backgroundColor: Color(0x44000000),
        // title: const Text(
        //   "Boiler Time",
        //   style: TextStyle(fontSize: 15),
        // ),

        // leading: Icon(Icons.menu),
        // title: Text(
        //   "Purdue Univ",
        //   style: TextStyle(fontStyle: FontStyle.italic),
        // ),
      ),
      body: ListView(
        children: [
          Wrap(children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Hello World !",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    name.toString(),
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150, // card height
              child: PageView.builder(
                itemCount: classList.length,
                controller: PageController(viewportFraction: 0.85),
                onPageChanged: (int index) => setState(() => _index = index),
                itemBuilder: (_, i) {
                  return Transform.scale(
                    scale: i == _index ? 1 : 0.9,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Visibility(
                                // visible: _index == 0,
                                child: Row(
                              children: [
                                Icon(Icons.schedule),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Today's class",
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                                Text(
                                  DateFormat('EEEE').format(date),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                                Text(
                                  classList[i],
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      // fontWeight: FontWeight.bold,
                                    ),
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
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.bus_alert),
                      iconSize: 30.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BusSchedule()),
                        );
                      },
                    ),
                    Text(
                      "Bus Schedule",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.school),
                      iconSize: 30.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LibraryTime()),
                        );
                      },
                    ),
                    Text(
                      "Library Scheudle",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.dining),
                      iconSize: 30.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DiningMenu()),
                        );
                      },
                    ),
                    Text(
                      "Dining Menu",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.schedule),
                      iconSize: 30.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AcademicSchedule()),
                        );
                      },
                    ),
                    Text(
                      "Academic Scheudle",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(height: 20),

                /// Carousel FullScreen
                BannerCarousel.fullScreen(
                  banners: BannerImages.listBanners,
                  height: 130,
                  animation: false,
                  initialPage: 1,
                  indicatorBottom: false,
                  // OR pageController: PageController(initialPage: 6),
                ),
              ],
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 30.0),
                child: FlatBanners(
                  imageWidth: 50,
                  gradientColors: [
                    Color.fromARGB(255, 2, 3, 2).withOpacity(0.9),
                    Color.fromARGB(255, 65, 69, 42).withOpacity(0.7),
                  ],
                  title: 'Gen.G Esports',
                  subtitle: 'CHOOOOVY',
                  btnText: 'find out more',
                  image: 'geng.png',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(
                    // color: Color.fromARGB(255, 131, 124, 132),
                    ),
                borderRadius: BorderRadius.all(Radius.circular(
                        5.0) //                 <--- border radius here
                    ),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 25,
                        ),
                        Text(
                          "Most Viewed",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 0,
                    child: TextButton(
                      child: ListTile(
                        title: Text(
                          'Exam',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Exam()),
                        )
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      child: ListTile(
                        title: Text(
                          'Exam',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => {},
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      child: ListTile(
                        title: Text(
                          'Exam',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => {},
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      child: ListTile(
                        title: Text(
                          'Exam',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => {},
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      child: ListTile(
                        title: Text(
                          'Exam',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => {},
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class BannerImages {
  static const String banner1 =
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";
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
      "https://file.thisisgame.com/upload/nboard/news/2022/02/11/20220211104008_4939w.jpg";
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
