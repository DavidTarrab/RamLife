import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services.dart";

class ClubsModel {
	// Get from CloudDatabase.
	User user;

	ClubsModel() {
		user = Models.instance.user.data;
	}

	Future<void> registerForClub(Club club) => Services
		.instance
		.database
		.cloudDatabase
		.registerForClub(club.id, user.contactInfo.json);

	void unregisterFromClub(Club club) {
		// Use Firestore to remove your contact info from the members collection
	}

	void email(ContactInfo contact) {
		// Open an email app to contact this person. 
	}

	/// Gets a list of all the club for the user to browse. 
	Future<List<Club>> getAllClubs() async {
		// Step 1. Get the raw JSON. 
		// Step 2. Turn them into a list of clubs
		final List<Map<String, dynamic>> rawJson = 
			await Services.instance.database.allClubs;

		final List<Club> result = [];
		for (final Map<String, dynamic> json in rawJson) {
			result.add(Club.fromJson(json));
		}
		return result;
	}	
}

abstract class ClubAdminsModel {
	Club club;

	void markMeetingAsSpecial(DateTime date);
	void rescheduleMeeting(DateTime from, DateTime to);
	void postMessage(String message);
	void createClub();
	void approveClub();
	void emailAll();
}