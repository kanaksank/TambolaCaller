# Tambola Caller

A large-format, fully offline number caller for Tambola / Housie, built with Flutter and Material 3.

Made for the person running the game in a room: one enormous number, one big button, and a clear
voice announcement for every call. No login, no internet, no server.

## Features

- **Huge, readable number.** The current call fills the screen and scales to whatever space is available.
- **Never repeats.** Numbers are drawn only from 1–90 and never twice in the same game.
- **Voice announcements** through the device's built-in text-to-speech:
  - `1–9` → *"Single number, number 5; I repeat, number 5."*
  - `10–90` → *"Number 67; 6 and 7, number 67."*
  - Repeated digits stay digits — *"Number 77; 7 and 7, number 77."* The phrase "double number" is never used.
- **Repeat button** replays the announcement without drawing a new number.
- **Voice controls** — on/off toggle and a Slow · Normal · Fast speed slider that defaults slightly
  slower than normal so a noisy room can follow every digit.
- **Number board** — all 90 numbers in a 10-column grid. Called numbers are filled and check-marked,
  the current number is ringed and glowing, so states never depend on colour alone.
- **Recent numbers** with the newest call highlighted.
- **Game persistence** — the called list, current number and settings survive the app being closed.
- **Landscape first**, portrait fully supported.

## Screens

| Screen | What it does |
| --- | --- |
| **Caller** | Current number, announcement text, `GENERATE NUMBER`, `REPEAT NUMBER`, recent calls, called counter, game controls |
| **Number Board** | The full 1–90 grid with called / current / uncalled states and a legend |

Game controls (voice, speed, reset, new game) live behind the settings icon in the header. Starting a
new game always asks for confirmation first.

## Running it

```bash
flutter pub get
flutter run                # debug on a connected device
flutter build apk --release
```

Requires Flutter 3.24 or newer (Dart 3.5+). Dependencies: [`flutter_tts`](https://pub.dev/packages/flutter_tts)
for the voice and [`shared_preferences`](https://pub.dev/packages/shared_preferences) for local game state —
both work entirely on-device.

## Tests

```bash
flutter analyze
flutter test
```

The calling rules, the no-repeat guarantee, persistence and the main screens are covered by unit and
widget tests, none of which touch the platform text-to-speech engine.

## Project layout

```
lib/
├── main.dart                     # bootstrap: orientation, controller, saved game
├── app.dart                      # MaterialApp + welcome/home routing
├── models/                       # Announcement, PersistedGame
├── services/
│   ├── announcement_builder.dart # the calling rules, in one testable place
│   ├── game_controller.dart      # all game logic (ChangeNotifier)
│   ├── game_storage.dart         # shared_preferences persistence
│   └── voice_service.dart        # text-to-speech behind an interface
├── state/game_scope.dart         # InheritedNotifier — no state-management package
├── screens/                      # welcome, home shell, caller, board
├── theme/app_theme.dart          # Material 3 palette and shared styles
└── widgets/                      # number ball, buttons, grid, recent numbers, settings sheet
```

Business logic never touches Flutter widgets, and the UI never contains game rules — which is why the
whole rule set can be tested without a device.

## Before publishing to Play Store

1. Replace the placeholder launcher icon. It is currently a vector tambola ball
   (`android/app/src/main/res/drawable/ic_launcher_foreground.xml` plus the adaptive icon in
   `mipmap-anydpi-v26/`). The easiest swap: drop a 1024×1024 PNG into `assets/icon/`, add
   [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) to `dev_dependencies`
   and run `dart run flutter_launcher_icons`.
2. Set a real `applicationId` in `android/app/build.gradle.kts` (currently `com.example.tambola_caller`).
3. Add a release signing config — the release build currently signs with the debug key.
