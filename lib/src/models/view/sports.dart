import "dart:async";

import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

// ignore: prefer_mixin
class Sports with ChangeNotifier {
	static const Duration updateInterval = Duration (hours: 1);

	List<SportsGame> games, recents, upcoming, todayGames;
	Timer timer;

	Sports(Reader reader) {
		setup(reader);
		timer = Timer.periodic(updateInterval, updateGames);
	}

	@override
	void dispose() {
		timer.cancel();
		super.dispose();
	}

	void setup(Reader reader) {
		games = SportsGame.fromList(reader.sportsData);
		updateGames();
	}

	void updateGames([_]) {
		final DateTime now = DateTime.now();
		recents = [];
		upcoming = [];
		todayGames = [];
		for (final SportsGame game in games) {
			if (
				game.date.year == now.year &&
				game.date.month == now.month &&
				game.date.day == now.day
			) {
				todayGames.add(game);
			} else {
				(game.date.isAfter(now) ? recents : upcoming).add(game);
			}
		}
		notifyListeners();
	}
}
