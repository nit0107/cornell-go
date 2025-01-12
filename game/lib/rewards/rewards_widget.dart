import 'package:flutter/material.dart';
import 'package:game/model/event_model.dart';
import 'package:game/model/reward_model.dart';
import 'package:game/model/user_model.dart';
import 'package:game/widget/back_btn.dart';
import 'package:game/widget/rewards_cell.dart';
import 'package:provider/provider.dart';

class RewardsWidget extends StatefulWidget {
  RewardsWidget({Key? key}) : super(key: key);

  @override
  _RewardsWidgetState createState() => _RewardsWidgetState();
}

class _RewardsWidgetState extends State<RewardsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        setState(() {
          loaded = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: backBtn(scaffoldKey, context, "Rewards"),
      backgroundColor: Color.fromARGB(255, 43, 47, 50),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: AnimatedOpacity(
          opacity: loaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Consumer3<RewardModel, UserModel, EventModel>(
                      builder:
                          (context, rewardModel, userModel, eventModel, child) {
                        return ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: rewardModel.rewardByEventId.values
                              .where((element) =>
                                  userModel.userData?.rewardIds
                                      .contains(element.id) ??
                                  false)
                              .map(
                            (e) {
                              final ev = eventModel.getEventById(e.eventId);
                              return AnimatedRewardCell(
                                  e.description,
                                  "From " + (ev?.name ?? "an Event"),
                                  e.redeemInfo);
                            },
                          ).toList(),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
