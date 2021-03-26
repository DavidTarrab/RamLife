import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

/// A widget to represent a [Period] when creating a [Special].
class PeriodTile extends StatelessWidget {
	/// The view model to decide the properties of this period. 
	final SpecialBuilderModel model;

	/// The times for this period. 
	final Range range;

	/// Allows [range] to be formatted according to the user's locale.
	final TimeOfDay start, end;

	/// The [Activity] for this period. 
	final Activity? activity;

	/// Whether this period is skipped. 
	final bool skipped;

	/// The index of this period in [SpecialBuilderModel.times].
	final int index;

	/// Creates a widget to edit a period in a [Special].
	PeriodTile({
		required this.model,
		required this.range,
		required this.index,
	}) : 
		skipped = model.skips.contains(index),
		activity = null,
		start = range.start.asTimeOfDay,
		end = range.end.asTimeOfDay;

	@override
	Widget build(BuildContext context) => SizedBox(
		height: 55,
		child: Stack (
			children: [
				if (skipped) Center(
					child: Container(
						height: 5,
						color: Colors.black,	
					),
				),
				ListTile(
					subtitle: Text(model.periods [index]),
					leading: IconButton(
						icon: Icon(
							model.skips.contains(index) 
								? Icons.add_circle_outline 
								: Icons.remove_circle_outline
						),
						onPressed: () => model.toggleSkip(index),
					),
					title: Text.rich(
						TextSpan(
							children: [
								WidgetSpan(
									child: InkWell(
										onTap: () async => model.replaceTime(
											index, 
											getRange(
												await showTimePicker(
													context: context,
													initialTime: start,
												) ?? start,
												start: true,
											)
										),
										child: Text(
											start.format(context), 
											style: const TextStyle(color: Colors.blue)
										),
									),
								),
								const TextSpan(text: " -- "),
								WidgetSpan(
									child: InkWell(
										onTap: () async => model.replaceTime(
											index,
											getRange(
												await showTimePicker(
													context: context,
													initialTime: end,
												) ?? end,
												start: false,
											)
										),
										child: Text(
											end.format(context), 
											style: const TextStyle(color: Colors.blue)
										),
									),
								),
							]
						)
					),
				)
			]
		)
	);

	/// Creates a [Range] from a [TimeOfDay]. 
	/// 
	/// [start] determines if the range starts with [time] or not.
	Range getRange(TimeOfDay time, {required bool start}) => Range(
		start ? time.asTime : range.start,
		start ? range.end : time.asTime,
	);
}
