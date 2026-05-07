<div align="center">

  <img src="./doc/morse-code.logo.png" alt="logo" width="200" height="auto" />
  <h1>Morse-Code</h1>

  <p>
    <a href="https://github.com/petrubraha/morse-code/graphs/contributors">
      <img src="https://img.shields.io/github/contributors/petrubraha/morse-code" alt="contributors" />
    </a>
    <a href="">
      <img src="https://img.shields.io/github/last-commit/petrubraha/morse-code" alt="last update" />
    </a>
    <a href="https://github.com/petrubraha/morse-code/network/members">
      <img src="https://img.shields.io/github/forks/petrubraha/morse-code" alt="forks" />
    </a>
    <a href="https://github.com/petrubraha/morse-code/stargazers">
      <img src="https://img.shields.io/github/stars/petrubraha/morse-code" alt="stars" />
    </a>
    <a href="https://github.com/petrubraha/morse-code/issues/">
      <img src="https://img.shields.io/github/issues/petrubraha/morse-code" alt="open issues" />
    </a>
    <a href="https://github.com/petrubraha/morse-code/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/petrubraha/morse-code.svg" alt="license" />
    </a>
  </p>
   
  <h4>
      <a href="./doc/requirements.md">System requirments</a>
    <span> · </span>
      <a href="https://github.com/petrubraha/morse-code/issues/">Report Bug</a>
    <span> · </span>
      <a href="https://github.com/petrubraha/morse-code/issues/">Request Feature</a>
  </h4>
</div>

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
