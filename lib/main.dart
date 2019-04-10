// BUG: Tzom should skip lunch periods
// TODO: Convert static funcs to factories
// TODO: Get Ramaz icon for login
// TODO: Retrieve user
// TODO: Verify password
// TODO: Retrieve user data 
// TODO: Retrieve day
// TODO: Retrieve period
// TODO: Handle free
// TEST: Winter fridays

import "package:flutter/material.dart";
import "widgets/drawer.dart";  // mock page for all other screens

import "mock.dart";
import "widgets/schedule.dart" show SchedulePage;
import "widgets/home.dart" show HomePage;

void main () => runApp (
	MaterialApp (
		home: getMainPage(),
		routes: {
			"main": (_) => HomePage(), 
			"lunch": placeholder ("Lunch"),
			"schedule": (_) => SchedulePage(levi),
			"news": placeholder ("News"),
			"lost-and-found": placeholder ("Lost and found"),
			"sports": placeholder ("Sports")
		}
	)
);

class PlaceholderPage extends StatelessWidget {
	final String title;
	PlaceholderPage (this.title);

	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(),
		appBar: AppBar (title: Text (title)),
		body: Placeholder()
	);
}

Widget Function(BuildContext) placeholder(String text) => 
	(BuildContext context) => PlaceholderPage (text);