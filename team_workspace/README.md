# Team Workspace

Team Workspace is a Flutter-based task management application designed with a robust Clean Architecture and offline-first capabilities. It allows users to manage their tasks seamlessly, with automatic synchronization when online.

## 🚀 Getting Started

### Prerequisites
*   **Flutter SDK:** `^3.11.0`
*   **Dart SDK:** Integrated with Flutter
*   **Firebase Project:** A configured Firebase project for Authentication and Data.

### Setup Instructions
1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd team_workspace
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate Code:**
    This project uses `freezed` and `json_serializable`. Generate the necessary files using:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Firebase Configuration:**
    *   Ensure `firebase_options.dart` is correctly configured for your environment.
    *   Initialize Firebase in your platform-specific folders (Android/iOS) if necessary.
5.  **Run the app:**
    ```bash
    flutter run --target lib/app/env/main_dev.dart
    ```

## 🏗 Architecture Overview
The project follows **Clean Architecture** principles combined with the **BLoC (Business Logic Component)** pattern for state management. This ensures a clear separation of concerns, making the app maintainable and testable.

### Layers:
*   **Presentation:** UI widgets, screens, and BLoC components.
*   **Domain:** Business logic, entities, use cases, and repository interfaces. This layer is independent of any other layer.
*   **Data:** Implementation of repositories, data sources (Remote/Local), and data models (Mappers).
*   **Core:** Shared utilities, networking, database configuration, dependency injection, and constants.

## 📂 Core Folder Explanation
The `lib/core` directory contains the foundational components of the application:
*   **di/**: Dependency Injection setup using `get_it`.
*   **network/**: Dio configuration, API clients, and network connectivity checks.
*   **database/**: Local persistence setup using `sqflite`.
*   **error/**: Custom failure and exception handling classes.
*   **usecase/**: Base classes for application use cases.
*   **utils/**: Extensions, formatters, and helper functions.
*   **mappers/**: Logic to convert between Data Models and Domain Entities.
*   **constants/**: Global constants like API endpoints or UI themes.

## 📦 Packages Used
| Package | Version | Purpose |
| :--- | :--- | :--- |
| `flutter_bloc` | `^9.1.1` | State Management |
| `dio` | `^5.10.0` | HTTP Networking |
| `firebase_auth` | `^5.2.0` | Authentication |
| `sqflite` | `^2.3.3+1` | Local Persistence |
| `get_it` | `^9.2.1` | Service Locator (DI) |
| `freezed` | `^3.2.5` | Code Generation for Unions/Data Classes |
| `connectivity_plus` | `^6.0.5` | Network Connectivity Monitoring |
| `equatable` | `^2.1.0` | Value Equality |
| `intl` | `^0.19.0` | Localization and Date Formatting |

## 🛠 VS Code Launch Configuration
Add this to your `.vscode/launch.json` to run the app with different environments:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Team Workspace (Dev)",
            "request": "launch",
            "type": "dart",
            "program": "lib/app/env/main_dev.dart",
            "args": [
                "--dart-define", "APP_ENV=dev",
                "--dart-define", "API_BASE_URL=https://api.dev.teamworkspace.com"
            ]
        },
        {
            "name": "Team Workspace (Prod)",
            "request": "launch",
            "type": "dart",
            "program": "lib/app/env/main_prod.dart",
            "args": [
                "--dart-define", "APP_ENV=prod",
                "--dart-define", "API_BASE_URL=https://api.teamworkspace.com"
            ]
        }
    ]
}
```

## 🔄 App Flow
1.  **Authentication:** Users start at the **Login/Signup** screens (powered by Firebase).
2.  **Dashboard:** Upon successful login, users land on the **Dashboard**, which displays a list of tasks.
    *   Features include **Filtering** (by status/priority) and **Search** queries.
3.  **Create Task:** A dedicated form to add new tasks with titles, descriptions, and due dates.
4.  **View Task:** Detailed view of a specific task's information.
5.  **Edit Task:** Ability to modify existing task details, which syncs to the backend.

## 📝 Assumptions Made
*   **Offline First:** The app assumes that users might work in low-connectivity areas. Tasks are cached locally in `sqflite` and synced via `TaskSyncService`.
*   **Firebase for Auth:** Firebase is the primary source of truth for user sessions.
*   **Environment Specifics:** The app uses different entry points (`main_dev.dart`, `main_prod.dart`) to handle environment-specific configurations.
*   **Dependency Injection:** All services and repositories are managed via `get_it` for easy mocking in tests.
