import 'package:flutter/material.dart';
import 'package:game/api/game_api.dart';
import 'package:game/events/event_cell.dart';
import 'package:game/model/challenge_model.dart';
import 'package:game/model/event_model.dart';
import 'package:game/api/game_client_dto.dart';
import 'package:game/model/group_model.dart';
import 'package:game/model/tracker_model.dart';
import 'package:game/model/user_model.dart';
import 'package:game/utils/utility_functions.dart';
import 'package:game/widget/back_btn.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsWidget extends StatefulWidget {
  EventsWidget({Key? key}) : super(key: key);

  @override
  _EventsWidgetState createState() => _EventsWidgetState();
}

Future<void> _showConfirmation(
    BuildContext context, String eventId, String eventName) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Switch to Event'),
        content: Text('Are you sure you want to switch to $eventName?'),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Consumer<ApiClient>(
            builder: (context, apiClient, child) {
              return TextButton(
                child: Text('YES'),
                onPressed: () {
                  apiClient.serverApi?.setCurrentEvent(eventId);
                  Navigator.pop(context);
                },
              );
            },
          )
        ],
      );
    },
  );
}

class _EventsWidgetState extends State<EventsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
                  child: Consumer5<EventModel, GroupModel, TrackerModel,
                      ChallengeModel, UserModel>(
                    builder: (context, myEventModel, groupModel, trackerModel,
                        challengeModel, userModel, child) {
                      List<Widget> eventCells = [];
                      if (myEventModel.searchResults == null) {
                        myEventModel.searchEvents(
                            0,
                            1000,
                            [
                              EventRewardType.PERPETUAL,
                              EventRewardType.LIMITED_TIME_EVENT
                            ],
                            false,
                            false,
                            false);
                      }
                      final events = myEventModel.searchResults ?? [];
                      if (!events.any(
                          (element) => element.id == groupModel.curEventId)) {
                        final curEvent = myEventModel
                            .getEventById(groupModel.curEventId ?? "");
                        if (curEvent != null) events.add(curEvent);
                      }
                      for (EventDto event in events) {
                        final reward = event.rewardIds.length == 0
                            ? null
                            : event.rewardIds[0];
                        final tracker = trackerModel.trackerByEventId(event.id);
                        final format = DateFormat('yyyy-MM-dd');
                        final chal = event.challengeIds.length == 0
                            ? null
                            : challengeModel
                                .getChallengeById(event.challengeIds[0]);
                        final complete = tracker?.prevChallengeIds.length ==
                            event.challengeIds.length;
                        final timeTillExpire = DateTime.parse(event.endTime)
                            .difference(DateTime.now());
                        eventCells.add(
                          GestureDetector(
                            onTap: () {
                              if (groupModel.curEventId == event.id) return;
                              if (groupModel.members.any((element) =>
                                  element.id == userModel.userData?.id &&
                                  element.id == groupModel.group!.hostId)) {
                                _showConfirmation(
                                    context, event.id, event.name);
                              } else {
                                showAlert(
                                    "Ask the group leader to change the event.",
                                    context);
                              }
                            },
                            child: StreamBuilder(
                              stream: Stream.fromFuture(
                                  Future.delayed(timeTillExpire)),
                              builder: (stream, value) => timeTillExpire
                                      .isNegative
                                  ? Consumer<ApiClient>(
                                      builder: (context, apiClient, child) {
                                        if (event.id == groupModel.curEventId) {
                                          apiClient.serverApi
                                              ?.setCurrentEvent("");
                                        }
                                        return Container();
                                      },
                                    )
                                  : EventCell(
                                      event.name,
                                      format.format(
                                          DateTime.parse(event.endTime)),
                                      event.description,
                                      complete,
                                      event.id == groupModel.curEventId,
                                      DateTime.parse(event.endTime),
                                      reward ?? "",
                                      event.rewardIds.length,
                                      event.requiredMembers,
                                      chal?.imageUrl ??
                                          "https://a.rgbimg.com/users/b/ba/badk/600/qfOGvbS.jpg",
                                    ),
                            ),
                          ),
                        );
                      }
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: eventCells,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
