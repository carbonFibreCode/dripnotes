# DripNotes

DripNotes is a feature-rich note-taking application built with Flutter and Firebase. It provides users with a seamless experience to create, manage, and sync their notes across devices.

## Features

- User authentication (sign up, login, logout)
- Email verification
- Password reset functionality
- Create, read, update, and delete notes
- Real-time synchronization with cloud storage
- Localization support
- Responsive UI with loading indicators

## Tech Stack

- Flutter for cross-platform mobile development
- Firebase Authentication for user management
- Cloud Firestore for database storage
- BLoC pattern for state management

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- Android Studio or VS Code with Flutter plugins

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/dripnotes.git
   ```

2. Navigate to the project directory:
   ```
   cd dripnotes
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Set up Firebase:
   - Create a new Firebase project
   - Add your Firebase configuration files to the project
   - Enable Authentication and Cloud Firestore in your Firebase console

5. Run the app:
   ```
   flutter run
   ```

## Project Structure

- `lib/`
  - `helpers/`: Helper functions and utilities
  - `services/`: Authentication and cloud storage services
  - `view/`: UI screens and components
  - `constants/`: App-wide constants and routes
  - `extensions/`: Dart extensions for added functionality

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

Citations:
[1] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/50460437/032c137c-efc4-4c07-b2b1-2b038a0c01b2/main.dart
[2] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/50460437/7fe4082e-4db7-4e97-b351-d1d11b43786f/auth_bloc.dart
[3] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/50460437/2038a628-c252-4192-be00-a538b56afc01/firebase_cloud_storage.dart
[4] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/50460437/fc048405-7fa4-44d0-b5fc-ac1655be7223/notes_service.dart
