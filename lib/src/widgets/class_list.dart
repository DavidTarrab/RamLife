import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class ClassPanel extends StatelessWidget {
	final String title;
	final List<String> children;
	final List<int> notes;

	const ClassPanel ({
		@required this.title,
		@required this.children,
		@required this.notes,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: SizedBox (
			height: 50,
			child: Center (
				child: ListTile (
					title: Text (title),
					contentPadding: EdgeInsets.zero,
					trailing: notes.isEmpty ? null : Icon(Icons.note)
				)
			)
		),
		children: [
			Padding (
				padding: EdgeInsets.only(left: 30),
				child: Align (
					alignment: Alignment.centerLeft,					
					child: Column (
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							for (final String label in children) 
								Padding (
									padding: const EdgeInsets.symmetric(vertical: 5),
									child: Text (label)
								),
							for (final int index in notes)
								NoteTile (
									index: index,
									height: 60,
								)
						]
					)
				)
			)
		]
	);
}

class ClassList extends StatelessWidget {
	final Day day;
	final Iterable<Period> periods;

	final String headerText;

	const ClassList ({
		@required this.day, 
		this.headerText,
		this.periods,
	});

	@override Widget build(BuildContext context) => ModelListener<Notes>(
		model: () => Services.of(context).notes,
		dispose: false,
		child: DrawerHeader (
			child: Center (
				child: Text (
					headerText ?? "",
					textScaleFactor: 2,
					textAlign: TextAlign.center,
				)
			)
		),
		builder: (BuildContext context, Notes notes, Widget header) {
			final Services services = Services.of(context);
			return ListView (
				shrinkWrap: true,
				children: [
					if (headerText != null) header,
					...[
						for (
							final Period period in 
							periods ?? services.schedule.student.getPeriods(day)
						) getPanel(services, period)
					]
				]
			);
		}
	);

	Widget getPanel(Services services, Period period) {
		final Subject subject = services.schedule.subjects[period.id];
		return ClassPanel (
			children: [
				for (final String description in period.getInfo(subject))
					if (!description.startsWith("Period:"))
						description,
				if (period.id != null) 
					"ID: ${period.id}",
			],
			title: (int.tryParse(period.period) == null 
				? period.getName(subject)
				: "${period.period}: ${period.getName(subject)}"
			),
			notes: services.notes.getNotes(
				period: period.period,
				letter: day.letter,
				subject: subject?.name,
			),
		);
	}
}
