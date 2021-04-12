import "package:meta/meta.dart";

import "contact_info.dart";
import "schedule/advisory.dart";
import "schedule/day.dart";
import "schedule/period.dart";
import "schedule/special.dart";
import "schedule/time.dart";

/// What grade the user is in. 
/// 
/// The [User.grade] field could be an `int`, but by specifying the exact
/// possible values, we avoid any possible errors, as well as possibly cleaner
/// code.  
/// 
/// Faculty users can have [User.grade] be null. 
enum Grade {
	/// A Freshman. 
	freshman, 

	/// A Sophomore. 
	sophomore,

	/// A Junior. 
	junior,

	/// A Senior. 
	senior
}

/// Maps grade numbers to a [Grade] type. 
Map<int, Grade> intToGrade = {
	9: Grade.freshman,
	10: Grade.sophomore,
	11: Grade.junior,
	12: Grade.senior,
};

/// Represents a user and all their data. 
/// 
/// This objects includes data like the user's schedule, grade, list of clubs, 
/// and more. 
@immutable
class User {
	/// The user's schedule. 
	/// 
	/// Each key is a different day, and the values are list of periods in that  
	/// day. Possible key values are defined by [dayNames].
	/// 
	/// Periods may be null to indicate free periods (or, in the case of faculty,
	/// periods where they don't teach).
	final Map<String, List<PeriodData?>> schedule;

	/// The advisory for this user. 
	final Advisory? advisory;

	/// This user's contact information. 
	final ContactInfo contactInfo;

	/// The grade this user is in. 
	/// 
	/// This property is null for faculty. 
	final Grade? grade;

	/// The IDs of the clubs this user attends.
	/// 
	/// TODO: decide if this is relevant for captains.
	final List<String> registeredClubs; 

	/// The possible day names for this user's schedule.
	/// 
	/// These will be used as the keys for [schedule].
	final Iterable<String> dayNames;

	/// Creates a new user.
	const User({
		required this.schedule,
		required this.contactInfo,
		required this.registeredClubs,
		required this.dayNames,
		this.grade,
		this.advisory,
	});

	/// Gets a value from JSON, throwing if null.
	/// 
	/// This function is needed since null checks don't run on dynamic values.
	static dynamic safeJson(Map<String, dynamic> json, String key) {
		final dynamic value = json [key];
		if (value == null) {
			throw ArgumentError.notNull(key);
		} else {
			return value;
		}
	}

	/// Creates a new user from JSON. 
	User.fromJson(Map<String, dynamic> json) : 
		dayNames = List<String>.from(safeJson(json, "dayNames")),
		schedule = {
			for (final String dayName in safeJson(json, "dayNames"))
				dayName: PeriodData.getList(json [dayName])
		},
		advisory = json ["advisory"] == null ? null : Advisory.fromJson(
			Map<String, dynamic>.from(safeJson(json, "advisory"))
		),
		contactInfo = ContactInfo.fromJson(
			Map<String, dynamic>.from(safeJson(json, "contactInfo"))
		),
		grade = json ["grade"] == null ? null : intToGrade [safeJson(json, "grade")],
		registeredClubs = List<String>.from(json ["registeredClubs"] ?? []);

	/// Gets the unique section IDs for the courses this user is enrolled in.
	/// 
	/// For teachers, these will be the courses they teach. 
	Set<String> get sectionIDs => {
		for (final List<PeriodData?> daySchedule in schedule.values)
			for (final PeriodData? period in daySchedule)
				if (period != null)
					period.id
	};

	/// Computes the periods, in order, for a given day. 
	/// 
	/// This method converts the [PeriodData]s in [schedule] into [Period]s using 
	/// [Day.special]. [PeriodData] objects are specific to the user's schedule, 
	/// whereas the times of the day [Range]s are specific to the calendar. 
	/// 
	/// See [Special] for an explanation of the different factors this method
	/// takes into account. 
	List<Period> getPeriods(Day day) {
		final Special special = day.special;
		final int periodCount = special.periods.length;
		int periodIndex = 0;
		return [
			for (int index = 0; index < periodCount; index++)
				if (special.homeroom == index) Period(
					data: null,		
					period: "Homeroom",
					time: special.periods [index],
					activity: null,
				) else if (special.mincha == index) Period(
					data: null,
					period: "Mincha",
					time: special.periods [index],
					activity: null,
				) else if (special.skip.contains(index)) Period(
					data: null,
					period: "Free period",
					time: special.periods [index],
					activity: null,
				) else Period(
					data: schedule [day.name]! [periodIndex],
					period: (++periodIndex).toString(),
					time: special.periods [index],
					activity: null,
				)
		];
	}
}
