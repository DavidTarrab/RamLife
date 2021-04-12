import "auth.dart";
import "cloud_db.dart";
import "database.dart";
import "local_db.dart";

/// Bundles different databases to provide more complex functionality. 
/// 
/// This class is used to consolidate the results of the online database and
/// the on-device database. It works by downloading all the necessary data in 
/// [signIn]. All reads are from [localDatabase], and all writes are to both 
/// databases. 
class Databases extends Database {
	/// Provides a connection to the online database. 
	final CloudDatabase cloudDatabase = CloudDatabase();

	/// The local device storage.
	/// 
	/// Used to minimize the number of requests to the database and keep the app
	/// offline-first. 
	final LocalDatabase localDatabase = LocalDatabase();

	@override
	Future<void> init() async {
		await cloudDatabase.init();
		await localDatabase.init();

		// Download this month's calendar, in case it changed
		final int month = DateTime.now().month;
		await localDatabase.setCalendar(
			month, 
			await cloudDatabase.getCalendarMonth(month)
		);
	}

	/// Downloads all the data and saves it to the local database. 
	@override 
	Future<void> signIn() async {
		await cloudDatabase.signIn();
		await localDatabase.signIn();

		await localDatabase.setUser(await cloudDatabase.user);
		await updateCalendar();
		// await updateSports();

		final List<Map<String, dynamic>> cloudReminders = 
			await cloudDatabase.reminders;
		for (int index = 0; index < cloudReminders.length; index++) {
			await localDatabase.updateReminder(index.toString(), cloudReminders [index]);
		}

		if (await Auth.isAdmin) {
			await localDatabase.setAdmin(await cloudDatabase.admin);
		}
	}

	/// Downloads the calendar and saves it to the local database.
	Future<void> updateCalendar() async {
		for (int month = 1; month <= 12; month++) {
			await localDatabase.setCalendar(
				month, 
				await cloudDatabase.getCalendarMonth(month)
			);
		}
	}

	/// Downloads sports games and saves them to the local database.
	Future<void> updateSports() async {
		await localDatabase.setSports(await cloudDatabase.sports);
	}

	@override 
	bool get isSignedIn => 
		cloudDatabase.isSignedIn && localDatabase.isSignedIn;

	@override
	Future<void> signOut() async {
		await cloudDatabase.signOut();
		await localDatabase.signOut();
	}

	@override
	Future<Map<String, dynamic>> get user => localDatabase.user;

	// Cannot modify user profile. 
	@override
	Future<void> setUser(Map<String, dynamic> json) async {} 

	/// Do not use this function. Use [getSections instead]. 
	/// 
	/// In a normal database, the [getSections] function works by calling 
	/// [getSection] repeatedly. So it would be this function that needs to be
	/// overridden. However, this class uses other [Database]s, so instead, 
	/// this function is left blank and [getSections] uses other 
	/// [Database.getSections] to work.
	@override
	Future<Map<String, dynamic>> getSection(String id) async => {};

	/// Gets section data. 
	/// 
	/// Checks the local database, and downloads it if the data is unavailable.
	@override
	Future<Map<String, Map<String, dynamic>>> getSections(
		Iterable<String> ids
	) async {
		Map<String, Map<String, dynamic>>? result = 
			await localDatabase.getSections(ids);
		if (result == null) {
			result = (await cloudDatabase.getSections(ids))!;
			await localDatabase.setSections(result);
		}
		return result;
	}

	// Cannot modify sections
	@override
	Future<void> setSections(Map<String, Map<String, dynamic>> json) async {}

	@override
	Future<Map<String, dynamic>> getCalendarMonth(int month) => 
		localDatabase.getCalendarMonth(month);

	@override
	Future<void> setCalendar(int month, Map<String, dynamic> json) async {
		await cloudDatabase.setCalendar(month, json);
		await localDatabase.setCalendar(month, json);
	}

	@override
	Future<List<Map<String, dynamic>>> get reminders => localDatabase.reminders;

	@override
	Future<void> updateReminder(dynamic oldHash, Map<String, dynamic> json) async {
		await cloudDatabase.updateReminder(oldHash, json);
		await localDatabase.updateReminder(oldHash, json);
	}

	@override
	Future<void> deleteReminder(dynamic oldHash) async {
		await cloudDatabase.deleteReminder(oldHash);
		await localDatabase.deleteReminder(oldHash);
	}

	@override
	Future<Map<String, dynamic>> get admin => localDatabase.admin;

	@override
	Future<void> setAdmin(Map<String, dynamic> json) async {
		await cloudDatabase.setAdmin(json);
		await localDatabase.setAdmin(json);
	}


	@override
	Future<List<Map<String, dynamic>>> get sports => localDatabase.sports;

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) async {
		await cloudDatabase.setSports(json);
		await localDatabase.setSports(json);
	}

	@override
	Future<List<Map<String, dynamic>>> get allClubs => 
		cloudDatabase.allClubs;
}