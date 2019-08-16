import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/models/notes.dart";
import "package:ramaz/data/note.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/drawer.dart" show NavigationDrawer;
import "package:ramaz/pages/notes_builder.dart";

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatelessWidget {
	final Reader reader;
	final Widget drawer;

	NotesPage({
		@required this.reader,
		@required Preferences prefs,
	}) : drawer = NavigationDrawer(prefs);

	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<NoteEditor>(
		model: () => NoteEditor(reader),
		builder: (BuildContext context, NoteEditor model, _) => Scaffold(
				drawer: drawer,
				appBar: AppBar(title: Text ("Notes")),
				floatingActionButton: FloatingActionButton(
					child: Icon (Icons.note_add),
					onPressed: () async => model.addNote(await showBuilder(context)),
				),
				body: model.notes.isEmpty
					? Center (
						child: Text (
							"You don't have any notes yet",
							textScaleFactor: 1.5,
							textAlign: TextAlign.center,
						),
					) 
					: ListView.separated (
						itemCount: model.notes.length,
						separatorBuilder: (_, __) => Divider(),
						itemBuilder: (BuildContext context, int index) => NoteTile(
							note: model.notes [index],
							onTap: () async => model.replaceNote(
								index, 
								await showBuilder(context, model.notes [index]),
							),
							onDelete: () => model.deleteNote(index),
						),
					)
		)
	);

	Future<Note> showBuilder(BuildContext context, [Note note]) => 
		showDialog<Note>(
			context: context,
			builder : (BuildContext context) => 
				NotesBuilder(reader: reader, note: note)
		);
}