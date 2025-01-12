import 'package:flutter/foundation.dart';
import 'package:game/api/game_api.dart';
import 'package:game/api/game_client_dto.dart';

class RewardModel extends ChangeNotifier {
  ApiClient _client;
  Map<String, RewardDTO> rewardByEventId = {};

  RewardModel(ApiClient client) : _client = client {
    client.clientApi.updateUserDataStream.listen((event) {
      if (!event.ignoreIdLists) {
        client.serverApi?.requestRewardData(event.rewardIds);
      }
    });

    client.clientApi.updateRewardDataStream.listen((event) {
      if (event.deleted) {
        rewardByEventId.removeWhere((key, value) => (key == event.id));
      } else {
        rewardByEventId[event.id!] = event.reward!;
      }
      notifyListeners();
    });

    client.clientApi.connectedStream.listen((event) {
      rewardByEventId.clear();
      notifyListeners();
    });

    client.clientApi.invalidateDataStream.listen((event) {
      if (event.userRewardData || event.winnerRewardData) {
        rewardByEventId.clear();
        notifyListeners();
      }
    });
  }

  RewardDTO? getRewardByEventId(String eventId, String rewardId) {
    final reward = rewardByEventId[eventId];
    if (reward != null) {
      return reward;
    } else {
      _client.serverApi?.requestRewardData([rewardId]);
      return null;
    }
  }
}
