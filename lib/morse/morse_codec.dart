import 'morse_constants.dart';

class MorseCodec {
  static final Map<String, String> _decryptionMap = _buildDecryptionMap();

  static Map<String, String> _buildDecryptionMap() {
    final map = <String, String>{};
    for (final entry in morseEncryption.entries) {
      if (entry.key == ' ') continue;
      map[entry.value] = entry.key;
    }
    return map;
  }

  static String sanitize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String encrypt(String rawInput) {
    final input = sanitize(rawInput);
    if (input.isEmpty) {
      throw ArgumentError('Input cannot be empty.');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      final code = morseEncryption[char];
      if (code == null) {
        throw ArgumentError('Unsupported character: "${input[i]}"');
      }

      if (i > 0 && char != ' ' && input[i - 1] != ' ') {
        buffer.write(letterGap);
      }
      buffer.write(code);
    }
    return buffer.toString();
  }

  static String decrypt(String morseInput) {
    final input = morseInput.trim();
    if (input.isEmpty) {
      throw ArgumentError('Input cannot be empty.');
    }

    final words = input.split(' $wordGap ');
    final decryptedWords = <String>[];

    for (final word in words) {
      final letters = word.split(letterGap);
      final decryptedLetters = <String>[];

      for (final letter in letters) {
        final trimmed = letter.trim();
        if (trimmed.isEmpty || trimmed == wordGap) continue;

        final char = _decryptionMap[trimmed];
        if (char == null) {
          throw ArgumentError('Invalid morse sequence: "$trimmed"');
        }
        decryptedLetters.add(char);
      }

      if (decryptedLetters.isNotEmpty) {
        decryptedWords.add(decryptedLetters.join());
      }
    }

    return decryptedWords.join(' ');
  }
}
