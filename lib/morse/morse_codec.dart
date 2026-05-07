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
    return input.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  }

  static String encrypt(String rawInput) {
    final input = sanitize(rawInput);
    if (input.isEmpty) {
      throw ArgumentError('Input cannot be empty.');
    }

    final buffer = StringBuffer();
    String code = _getCode(input, 0);
    buffer.write(code);

    for (int i = 1; i < input.length; i++) {
      code = _getCode(input, i);
      buffer.write(letterGap);
      buffer.write(code);
    }
    return buffer.toString();
  }

  static String _getCode(String input, int index) {
    final char = input[index];
    final code = morseEncryption[char];
    if (code == null) {
      throw ArgumentError('Unsupported character: "${input[index]}"');
    }

    return code;
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
