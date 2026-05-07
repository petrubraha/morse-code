# Morse-Code

A Flutter application that encrypts text into Morse code, flashes it via the phone's LED, sends it as SMS, and decrypts received Morse code messages.

## ✨ Features

- **Morse Encryption/Decryption** — Converts plaintext to Morse code and back, supporting A–Z, 0–9, and common punctuation.
- **LED Flashing** — Flashes the device torch using standard Morse timing (dit = 1 unit, dah = 3 units, letter gap = 3 units, word gap = 7 units).
- **SMS Sending** — Sends the encoded Morse string to a phone number via native Android SMS API.
- **SMS Receiving** — Listens for incoming SMS and auto-decrypts Morse code messages.

## 🛠 Build Instructions

### Prerequisites

- Flutter SDK 3.10+
- Android SDK with API 21+ (for mobile)
- Enable Developer Mode on Windows for symlinks: `start ms-settings:developers`

### Execution

1. **Install dependencies:**

```bash
flutter pub get
```

2. **Run application:**

```bash
flutter run
```

When prompted, grant SMS permissions. See the required permission list [here](./android/app/src/main/AndroidManifest.xml).

3. **Mocking on desktop:**

- **Flashing** — `torch_light` gracefully degrades; the flash indicator in the processing modal still animates to show timing.
- **SMS** — The native MethodChannel call will throw a `PlatformException` on Windows (no SMS hardware). The app catches this and shows an error notification. To test end-to-end, use an Android emulator or physical device.
- **SMS Receiving** — On desktop, the incoming SMS stream will simply never fire. The notification overlay remains ready to display decrypted messages.

## Workflow

1. Enter the recipient phone number → validated, saved
2. Compose a plaintext message → validated for supported characters
3. The app opens a modal, flashes each character via the torch, and displays the character + its Morse code in real time
4. After flashing, the full Morse string is sent as SMS
5. When an SMS is received, it is auto-decrypted and shown in the top-right notification overlay
