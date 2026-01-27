# MIRA - Mastering Information Retention App

MIRA is a comprehensive Flutter-based mobile application designed to enhance learning and information retention through AI-powered study tools, community collaboration, and personalized study techniques.

## Features

### Study Tools
- **Pomodoro Timer**: Focus enhancement with timed intervals
- **Feynman Technique**: Learn by teaching concepts
- **Flashcards**: Spaced repetition for memorization
- **Mind Maps**: Visual learning and concept mapping
- **Notes**: Organized note-taking
- **Eisenhower Matrix**: Task prioritization
- **Blurting Method**: Active recall technique
- **AI Chat**: Intelligent study assistance powered by Google Generative AI

### Second Brain
- AI-enhanced note storage and retrieval
- Subscription-based tiers (Regular, Plus, Premium)
- Advanced search and organization

### Community & Social
- Community discussions and collaboration
- Real-time chat functionality
- User presence tracking

### Authentication & Security
- Google Sign-In integration
- Local authentication (biometrics)
- Secure storage for sensitive data

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **AI**: Google Generative AI
- **State Management**: GetIt (Dependency Injection)
- **UI/UX**: Google Fonts, Lottie animations, Shimmer effects
- **Additional**: Image Picker, URL Launcher, Flutter Secure Storage

## Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mitcheltastic/mira-mobapp.git
   cd mira-mobapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your Supabase credentials:
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Configure app secrets**
   - Update `lib/core/constant/app_secrets.dart` with your credentials

5. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (on macOS):**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── core/           # Constants, services, utilities, widgets
├── features/       # Feature modules
│   ├── auth/       # Authentication
│   ├── chats/      # Real-time messaging
│   ├── community/  # Community features
│   ├── dashboard/  # Main navigation
│   ├── home/       # Home screen
│   ├── onboarding/ # Splash and onboarding
│   ├── profile/    # User profile
│   ├── second_brain/ # AI-powered notes
│   └── study_tools/ # Study techniques
└── main.dart       # App entry point
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and not intended for public distribution.

## Support

For support or questions, please contact the development team.
