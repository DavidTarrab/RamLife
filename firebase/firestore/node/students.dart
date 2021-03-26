// @dart=2.9

import "package:firestore/constants.dart";
import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";
import "package:firestore/students.dart";

Future<void> main() async {
	Args.initLogger("Indexing data...");

	final Map<String, List<String>> studentClasses = await Logger.logValue(
		"student classes", StudentReader.getStudentClasses
	);

	final Map<String, User> students = await Logger.logValue(
		"students", StudentReader.getStudents
	);

	final Map<String, List<Period>> periods = await Logger.logValue(
		"section periods", StudentReader.getPeriods
	);

	// Early 2020 data did not contain homerooms...
	// final Map<String, String> homeroomLocations = 
		// StudentReader.homeroomLocations;
	final Map<String, String> homeroomLocations = DefaultMap((_) => "Unavailable");
	Logger.debug("Homeroom locations", homeroomLocations);

	final Map<String, Semesters> semesters = await Logger.logValue(
		"semesters", StudentReader.getSemesters
	);

	final Map<User, Map<String, List<Period>>> schedules = 
		await Logger.logValue(
			"schedules", () => StudentLogic.getSchedules(
				students: students,
				periods: periods,
				studentClasses: studentClasses,
				semesters: semesters,
			)
		);

	final Map<User, String> homerooms = StudentLogic.homerooms;
	Logger.debug("Homerooms", homerooms);

	Logger.debug("Seniors", StudentLogic.seniors);

	final List<User> studentsWithSchedules = await Logger.logValue(
		"student schedules", () => StudentLogic.getStudentsWithSchedules(
			schedules: schedules,
			homerooms: homerooms, 
			homeroomLocations: homeroomLocations,
		)
	);
	
	User.verifySchedules(studentsWithSchedules);

	final List<User> testUsers = [
		for (final Map<String, dynamic> tester in testers)
			User.empty(
				email: tester ["email"],
				first: tester ["first"],
				last: tester ["last"],
			)
	];
	Logger.info("Found ${testUsers.length} testers");
	studentsWithSchedules.addAll(testUsers);

	Logger.info("Finished data indexing.");

	if (Args.upload) {
		await Logger.logProgress(
			"data upload", () => Firestore.uploadUsers(studentsWithSchedules)
		);
	} else {
		Logger.warning("Did not upload student data. Use the --upload flag.");
	}
	await app.delete();
	Logger.info("Processed ${students.length} users.");
}
