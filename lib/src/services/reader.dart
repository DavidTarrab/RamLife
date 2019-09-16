import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

/// An abstraction around the file system.
/// 
/// This class handles reading and writing JSON to and from files. 
/// Note that only raw data should be used with this class. Using 
/// dataclasses will create a dependency on the data library. 
class Reader {
	/// The path for this app's file directory.
	/// 
	/// Every app is provided a unique path in the file system by the OS. 
	/// Performing operations on files in this directory does not require
	/// extra permissions. In other words, data belonging exclusively to
	/// an app should reside in its given directory.  
	final String dir;
	
	/// The file containing the user's schedule.
	final File studentFile;

	/// The file containing data for all the classes in the user's schedule.
	final File subjectFile;

	/// The file containing the calendar. 
	final File calendarFile;

	/// The file containing the user's notes. 
	final File notesFile;

	/// The file containing the user's downloaded publications.
	final File publicationsFile;

	/// Initializes the files based on the path ([dir]) provided to it. 
	Reader(this.dir) :
		studentFile = File ("$dir/student.json"),
		subjectFile = File ("$dir/subjects.json"),
		calendarFile = File ("$dir/calendar.json"),
		publicationsFile = File ("$dir/publications.json"),
		notesFile = File ("$dir/notes.json");

	/// The JSON representation of the user's schedule.
	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
	);

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	/// The JSON representation of the user's classes. 
	/// 
	/// The value returned is a map where the keys are the class IDs 
	/// and the values are JSON representations of the class. 
	Map<String, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map<String, Map<String, dynamic>> (
		(String id, dynamic json) => MapEntry (
			id,
			Map<String, dynamic>.from(jsonDecode(json))
		)
	);

	set subjectData (Map<String, Map<String, dynamic>> subjects) {
		subjectFile.writeAsStringSync (
			jsonEncode (
				subjects.map(
					(String id, Map<String, dynamic> json) => MapEntry(
						id.toString(), jsonEncode(json)
					)
				)
			)
		);
	}

	/// The JSON representation of the calendar. 
	Map<String, dynamic> get calendarData => jsonDecode(
		calendarFile.readAsStringSync()
	);

	set calendarData (Map<String, dynamic> data) => calendarFile.writeAsStringSync(
		jsonEncode(data)
	);

	/// The JSON representation of the user's notes.
	/// 
	/// This includes a list of the user's read notes. 
	Map<String, dynamic> get notesData => Map<String, dynamic>.from(
		jsonDecode(
			notesFile.readAsStringSync()
		) ?? {}
	);

	set notesData(Map<String, dynamic> data) => notesFile.writeAsStringSync(
		jsonEncode(data ?? {})
	);

	/// A JSON representation of the user's downloaded publications.
	List<Map<String, dynamic>> get publications => [
		for (final dynamic json in jsonDecode(
			publicationsFile.readAsStringSync()
		))
			Map<String, dynamic>.from(json)
	];

	set publications (List<Map<String, dynamic>> data) => publicationsFile.writeAsStringSync(
		jsonEncode(data)
	);

	/// Deletes all files that contain user data. 
	/// 
	/// This function will be called in two placed: 
	/// 
	/// 1. To try to get rid of bugs. If setup fails all data is erased. 
	/// 2. To clean up after logoff. 
	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
		if (subjectFile.existsSync())
			subjectFile.deleteSync();
		if (calendarFile.existsSync())
			calendarFile.deleteSync();
		if (notesFile.existsSync())
			notesFile.deleteSync();
		if (publicationsFile.existsSync())
			publicationsFile.deleteSync();
	}

	/// Whether the files necessary are present. 
	/// 
	/// This helps the setup logic determine whether to proceed 
	/// to the main app or prompt the user to login. 
	bool get ready => (
		studentFile.existsSync() && subjectFile.existsSync() 
		&& notesFile.existsSync() && calendarFile.existsSync()
	);
}
