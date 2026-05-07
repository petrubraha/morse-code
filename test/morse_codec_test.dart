import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code/morse/morse_codec.dart';

void main() {
  group('MorseCodec Encryption', () {
    test('encrypts a simple word "SOS"', () {
      expect(MorseCodec.encrypt('SOS'), '... ___ ...');
    });

    test('is case-insensitive', () {
      expect(MorseCodec.encrypt('sos'), '... ___ ...');
      expect(MorseCodec.encrypt('Sos'), '... ___ ...');
    });

    test('encrypts multiple words "HELLO WORLD"', () {
      // H: .... E: . L: ._.. L: ._.. O: ___
      // W: .__ O: ___ R: ._. L: ._.. D: _..
      expect(
        MorseCodec.encrypt('HELLO WORLD'),
        '.... . ._.. ._.. ___ / .__ ___ ._. ._.. _..',
      );
    });

    test('encrypts numbers', () {
      expect(MorseCodec.encrypt('123'), '.____ ..___ ...__');
    });

    test('sanitizes input with extra spaces', () {
      expect(MorseCodec.encrypt('  SOS   '), '... ___ ...');
      expect(MorseCodec.encrypt('  \t \t SOS \n \n  '), '... ___ ...');
      expect(
        MorseCodec.encrypt(' \n\n HELLO    WORLD \n\n'),
        '.... . ._.. ._.. ___ / .__ ___ ._. ._.. _..',
      );
    });

    test('throws ArgumentError for empty input', () {
      expect(() => MorseCodec.encrypt(''), throwsArgumentError);
      expect(() => MorseCodec.encrypt('   '), throwsArgumentError);
    });

    test('throws ArgumentError for unsupported characters', () {
      expect(() => MorseCodec.encrypt('HELLO\$'), throwsArgumentError);
    });
  });

  group('MorseCodec Decryption', () {
    test('decrypts "..." to "S"', () {
      expect(MorseCodec.decrypt('...'), 'S');
    });

    test('decrypts "... ___ ..."', () {
      expect(MorseCodec.decrypt('... ___ ...'), 'SOS');
    });

    test('decrypts multiple words with "/"', () {
      expect(
        MorseCodec.decrypt('.... . ._.. ._.. ___ / .__ ___ ._. ._.. _..'),
        'HELLO WORLD',
      );
    });

    test('decrypts numbers', () {
      expect(MorseCodec.decrypt('.____ ..___ ...__'), '123');
    });

    test('throws ArgumentError for empty input', () {
      expect(() => MorseCodec.decrypt(''), throwsArgumentError);
      expect(() => MorseCodec.decrypt('   '), throwsArgumentError);
    });

    test('throws ArgumentError for invalid morse sequences', () {
      expect(() => MorseCodec.decrypt('........'), throwsArgumentError);
    });
  });

  group('MorseCodec Round-trip', () {
    test(
      'encrypt and then decrypt returns the original string (uppercase)',
      () {
        const input = 'HELLO WORLD 123';
        final encrypted = MorseCodec.encrypt(input);
        final decrypted = MorseCodec.decrypt(encrypted);
        expect(decrypted, input);
      },
    );

    test('handles complex punctuation round-trip', () {
      const input = 'HELP! SOS?';
      final encrypted = MorseCodec.encrypt(input);
      final decrypted = MorseCodec.decrypt(encrypted);
      expect(decrypted, input);
    });
  });
}
