import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/app_background.dart';
import 'dashboard_screen.dart';
import 'skills_screen.dart';
import 'opportunities_screen.dart';
import 'applications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([store, store.tabIndex]),
      builder: (context, _) {
        final index = store.tabIndex.value;
        final applied = store.applications.length;

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: IndexedStack(
                index: index,
                children: [
                  DashboardScreen(store: store),
                  SkillsScreen(store: store),
                  OpportunitiesScreen(store: store),
                  ApplicationsScreen(store: store),
                  ProfileScreen(store: store),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: store.goToTab,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Skills',
              ),
              const NavigationDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: applied > 0,
                  label: Text('$applied'),
                  child: const Icon(Icons.track_changes_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: applied > 0,
                  label: Text('$applied'),
                  child: const Icon(Icons.track_changes),
                ),
                label: 'Tracker',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
