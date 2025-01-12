import 'dart:async';
import 'package:game/api/game_client_dto.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameServerApi {
  final Future<bool> Function() _refreshAccess;
  Socket _socket;

  String _refreshEv = "";
  dynamic _refreshDat = "";

  GameServerApi(Socket socket, Future<bool> Function() refresh)
      : _refreshAccess = refresh,
        _socket = socket {
    _socket.onError((data) async {
      if (await _refreshAccess()) {
        _socket.emit(_refreshEv, _refreshDat);
      }
    });
  }

  void replaceSocket(Socket socket) {
    _socket = socket;
    _socket.onError((data) async {
      if (await _refreshAccess()) {
        _socket.emit(_refreshEv, _refreshDat);
      }
    });
  }

  void _invokeWithRefresh(String ev, Map<String, dynamic> data) {
    _refreshEv = ev;
    _refreshDat = data;
    print(ev);
    _socket.emit(ev, data);
  }

  void requestRewardData(List<String> rewardIds) =>
      _invokeWithRefresh("requestRewardData", {'rewardIds': rewardIds});

  void requestGlobalLeaderData(int offset, int count) => _invokeWithRefresh(
      "requestGlobalLeaderData", {'offset': offset, 'count': count});

  void closeAccount() => _invokeWithRefresh("closeAccount", {});
  void setUsername(String newUsername) =>
      _invokeWithRefresh("setUsername", {'newUsername': newUsername});
  // void setMajor(String newMajor) =>
  //     _invokeWithRefresh("setMajor", {'newMajor': newMajor});
  void setGraduationYear(String newYear) =>
      _invokeWithRefresh("setGraduationYear", {'newYear': newYear});
  void requestUserData() => _invokeWithRefresh("requestUserData", {});
  void requestGroupData() => _invokeWithRefresh("requestGroupData", {});
  void joinGroup(String groupId) =>
      _invokeWithRefresh("joinGroup", {'groupId': groupId});
  void leaveGroup() => _invokeWithRefresh("leaveGroup", {});
  void setCurrentEvent(String eventId) =>
      _invokeWithRefresh("setCurrentEvent", {"eventId": eventId});
  void requestEventData(List<String> eventIds) =>
      _invokeWithRefresh("requestEventData", {"eventIds": eventIds});
  void requestAllEventData(
          int offset,
          int count,
          List<EventRewardType> rewardTypes,
          bool closestToEnding,
          bool shortestFirst,
          bool skippableOnly) =>
      _invokeWithRefresh("requestAllEventData", {
        "offset": offset,
        "count": count,
        "closestToEnding": closestToEnding,
        "shortestFirst": shortestFirst,
        "skippableOnly": skippableOnly,
        "rewardTypes": rewardTypes
            .map((e) => e == EventRewardType.PERPETUAL
                ? 'perpetual'
                : 'limited_time_event')
            .toList()
      });

  void requestEventLeaderData(int offset, int count, String eventId) =>
      _invokeWithRefresh("requestEventLeaderData",
          {"offset": offset, "count": count, "eventId": eventId});

  void requestEventTrackerData(List<String> trackedEventIds) =>
      _invokeWithRefresh(
          "requestEventTrackerData", {"trackedEventIds": trackedEventIds});

  void requestChallengeData(List<String> challengeIds) => _invokeWithRefresh(
      "requestChallengeData", {"challengeIds": challengeIds});

  void setCurrentChallenge(String challengeId) =>
      _invokeWithRefresh("setCurrentChallenge", {"challengeId": challengeId});

  void completedChallenge(String challengeId) =>
      _invokeWithRefresh("completedChallenge", {"challengeId": challengeId});

  void requestOrganizationDataDto() =>
      _invokeWithRefresh("requestOrganizationDataDto", {"admin": false});
}
