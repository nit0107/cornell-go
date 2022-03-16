import 'package:flutter/material.dart';

import 'package:game/widget/back_btn.dart';
import 'package:game/widget/challenge_cell.dart';

class ChallegesWidget extends StatefulWidget {
  ChallegesWidget({Key? key}) : super(key: key);

  @override
  _ChallegesWidgetState createState() => _ChallegesWidgetState();
}

class _ChallegesWidgetState extends State<ChallegesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: backBtn(scaffoldKey, context, "Previouly visited"),
      backgroundColor: Color.fromARGB(255, 43, 47, 50),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 25,
                        color: Colors.white,
                      ),
                      Expanded(
                          child: TextField(
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  border: UnderlineInputBorder(),
                                  hintText: 'search...',
                                  hintStyle: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  fillColor: Colors.white)))
                    ],
                  ),
                )),
                Expanded(
                    child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                      challengeCell(context, "Sage Chapel", "4/19/2021", 5,
                          "assets/images/38582.jpg", false, false, false),
                      challengeCell(context, "Sage Chapel", "4/19/2021", 5,
                          "assets/images/38582.jpg", true, true, false),
                      challengeCell(context, "Sage Chapel", "4/19/2021", 5,
                          "assets/images/38582.jpg", false, true, false),
                      challengeCell(context, "Sage Chapel", "4/19/2021", 5,
                          "assets/images/38582.jpg", false, true, true),
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
