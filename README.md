# Tambola Caller

A large-format, fully offline number caller for Tambola / Housie, built with Flutter and Material 3.

Made for the person running the game in a room: one enormous number, one big button, and a clear
voice announcement for every call. No login, no internet, no server.

## Features

- **Huge, readable number.** The current call fills the circle and scales to whatever space is available.
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
- **Orientation is the caller's choice** — Auto, Landscape or Portrait, remembered between sessions,
  with a one-tap switch in the header. Landscape gives the biggest number; portrait suits calling
  one-handed.
- **Printable ticket books** — generate A4 PDFs of Housie tickets, 12 to a page, print or share them
  straight from the app. See [Ticket printing](#ticket-printing).

## Screens

| Screen | What it does |
| --- | --- |
| **Caller** | Current number, announcement text, `GENERATE NUMBER`, `REPEAT NUMBER`, recent calls, called counter, game controls |
| **Number Board** | The full 1–90 grid with called / current / uncalled states and a legend |
| **Tickets** | Page count, sample ticket, `GENERATE PDF`, then preview / print / share |

Game controls (voice, speed, orientation, reset, new game) live behind the settings icon in the
header. Starting a new game always asks for confirmation first.

## Running it

```bash
flutter pub get
flutter run                # debug on a connected device
flutter build apk --release
```

Requires Flutter 3.24 or newer (Dart 3.5+). The Android build targets the toolchain that ships with
current stable Flutter: Gradle 9.3.1, Android Gradle Plugin 9.1.0, Kotlin 2.4.0 and JDK 17+.
Dependencies: [`flutter_tts`](https://pub.dev/packages/flutter_tts) for the voice,
[`shared_preferences`](https://pub.dev/packages/shared_preferences) for local game state, and
[`pdf`](https://pub.dev/packages/pdf) + [`printing`](https://pub.dev/packages/printing) for the
ticket sheets — all of which work entirely on-device.

## Ticket printing

The **Tickets** tab turns out print-ready A4 sheets of Housie tickets: 12 tickets per page, three
across and four down, with cutting guides in the gutters and a `T001` identifier on each ticket.

**Strips, not loose tickets.** Tickets are never generated independently. Each group of six is a
*strip* that between them carries all 90 numbers exactly once, so a strip guarantees exactly one full
house. A page holds two independent strips; ten pages is 20 strips and 120 tickets.

The generator works in three steps:

1. **Share out each column.** Column 1 holds nine numbers (1–9), columns 2–8 ten each, column 9
   eleven (80–90). Every ticket takes at least one number from every column — that is six of them —
   and the remainder are dealt in shares of one or two, mostly ones, so two numbers in a column is
   the common case and a full column of three stays occasional. Each ticket's nine columns must add
   up to exactly 15.
2. **Choose rows.** A column taking *k* numbers occupies *k* of the three rows. Columns are placed
   widest first into the rows with the most space left, which lands every row on exactly five.
3. **Deal the numbers.** Each column's numbers are shuffled once for the whole strip, dealt out in
   order, then sorted top to bottom within each ticket's column.

Anything that cannot satisfy the constraints is discarded and retried; in a 100,000-strip stress run
the algorithm never failed, and averaged 1.9 attempts per strip.

**Validation** runs before anything is rendered — `TicketValidation` checks rows, columns, counts,
ranges, ordering and duplicates per ticket; 1–90 coverage per strip; two strips and twelve tickets
per page. The PDF generator refuses to render a document that fails, and the A4 layout itself is
checked to fit the printable area before a line is drawn.

Everything is drawn as vector text and lines using built-in Helvetica, so numbers stay sharp at any
print resolution and the file carries no embedded font or bitmaps. Long runs are built on a
background isolate so the UI never stalls.

## Tests

```bash
flutter analyze
flutter test
```

The calling rules, the no-repeat guarantee, persistence, ticket generation, strip coverage, the A4
layout and the main screens are covered by unit and widget tests, none of which touch the platform
text-to-speech engine or a printer.

## Project layout

```
lib/
├── main.dart                     # bootstrap: orientation, controller, saved game
├── app.dart                      # MaterialApp, orientation lock, welcome/home routing
├── models/                       # Announcement, PersistedGame, OrientationMode, HousieTicket
├── services/
│   ├── announcement_builder.dart # the calling rules, in one testable place
│   ├── game_controller.dart      # all game logic (ChangeNotifier)
│   ├── game_storage.dart         # shared_preferences persistence
│   ├── orientation_service.dart  # preference -> DeviceOrientation list
│   ├── ticket_generator.dart     # six-ticket Housie strips
│   ├── ticket_validation.dart    # every ticket, strip and page rule
│   ├── ticket_pdf_generator.dart # A4 layout and vector PDF rendering
│   └── voice_service.dart        # text-to-speech behind an interface
├── state/game_scope.dart         # InheritedNotifier — no state-management package
├── screens/                      # welcome, home shell, caller, board, tickets, pdf preview
├── theme/app_theme.dart          # Material 3 palette and shared styles
└── widgets/                      # number ball, buttons, grid, recent numbers, settings, tickets
```

Business logic never touches Flutter widgets, and the UI never contains game rules — which is why the
whole rule set can be tested without a device.

## Before publishing to Play Store

1. Generate the launcher icon from `assets/icon/`:

   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

   `icon.png` is the square icon and `icon_foreground.png` the adaptive foreground — both are read
   only at build time. The generator fills `android/app/src/main/res/mipmap-*/` and rewrites the
   adaptive icon and `values/colors.xml`; commit what it produces. Two placeholder vectors
   (`mipmap/ic_launcher.xml` and `drawable/ic_launcher_foreground.xml`) are then unused and can be
   deleted. Foreground art needs generous padding — Android masks adaptive icons to a circle, squircle
   or rounded square depending on the launcher, and `adaptive_icon_foreground_inset` only adds 16%.
2. Set a real `applicationId` in `android/app/build.gradle.kts` (currently `com.example.tambola_caller`).
3. Add a release signing config — the release build currently signs with the debug key. `flutter build
   appbundle --release` works without one, but Play will not accept a debug-signed bundle.
