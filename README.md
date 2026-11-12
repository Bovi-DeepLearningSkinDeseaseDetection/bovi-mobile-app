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

### Cloud backup (HU12)

Evaluations and animals are backed up on their own: when the phone gets a
connection back, two minutes after a new analysis (time to assign the animal;
once in the cloud an evaluation can no longer change), when the app comes to
the front, every 15 minutes, and with the app closed through WorkManager.
Photos go straight to S3 with the presigned POST, never through the backend.

To test it against the local backend, the presigned URLs must point to an
address the phone can reach. In `bovi-backend/docker-compose.yml` set
`S3_PUBLIC_ENDPOINT_URL` for the `api` service:

- Android emulator: `http://10.0.2.2:9000`
- Phone on the same Wi-Fi: `http://<PC IP>:9000` (and run the app with
  `--dart-define=API_BASE_URL=http://<PC IP>:8000`)

Contract test of the whole sync with the real backend and RustFS:

```bash
BOVI_API_URL=http://localhost:8000 flutter test test/clinical/sync_backend_contract_test.dart
```
