import 'package:flutter/material.dart';
import 'package:game/api/game_api.dart';
import 'package:game/model/challenge_model.dart';
import 'package:game/model/event_model.dart';
import 'package:game/model/group_model.dart';
import 'package:game/model/tracker_model.dart';
import 'package:game/model/user_model.dart';
import 'package:game/api/game_client_dto.dart';

import 'package:game/widget/back_btn.dart';
import 'package:game/widget/challenge_cell.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChallengesWidget extends StatefulWidget {
  ChallengesWidget({Key? key}) : super(key: key);

  @override
  _ChallengesWidgetState createState() => _ChallengesWidgetState();
}

class _ChallengesWidgetState extends State<ChallengesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: backBtn(scaffoldKey, context, "Challenges"),
      backgroundColor: Color.fromARGB(255, 43, 47, 50),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Expanded(child: Consumer5<EventModel, ChallengeModel,
                        TrackerModel, GroupModel, ApiClient>(
                    builder: (context, myEventModel, myChallengeModel,
                        myTrackerModel, groupModel, apiClient, child) {
                  if (groupModel.curEventId == null) {
                    return ListView();
                  } else {
                    List<Widget> challengeCells = [];
                    final eventId = groupModel.curEventId!;
                    final challenges =
                        myEventModel.getEventById(eventId)?.challengeIds;
                    if (challenges == null) {
                      return ListView();
                    } else {
                      for (String challengeId in challenges) {
                        final UpdateChallengeDataChallengeDto challenge =
                            myChallengeModel.getChallengeById(challengeId)!;
                        final UpdateEventDataEventDto event =
                            myEventModel.getEventById(eventId)!;
                        final UpdateEventTrackerDataEventTrackerDto tracker =
                            myTrackerModel.trackerByEventId(eventId)!;
                        challengeCells.add(GestureDetector(
                          onTap: () {
                            apiClient.serverApi
                                ?.setCurrentChallenge(challengeId);
                          },
                          child: challengeCell(
                              context,
                              challenge.name,
                              challenge.completionDate == null
                                  ? ""
                                  : format.format(challenge.completionDate!),
                              challenge.imageUrl,
                              tracker.curChallengeId == challengeId,
                              challenge.completionDate == null,
                              !event.skippingEnabled),
                        ));
                      }
                    }
                    return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: challengeCells);
                  }
                }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}