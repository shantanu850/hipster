# Hipster

Hipster is a feature-rich Flutter application that seamlessly integrates with the Amazon Chime SDK to provide real-time audio and video meeting capabilities. Designed with a clean, feature-driven architecture and robust state management, this project serves as a comprehensive starting point or reference for building scalable video conferencing apps in Flutter.

## Features

- **Amazon Chime SDK Integration**: Native audio/video call engine utilizing official backend session endpoints.
- **Hardware Camera Controls**: Start/stop local camera capture seamlessly via floating call controls.
- **Mute / Unmute Microphone**: Toggle microphone stream natively on/off with color-coded button feedback.
- **Dual-Camera Switching**: Toggle between front and rear cameras instantly during active meetings.
- **Audio Output Routing**: Modal bottom sheet selector for Speaker, Earpiece/Handset, and Bluetooth output devices.
- **Participants List**: Top-bar badge showing joined participants categorized by Client vs Agent.
- **Share Invitations**: Popup menu to copy Meeting ID or share invitation card via native OS share sheets.
- **Events Logs**: Sliding panel logging real-time call lifecycle state transitions.
- **Robust State Management**: Powered by Riverpod to handle complex meeting states efficiently.
- **Scalable Architecture**: Codebase is separated into `core` modules and `features` to ensure high cohesion and loose coupling.
- **Custom Native Integration**: Uses a specialized local plugin to interface with native iOS and Android Chime SDKs, ensuring maximum flexibility and stability.

## Setup

To set up this project locally, follow these steps:

1. Ensure you have the Flutter SDK installed (version `^3.11.4` or later).
2. Clone this repository to your local machine.
3. Open a terminal and navigate to the project directory.
4. Run `flutter pub get` to install all dependencies.
5. Note: This project uses a custom local plugin for Amazon Chime located in `./plugins/flutter_amazon_chime`. We are using this local version to patch a specific bug in the upstream package that was causing the app to crash when joining a meeting via code. Ensure this directory exists and is populated.
6. When running the application, you must provide your API key in the environment. You can do this by using the `--dart-define` flag.
7. Run `flutter run --dart-define=api_key=your_api_key_here` to launch the app on your connected device or emulator.

## Core Architecture

This project follows a **feature-driven architectural pattern**. The codebase is separated into main categories such as `core` and `features`.

- **Core**: Contains the foundational elements of the application that are shared across multiple features. This includes API clients, Chime integration logic, constants, themes, and utility functions.
- **Features**: Contains the UI and business logic for specific functional areas of the app (e.g., dashboard, meeting). Each feature is self-contained to promote modularity.

## Folder Structure

The `lib/` directory is structured as follows:

```text
lib/
├── core/
│   ├── api/        # API communication services
│   ├── chime/      # Amazon Chime SDK integration logic
│   ├── constants/  # Global constants and configuration
│   ├── theme/      # App-wide theme and styling definitions
│   └── utils/      # Helper functions and utilities
├── features/
│   ├── dashboard/  # Dashboard screen and related logic
│   └── meeting/    # Meeting screen and related logic
├── res/            # Resources such as images, icons, or fonts configurations
└── main.dart       # Application entry point
```

## State Management

This project uses **Riverpod** (`flutter_riverpod`) for state management. Riverpod provides a robust, compile-safe, and scalable way to manage state and dependencies across the application.

- **Providers** are used to expose state, APIs, and services.
- **Consumer widgets** are used in the UI to listen to state changes and rebuild efficiently when data updates.
