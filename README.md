# Bovi Mobile App

Bovi is a Flutter application for capturing livestock skin lesion photos for
assessment. It supports taking a photo with the device camera or selecting one
from the gallery, with on-screen framing guidance.

## Development

Install the Flutter SDK required by `pubspec.yaml`, then run:

```bash
flutter pub get
flutter analyze
flutter test
```

To run the app on a connected device:

```bash
flutter run
```

## Backend (account and sync)

The account of the farmer (HU14) and the cloud backup talk to
[bovi-backend](https://github.com/Bovi-DeepLearningSkinDeseaseDetection/bovi-backend).
Its address is chosen when building the app:

```bash
# Android emulator against the backend of docker-compose on the PC (default)
flutter run

# Physical phone on the same Wi-Fi as the PC
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000

# Release against production (HTTPS only)
flutter build apk --dart-define=API_BASE_URL=https://api.bovi.pe
```

Debug builds allow plain `http` to reach the local backend; release builds only
use HTTPS. The session is kept encrypted with the Android Keystore and lets the
farmer use the app offline for up to 30 days.

The contract with the real backend is tested when `BOVI_API_URL` is set:

```bash
BOVI_API_URL=http://localhost:8000 flutter test test/iam/auth_backend_contract_test.dart
```
