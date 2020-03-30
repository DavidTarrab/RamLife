import "package:firebase_admin_interop/firebase_admin_interop.dart" as fb;

import "package:firestore/data.dart";

import "firebase.dart";

/// A wrapper around Cloud Firestore.
class Firestore {
	/// The firestore instance for [app].
	static final fb.Firestore firestore = app.firestore(); 

	/// The name of the students collection.
	static const String studentsKey = "students";

	/// The name of the calendar collection.
	static const String calendarKey = "calendar";

	/// The name of the course collection.
	static const String courseKey = "classes";

	/// The students collection.
	static final fb.CollectionReference studentsCollection = 
		firestore.collection(studentsKey);

	/// The calendar collection.
	static final fb.CollectionReference calendarCollection = 
		firestore.collection(calendarKey);

	/// The course collection.
	static final fb.CollectionReference courseCollection =
		firestore.collection(courseKey);

	/// Uploads users to the cloud. 
	/// 
	/// Puts all users in a batch and commits them all at once.
	static Future<void> upoadStudents(List<User> users) {
		final fb.WriteBatch batch = firestore.batch();
		for (final User user in users) {
			batch.setData(
				studentsCollection.document(user.email), 
				fb.DocumentData.fromMap(user.json)
			);
		}
		return batch.commit();
	}

	/// Uploads a month of the calendar to the cloud. 
	/// 
	/// This collection is assumed to already contain a document for each month,
	/// so [fb.DocumentRefernce.update] is used instead of 
	/// [fb.DocumentRefernce.setData].
	static Future<void> uploadMonth(int month, List<Day> calendar) =>
		calendarCollection.document(month.toString()).updateData(
			fb.UpdateData.fromMap({
				"calendar": [
					for (final Day day in calendar)
						day.json
				]
			}
		)
	);

	/// Uploads all the sections to the cloud.
	/// 
	/// This function uses [fb.WriteBatch] to upload more efficiently. However, 
	/// each batch can only contain a maximum of 500 documents, but there are more
	/// sections than that. So this function splits it up into as many batches as 
	/// it needs to upload successfully.
	static Future<void> uploadSections(List<Section> sections) async {
		final List<fb.WriteBatch> batches = [];
		int count = 0;
		for (final Section section in sections) {
			if (count % 500 == 0) {
				batches.add(firestore.batch());
			}
			batches [batches.length - 1].setData(
				courseCollection.document(section.id),
				fb.DocumentData.fromMap(section.json),
			);
			count++;
		}
	}
}