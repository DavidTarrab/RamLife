import "package:flutter/foundation.dart";

/// A subject, or class, that a student can take.
/// 
/// Since one's schedule contains multiple instances of the same subject,
/// subjects are represented externally by an ID, which is used to look up
/// a canonicalized [Subject] instance. This saves space and simplifies
/// compatibility with existing school databases. 
@immutable
class Subject {
	/// Returns a map of [Subject]s from a list of JSON objects.
	/// 
	/// The keys are IDs to the subject, and the values are the
	/// corresponding [Subject] instances.
	/// See [Subject.fromJson] for more details. 
	static Map<String, Subject> getSubjects(
		Map<String, Map<String, dynamic>> data
	) => data.map (
		(String id, Map<String, dynamic> json) => MapEntry (
			id,
			Subject.fromJson(json)
		)
	);

	/// The name of this subject.
	final String name;
	
	/// The teacher who teaches this subject.
	final String teacher;

	/// A const constructor for a [Subject].
	const Subject ({
		required this.name,
		required this.teacher
	});

	/// Returns a [Subject] instance from a JSON object. 
	/// 
	/// The JSON map must have a `teacher` and `name` field.
	Subject.fromJson(Map<String, dynamic> json) :
		name = json ["name"], 
		teacher = json ["teacher"];

	@override 
	String toString() => "$name ($teacher)";
		
	@override 
	int get hashCode => "$name-$teacher".hashCode;

	@override 
	bool operator == (dynamic other) => other is Subject && 
		other.name == name &&
		other.teacher == teacher;
}
