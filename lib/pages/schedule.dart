import "package:flutter/material.dart";

// import "package:ramaz/services/preferences.dart";
// import "package:ramaz/services/reader.dart";
import "package:ramaz/widgets/services.dart";

import "package:ramaz/models/schedule.dart";
import "package:ramaz/data/times.dart";
import "package:ramaz/data/schedule.dart" show Letters;

import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/widgets/footer.dart";
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/date_picker.dart" show pickDate;

class SchedulePage extends StatelessWidget {
	final bool canExit;

	SchedulePage ({
		this.canExit = false
	});

	@override
	Widget build (BuildContext context) => ChangeNotifierListener<ScheduleModel>(
		model: () => ScheduleModel(services: Services.of(context).services),
		builder: (BuildContext context, ScheduleModel model, Widget _) => Scaffold(
			appBar: AppBar (
				title: Text ("Schedule"),
				actions: canExit ? null : [
					IconButton (
						icon: Icon (Icons.home),
						onPressed: () => Navigator
							.of(context)
							.pushReplacementNamed("home")
					)
				]
			),
			bottomNavigationBar: Footer (
				period: model.reader.period,
				subject: model.reader.subject,
				note: model.noteModel.hasNote
			),
			floatingActionButton: Builder (
				builder: (BuildContext context) => FloatingActionButton (
					child: Icon (Icons.calendar_today),
					onPressed: () => viewDay (model, context)
				)
			),
			drawer: canExit ? null : NavigationDrawer(),
			body: Column (
				children: [
					ListTile (
						title: Text ("Choose a letter"),
						trailing: DropdownButton<Letters> (
							value: model.day.letter, 
							onChanged: (Letters letter) => model.update(newLetter: letter),
							items: Letters.values.map<DropdownMenuItem<Letters>> (
								(Letters letter) => DropdownMenuItem<Letters> (
									child: Text (letter.toString().split(".").last),
									value: letter
								)
							).toList()
						)
					),
					ListTile (
						title: Text ("Choose a schedule"),
						trailing: DropdownButton<Special> (
							value: model.day.special,
							onChanged: (Special special) => model.update(newSpecial: special),
							items: specials.map<DropdownMenuItem<Special>> (
								(Special special) => DropdownMenuItem<Special> (
									child: Text (special.name),
									value: special
								)
							).toList()
						)
					),
					SizedBox (height: 20),
					Divider(),
					SizedBox (height: 20),
					Expanded (
						child: ClassList(
							noteModel: model.noteModel,
							day: model.day, 
							reader: model.reader
						)
					),
				]
			)
		)
	);

	void viewDay(ScheduleModel model, BuildContext context) async {
		final DateTime selected = await pickDate (
			context: context,
			initialDate: model.selectedDay
		);
		if (selected == null) return;
		try {model.date = selected;}
		on ArgumentError {
			Scaffold.of(context).showSnackBar(
				SnackBar (
					content: Text ("There is no school on this day")
				)
			);
		}
	}
}
