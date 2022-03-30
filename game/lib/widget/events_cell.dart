import 'package:flutter/material.dart';

Widget eventsCell(context, place, date, description, completed, current, time,
    reward, rewardNum, people, imgpath) {
  var placeStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white);
  var timeStyle = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 20, color: Colors.white);
  var dateStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 15,
      color: Colors.white,
      fontStyle: FontStyle.italic);
  var descriptionStyle = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 10, color: Colors.white);
  var rewardStyle = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 15, color: Colors.white);
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        RotatedBox(
          quarterTurns: 3,
          child: Container(
              child: Text(
            date,
            style: dateStyle,
          )),
        ),
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                  border: current
                      ? Border.all(color: Colors.greenAccent, width: 2.0)
                      : null,
                  image: DecorationImage(
                      image: AssetImage(imgpath),
                      fit: BoxFit.cover,
                      opacity: .5)),
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Row(children: [
                    Container(
                        child: Text(
                      place,
                      style: placeStyle,
                      textAlign: TextAlign.left,
                    )),
                    Expanded(
                      child: Container(
                          alignment: Alignment.topRight,
                          child: (people == -1 && !completed
                              ? Container()
                              : (completed
                                  ? Icon(Icons.star,
                                      color: Colors.yellow, size: 25)
                                  : Icon(Icons.people,
                                      color: Colors.white, size: 25)))),
                    ),
                    Container(
                        child: Text(
                      people == -1 || completed ? "" : " ${people}",
                      style: placeStyle,
                    ))
                  ]),
                  Expanded(
                      child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        width: 150,
                        alignment: Alignment.topLeft,
                        child: Text(
                          description,
                          style: descriptionStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  )),
                  Row(children: [
                    Container(
                        child: Text(
                      time == -1 ? "Perpetual Event" : "${time} Days Left",
                      style: timeStyle,
                    )),
                    Expanded(
                      child: Container(
                          child: Column(children: [
                        Container(
                            alignment: Alignment.bottomRight,
                            child: Text(reward, style: rewardStyle)),
                        Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                                rewardNum == 0
                                    ? ""
                                    : (rewardNum == -1
                                        ? "∞ Rewards"
                                        : "${rewardNum} Rewards Left"),
                                style: rewardStyle))
                      ])),
                    )
                  ]),
                ]),
              )),
        )
      ]));
}