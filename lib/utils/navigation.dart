import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../screens/opportunity_details_screen.dart';
import '../screens/saved_screen.dart';
import '../services/app_store.dart';

/// Tab indexes of the bottom navigation bar.
class Tabs {
  static const home = 0;
  static const skills = 1;
  static const explore = 2;
  static const tracker = 3;
  static const profile = 4;
}

/// Opens the full details page for one opportunity.
void openOpportunity(BuildContext context, AppStore store, Opportunity opportunity) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OpportunityDetailsScreen(opportunity: opportunity, store: store),
    ),
  );
}

/// Opens the saved-opportunities page.
void openSaved(BuildContext context, AppStore store) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SavedScreen(store: store)),
  );
}

/// Closes any pushed pages and switches to a bottom-navigation tab.
void openTab(BuildContext context, AppStore store, int index) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  store.goToTab(index);
}
