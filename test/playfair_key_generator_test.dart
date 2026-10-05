import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/crypto/playfair_key_generator.dart';

void main() {
  group('playfairAlphabet', () {
    test('contains exactly 36 characters (29 letters + 7 punctuation)', () {
      expect(turkishLetters.length, equals(29));
      expect(extraPunctuation.length, equals(7));
      expect(playfairAlphabet.length, equals(36));
    });

    test('has no duplicate characters', () {
      expect(playfairAlphabet.toSet().length, equals(playfairAlphabet.length));
    });
  });

  group('PlayfairKeyGenerator', () {
    test('generates a 6x6 grid', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();

      expect(key.length, equals(kGridSize));
      for (final row in key) {
        expect(row.length, equals(kGridSize));
      }
    });

    test('generated key contains every character of playfairAlphabet exactly once', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();
      final flattened = key.expand((row) => row).toList();

      expect(flattened.length, equals(playfairAlphabet.length));
      expect(flattened.toSet(), equals(playfairAlphabet.toSet()));
    });

    test('generated key passes isValidKey', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();

      expect(generator.isValidKey(key), isTrue);
    });

    test('isValidKey rejects a grid with duplicate characters', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();
      // Introduce a duplicate by overwriting one cell with another cell's value.
      final tampered = key.map((row) => List<String>.from(row)).toList();
      tampered[0][0] = tampered[1][1];

      expect(generator.isValidKey(tampered), isFalse);
    });

    test('isValidKey rejects wrong-size grids', () {
      final generator = PlayfairKeyGenerator();
      final tooSmall = [
        ['A', 'B'],
        ['C', 'D'],
      ];

      expect(generator.isValidKey(tooSmall), isFalse);
    });

    test('generates different grids across calls (randomness)', () {
      final generator = PlayfairKeyGenerator();
      final key1 = generator.generateKey();
      final key2 = generator.generateKey();

      expect(key1, isNot(equals(key2)));
    });

    test('positionOf finds the correct row/column for a character', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();

      for (var row = 0; row < kGridSize; row++) {
        for (var col = 0; col < kGridSize; col++) {
          final char = key[row][col];
          final pos = generator.positionOf(key, char);
          expect(pos, isNotNull);
          expect(pos!.x, equals(row));
          expect(pos.y, equals(col));
        }
      }
    });

    test('positionOf returns null for a character not in the grid', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();

      expect(generator.positionOf(key, '#'), isNull);
    });

    test('playfairKeyToString / playfairKeyFromString round trip', () {
      final generator = PlayfairKeyGenerator();
      final key = generator.generateKey();

      final encoded = playfairKeyToString(key);
      expect(encoded.length, equals(kGridSize * kGridSize));

      final decoded = playfairKeyFromString(encoded);
      expect(decoded, equals(key));
    });

    test('playfairKeyFromString throws on invalid length input', () {
      expect(() => playfairKeyFromString('TOO_SHORT'), throwsArgumentError);
    });
  });
}
