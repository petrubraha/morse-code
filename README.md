# Morse Code Flasher & SMS

A Flutter application that encrypts text into Morse code, flashes it via the phone's LED, sends it as SMS, and decrypts received Morse code messages.

## Features

- **Morse Encryption/Decryption** — Converts plaintext to Morse code and back, supporting A–Z, 0–9, and common punctuation.
- **LED Flashing** — Flashes the device torch using standard Morse timing (dit = 1 unit, dah = 3 units, letter gap = 3 units, word gap = 7 units).
- **SMS Sending** — Sends the encoded Morse string to a phone number via native Android SMS API.
- **SMS Receiving** — Listens for incoming SMS and auto-decrypts Morse code messages.

## Dependencies

| Package              | Purpose                          |
| -------------------- | -------------------------------- |
| `torch_light`        | Torch/flashlight control         |
| `permission_handler` | Runtime permission requests      |
| Native MethodChannel | SMS send/receive via Android API |

## Project Structure

```
lib/
├── main.dart                      # App entry, theme, screen routing
├── morse/
│   ├── morse_constants.dart       # Morse code lookup tables
│   └── morse_codec.dart           # Encrypt/decrypt functions
├── services/
│   ├── flash_service.dart         # Torch control with timing
│   └── sms_service.dart           # MethodChannel SMS bridge
├── screens/
│   ├── phone_screen.dart          # Phone number input (step 1)
│   └── message_screen.dart        # Message input + flash (step 2)
└── widgets/
    ├── notification_overlay.dart   # Top-right notification toasts
    └── processing_modal.dart       # Flash indicator modal
```

## Building & Running

### Prerequisites

- Flutter SDK 3.10+
- Android SDK with API 21+ (for mobile)
- Enable Developer Mode on Windows for symlinks: `start ms-settings:developers`

### Mobile (Android)

```bash
flutter pub get
flutter run
```

When prompted, grant SMS and Camera permissions.

### Desktop — Windows

```bash
flutter pub get
flutter run -d windows
```

**Mocking on desktop:**

- **Flashing** — `torch_light` gracefully degrades; the flash indicator in the processing modal still animates to show timing.
- **SMS** — The native MethodChannel call will throw a `PlatformException` on Windows (no SMS hardware). The app catches this and shows an error notification. To test end-to-end, use an Android emulator or physical device.
- **SMS Receiving** — On desktop, the incoming SMS stream will simply never fire. The notification overlay remains ready to display decrypted messages.

### Testing the Morse algorithms without a device

Open `dartpad.dev` or run from CLI:

```bash
dart run lib/morse/morse_codec.dart
```

Or add a quick main:

```dart
import 'lib/morse/morse_codec.dart';

void main() {
  final encrypted = MorseCodec.encrypt('HELLO');
  print(encrypted); // .... . ._.. ._.. ___
  final decrypted = MorseCodec.decrypt(encrypted);
  print(decrypted); // HELLO
}
```

## Workflow

1. Enter the recipient phone number → validated, saved
2. Compose a plaintext message → validated for supported characters
3. The app opens a modal, flashes each character via the torch, and displays the character + its Morse code in real time
4. After flashing, the full Morse string is sent as SMS
5. When an SMS is received, it is auto-decrypted and shown in the top-right notification overlay
6. The user returns to step 2 to send another message, or navigates back to change the number

## Permissions (Android)

- `SEND_SMS` — to send the Morse-encoded message
- `RECEIVE_SMS` / `READ_SMS` — to listen for and read incoming Morse messages
- `CAMERA` — required by `torch_light` to access the flashlight
