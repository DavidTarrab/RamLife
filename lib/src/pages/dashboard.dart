import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

const List<String> weekdayNames = [
	"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
];

class Dashboard extends NavigationItem {
	final ScheduleModel scheduleModel = Models.instance.schedule;

	/// The reminders data model. 
	final Reminders remindersModel = Models.instance.reminders;

	/// The sports data model. 
	final Sports sportsModel = Models.instance.sports;

	Dashboard() : 
		super(label: "Dashboard", icon: const Icon(Icons.dashboard));

	@override
	AppBar get appBar => AppBar(
		title: const Text("Dashboard"),
		actions: [
		if (scheduleModel.hasSchool)
			Builder(
				builder: (BuildContext context) => TextButton(
					onPressed: () => Scaffold.of(context).openEndDrawer(),
					child: const Text ("Tap for schedule"),
				)
			)
		]
	);

	@override
	Widget? get sideSheet => !scheduleModel.hasSchool ? null : ClassList(
		// if there is school, then:
		// 	scheduleModel.today != null
		// 	scheduleModel.periods != null
		day: scheduleModel.today!,  
		periods: scheduleModel.nextPeriod == null 
			? scheduleModel.periods!
			: scheduleModel.periods!.getRange (
				(scheduleModel.periodIndex ?? -1) + 1, 
				scheduleModel.periods!.length
			),
		headerText: scheduleModel.period == null 
			? "Today's Schedule" 
			: "Upcoming Classes"
	);

	/// Allows the user to refresh data. 
	/// 
	/// Updates the calendar and sports games. To update the user profile, 
	/// log out and log back in. 
	/// 
	/// This has to be a separate function since it can recursively call itself. 
	Future<void> refresh(BuildContext context, HomeModel model) => model.refresh(
		() => ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: const Text("No Internet"), 
				action: SnackBarAction(
					label: "RETRY", 
					onPressed: () => refresh(context, model),
				),
			)
		)
	);

	@override 
	Widget build(BuildContext context) => ModelListener(
		model: () => HomeModel(),
		builder: (BuildContext context, HomeModel model, _) => RefreshIndicator(
			onRefresh: () => refresh(context, model),
			child: ListView(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
				children: [
					Text (
						scheduleModel.today == null
							? "There is no school today"
							: "Today is ${scheduleModel.today!.name}",
						style: Theme.of(context).textTheme.headline3,
						textAlign: TextAlign.center
					),
					const SizedBox (height: 20),
					if (scheduleModel.hasSchool) ...[
						ScheduleSlot(),
						const SizedBox(height: 10),
					],
					if (sportsModel.todayGames.isNotEmpty) ...[
						Text(
							"Sports games",
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.headline5,
						),
						const SizedBox(height: 10),
						for (final int index in sportsModel.todayGames)
							SportsTile(sportsModel.games [index])
					]
				]
			)
		)
	);
}

/// Holds the schedule info on the home page.
class ScheduleSlot extends StatelessWidget {
	/// The schedule data model.
	late final ScheduleModel scheduleModel;

	/// The reminders data model.
	late final Reminders remindersModel;

	/// Displays schedule info on the home page.
	ScheduleSlot() {
		final Models models = Models.instance;
		remindersModel = models.reminders;
		scheduleModel = models.schedule;
	}

	/// The [NextClass] widgets to display.
	List<Widget> get children => [
		if (scheduleModel.hasSchool) NextClass(
			reminders: remindersModel.currentReminders,
			period: scheduleModel.period,
			subject: scheduleModel.subjects [scheduleModel.period?.id],
		),
		if (scheduleModel.nextPeriod != null) NextClass(
			next: true,
			reminders: remindersModel.nextReminders,
			period: scheduleModel.nextPeriod,
			subject: scheduleModel.subjects [scheduleModel.nextPeriod?.id],
		),
	];

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => Column(
			children: [
				Text(
					scheduleModel.hasSchool
						// if there is school, then scheduleModel.today != null
						? "Schedule: ${scheduleModel.today!.schedule.name}"
						: "There is no school today",
					textAlign: TextAlign.center,
					style: Theme.of(context).textTheme.headline5,
				),
				const SizedBox (height: 10),
				if (layout.isDesktop && children.length > 1) GridView.count(
					shrinkWrap: true,
					crossAxisCount: layout.isDesktop ? children.length : 1,
					children: children
				) else Column(children: children)
			]
		)
	);
}
