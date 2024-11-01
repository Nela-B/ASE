
# Advanced Software Engineering Project  
## Team 4: To-Do App for Globetrotters

### Project Overview

This is a Flutter-based To-Do App designed for globetrotters to help them manage tasks efficiently. The app supports creating, updating, and tracking main tasks and sub-tasks, with a user-friendly UI and backend integration for seamless data management.

---

## Project Structure

To make the project scalable, we organized the codebase into dedicated folders within the `lib/` directory. This separation improves readability, maintenance, and scalability as the app evolves.

### Folder Breakdown

#### `lib/models/`
- **Purpose**: Stores data models representing the app’s core data structure.
- **Examples**:
  - `task_model.dart`: Defines the main task structure with properties like title, description, priority, due date, etc.
  - `subtask_model.dart`: Defines the structure of a sub-task, including properties like title and completion status.

#### `lib/screens/`
- **Purpose**: Contains UI screens for different parts of the app.
- **Examples**:
  - `task_list_screen.dart`: Displays a list of all tasks.
  - `task_detail_screen.dart`: Shows details of a selected task, including associated sub-tasks and other relevant details.

#### `lib/widgets/`
- **Purpose**: Stores reusable UI components that can be used across multiple screens.
- **Examples**:
  - `task_card.dart`: A card widget that displays a summary of a task.
  - `custom_button.dart`: A custom-styled button widget to ensure consistent UI design.

#### `lib/services/`
- **Purpose**: Contains backend services, API calls, and other non-UI functionalities.
- **Examples**:
  - `task_service.dart`: Service for creating, updating, and retrieving tasks from the backend. This file manages the app’s interaction with external APIs or local data storage.

---

## Getting Started

### Prerequisites

Make sure you have the following installed on your machine:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with Flutter plugins
- Git (for version control)

### Installation

1. **Clone the Repository**  
   Open a terminal and run:
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

2. **Install Dependencies**  
   In the project directory, run:
   ```bash
   flutter pub get
   ```
   This command installs all necessary packages as listed in `pubspec.yaml`.

3. **Set Up Backend (if applicable)**  
   - If the app relies on an external backend, make sure it is set up and running.
   - Update the API endpoint in `lib/services/task_service.dart` with the backend URL.

### Running the App

1. **Run on an Emulator or Physical Device**
   - Connect a physical device via USB, or open an emulator.
   - Run the app with the following command:
     ```bash
     flutter run
     ```
   - Alternatively, launch the app from your IDE by selecting the target device and pressing the **Run** button.

### Testing

To ensure everything is working correctly, you can run tests located in the `test/` directory:
```bash
flutter test
```

---

## Additional Information

### Configurations
- You may update app configurations in `pubspec.yaml` and `AndroidManifest.xml` for Android, or `Info.plist` for iOS.

### Dependencies Used
- **provider**: For state management.
- **http**: For backend communication.
- **flutter_local_notifications** (optional): For handling task notifications.

---

## Contributing

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-branch
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m "Add your message here"
   ```
4. Push to the branch:
   ```bash
   git push origin feature-branch
   ```
5. Open a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
