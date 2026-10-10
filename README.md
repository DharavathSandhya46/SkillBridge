# SkillBridge – Student Skills & Opportunity Tracker (v1.1)

A Flutter app for students to track skills, explore opportunities, save listings and track applications.
All data is stored locally with `shared_preferences`.

## Run in VS Code (Windows)

1. Extract this ZIP and open the `SkillBridge` folder (the one containing `pubspec.yaml`) in VS Code.
2. Open a terminal and run:
   ```powershell
   flutter pub get
   flutter create . --platforms web
   flutter run -d chrome
   ```
   If Flutter is not on PATH, run first: `$env:Path += ";C:\Users\sandh\flutter\bin"`
3. Requires Flutter 3.27 or newer (Dart 3.6+). Check with `flutter --version`; upgrade with `flutter upgrade`.

## What's new in v1.1

**Every button now opens its own page**
- Dashboard: avatar → Profile; stat cards (Skills / Saved / Applied / Interviews) → their pages; Quick actions (Explore, Add skill, Tracker, Saved); recommended cards → full opportunity details.
- Profile: all tiles are live (My skills, Explore, Saved, Tracker); stat cards and top-skill chips are tappable.
- Tracker: tapping an application opens its opportunity; empty states have buttons that take you to Explore.
- Details page: after applying, "View in tracker" jumps straight to the Tracker tab. Bookmark now updates instantly.

**New features**
- **Skill match %** on every opportunity, based on your skills (DSA = Data Structures, MySQL counts as SQL, Flutter implies Dart).
- **Skill-gap analysis** on the details page: skills you have / still learning / missing. Tap a missing skill to add it to your list.
- **"Skills worth learning"** on the Skills tab: the most requested skills you don't have yet.
- **Recommended for you** on Home ranks listings by your match score.
- **Explore**: sort by Best match or Deadline, work-mode filter (Remote / Hybrid / On-site), "days left" on cards.
- **Saved opportunities** page.
- **Similar opportunities** on the details page.
- **Skills**: edit and delete, colour-coded progress, duplicate check.
- **Tracker**: status filter with counts, remove application, badge on the Tracker tab.
- **Profile**: branch, graduation year, target role, about-me; **dark mode**; reset app data.

**Design**
- Soft gradient background with colour blobs on every screen (light and dark versions).
- Gradient hero cards, colour-coded opportunity types, consistent card styling.

## Project structure

```
lib/
  main.dart
  theme/app_theme.dart          colours + light/dark themes
  utils/navigation.dart         openTab / openOpportunity / openSaved helpers
  models/                       Skill, Opportunity, Application
  services/app_store.dart       state, persistence, skill matching
  screens/                      home, dashboard, skills, explore, details, saved, tracker, profile
  widgets/                      app_background, opportunity_card, skill_card, skill_dialog, stat_card, match_badge
```

## Note

The bundled opportunities are sample listings for demonstrating app functionality, not verified live vacancies.
Check each employer's official careers page before applying.
