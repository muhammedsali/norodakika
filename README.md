# 🧠 NöroDakika
### Cognitive Training Mobile Application

> **Flutter · Firebase · Riverpod · Material 3**
> 12 Mini Games · 7 Cognitive Domains · Adaptive Difficulty

---

## 📖 Overview

**NöroDakika** is a Flutter-based mobile application designed to train and develop cognitive skills through engaging mini-games. The app targets 7 distinct cognitive domains — Memory, Attention, Reflex, Logic, Numerical Intelligence, Visual Perception, and Language — with 12 unique Flutter-powered games.

The platform features an **ELO-style adaptive difficulty system** that adjusts to each player's performance, ensuring a consistently challenging and personalized training experience. Progress is visualized through a **radar chart**, giving users a clear picture of their cognitive profile over time.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🧠 **7 Cognitive Categories** | Memory, Attention, Reflex, Logic, Numerical Intelligence, Visual Perception, Language |
| 🎮 **12 Mini Games** | All games built natively in Flutter as widgets — no WebView, no plugins |
| 📊 **Adaptive Difficulty** | ELO-based scoring system adjusts difficulty based on user performance |
| 📈 **Radar Chart Progress** | Visual cognitive profile tracking with `fl_chart` |
| 📅 **Daily Plan System** | Personalized daily training plans targeting weak areas |
| 🔥 **Firebase Backend** | Authentication (Email/Password) + Cloud Firestore for data persistence |
| 🎨 **Material 3 UI** | Modern design system with Google Fonts integration |
| 💾 **Local Storage** | Offline-capable session storage via SharedPreferences |
| 👤 **User Profiles** | Custom avatars and per-user statistics |
| 🌐 **Multi-language Support** | Language and theme providers via Riverpod |

---

## 🎮 Games

| ID | Game | Category | Description |
|---|---|---|---|
| REF01 | **Reflex Tap** | Reflex | Measures raw reaction time to on-screen stimuli |
| REF02 | **Reflex Dash** | Reflex | Tap moving targets on horizontal lanes |
| ATT01 | **Stroop Tap** | Attention | Color-word interference — tap by color, not word |
| ATT02 | **Focus Line** | Attention | Track and tap colored dots on a moving line |
| MEM01 | **N-Back Mini** | Memory | Working memory test — match stimuli from N steps back |
| MEM02 | **Memory Board** | Memory | Classic card-matching memory game |
| MEM03 | **Recall Phase** | Memory | Memorize and recall a list of words |
| MEM04 | **Sequence Echo** | Memory | Repeat a displayed cell sequence from memory |
| LOG01 | **Logic Puzzle** | Logic | Identify and complete logical sequences |
| NUM01 | **Quick Math** | Numerical | Time-pressured mental arithmetic challenges |
| VIS02 | **Odd One Out** | Visual | Find the card that does not match the group |
| LANG02 | **Word Sprint** | Language | Distinguish real words from made-up words rapidly |

---

## 🛠️ Tech Stack

| Layer | Technology | Details |
|---|---|---|
| Framework | Flutter | 3.0+ |
| Language | Dart | Latest stable |
| State Management | Riverpod | `flutter_riverpod ^2.5.1` |
| Auth | Firebase Authentication | Email / Password |
| Database | Cloud Firestore | Game results & user stats |
| Local Storage | SharedPreferences | Session & settings cache |
| Charts | fl_chart | Radar chart for cognitive profile |
| Networking | dio / http | API communication |
| UI | Material 3 + Google Fonts | Modern design system |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── memory/                    # App-wide memory bank & docs
│   ├── models/                    # Data models (user, game, attempt)
│   ├── api/                       # API service layer
│   ├── config/                    # App configuration
│   └── utils/constants.dart       # Global constants
├── features/
│   ├── auth/                      # Login & Register screens + provider
│   ├── welcome/                   # Splash & welcome screens
│   ├── home/                      # Home screen + bottom navigation
│   ├── daily_plan/                # Daily training plan
│   ├── game_launcher/             # Game list, launcher & 12 game widgets
│   ├── stats/                     # Radar chart & statistics screen
│   ├── profile/                   # User profile & avatar
│   ├── settings/                  # Theme & language providers
│   └── shared/                    # Shared widgets (game cards etc.)
├── services/
│   ├── auth_service.dart          # Firebase Authentication
│   ├── firestore_service.dart     # Firestore CRUD operations
│   └── local_storage_service.dart # SharedPreferences wrapper
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or later
- Dart SDK *(bundled with Flutter)*
- Android Studio or VS Code with Flutter extension
- A Firebase project *(free tier works fine)*
- Android emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/muhammedsali/norodakika.git
   cd norodakika
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a project at [firebase.google.com](https://firebase.google.com)
   - Enable **Email/Password Authentication**
   - Enable **Cloud Firestore**
   - Download `google-services.json` → `android/app/`
   - Download `GoogleService-Info.plist` → `ios/Runner/` *(iOS only)*

4. **Add assets**
   - Place images in `assets/images/`
   - Place icons in `assets/icons/`
   - Place game art in `assets/games/`

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 User Flow

1. App launches → **Splash Screen** (3 seconds)
2. **Auth Gate** checks login state
3. Not logged in → **Login / Register** screen
4. Logged in → **Home Screen** with 4 tabs:
   - **Home** — Daily plan card, quick-start games, stats summary
   - **Games** — Full list of all 12 mini games
   - **Progress** — Radar chart with per-domain scores
   - **Settings** — Profile, daily plan, and stats links
5. Select a game → Game runs as a Flutter widget
6. Game ends → Result saved to Firestore → Difficulty recalculated automatically

---

## 🏗️ Architecture Notes

- **State Management** — All state handled by Riverpod providers; no raw `setState` in business logic
- **Games** — Every mini game is a self-contained Flutter widget in `features/game_launcher/widgets/`
- **Memory Bank** — `lib/core/memory/memory_bank.dart` is the single source of truth for app constants
- **Adaptive Difficulty** — ELO-style rating updated in Firestore after every game attempt
- **Offline Support** — SharedPreferences caches session data so the app functions without a connection

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push and open a Pull Request

---

## 📄 License

This project is privately developed. All rights reserved by the author.  
Contact the repository owner for usage permissions.

---

## 👤 Author

**Muhammed Sali** — [github.com/muhammedsali](https://github.com/muhammedsali)

---

*Train your brain, one minute at a time. 🧠⚡*
