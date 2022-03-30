import 'package:flutter/material.dart';

import 'package:game/widget/back_btn.dart';
import 'package:game/widget/events_cell.dart';

class EventsWidget extends StatefulWidget {
  EventsWidget({Key? key}) : super(key: key);

  @override
  _EventsWidgetState createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: backBtn(scaffoldKey, context, "Events"),
      backgroundColor: Color.fromARGB(255, 43, 47, 50),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Expanded(
                    child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                      eventsCell(
                          context,
                          "Central Campus Event",
                          "4/19/2021",
                          "Learn more about this commonly visited area through the central campus event",
                          true,
                          false,
                          -1,
                          "Completion certificate",
                          -1,
                          -1,
                          "assets/images/38582.jpg"),
                      eventsCell(
                          context,
                          "Central Campus Event",
                          "4/19/2021",
                          "Learn more about this commonly visited area through the central campus event",
                          false,
                          true,
                          3,
                          "3\$ Cornell Store",
                          3,
                          -1,
                          "assets/images/38582.jpg"),
                      eventsCell(
                          context,
                          "Central Campus Event",
                          "4/19/2021",
                          "Learn more about this commonly visited area through the central campus event",
                          false,
                          false,
                          -1,
                          "",
                          0,
                          3,
                          "assets/images/38582.jpg"),
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}