import 'dart:math';

/// Playfair anahtar karesinin (key square) boyutu (6x6 = 36 hücre).
const int kGridSize = 6;

/// Türkçe alfabedeki 29 harf (Q, W, X yok; Ç, Ğ, I, İ, Ö, Ş, Ü var).
const List<String> turkishLetters = [
  'A', 'B', 'C', 'Ç', 'D', 'E', 'F', 'G', 'Ğ', 'H', 'I', 'İ', 'J', 'K', 'L',
  'M', 'N', 'O', 'Ö', 'P', 'R', 'S', 'Ş', 'T', 'U', 'Ü', 'V', 'Y', 'Z',
];

/// Anahtar karesine eklenen 7 ekstra noktalama karakteri:
/// boşluk, nokta, virgül, ünlem, soru işareti, iki nokta üst üste,
/// noktalı virgül.
const List<String> extraPunctuation = [' ', '.', ',', '!', '?', ':', ';'];

/// Playfair şifrelemesinde kullanılan tam karakter kümesi: 29 Türkçe
/// harf + 7 noktalama karakteri = 36 karakter (6x6 ızgarayı tam doldurur).
final List<String> playfairAlphabet = [
  ...turkishLetters,
  ...extraPunctuation,
];

/// Playfair şifreleme/şifre çözme için rastlantısal 6x6 **secret key
/// karesi (key square)** üreten sınıf.
///
/// Klasik Hill Cipher'daki sayısal/tersinir matristen farklı olarak,
/// Playfair anahtarı [playfairAlphabet] içindeki 36 karakterin
/// **rastgele bir permütasyonudur**: her karakter ızgarada tam olarak
/// bir kez bulunur, tekrar yoktur ve eksik karakter yoktur. Projenin
/// tüm şifreleme/şifre çözme akışı, üretilen bu 6x6 karakter karesi
/// üzerinden döner.
// tekrarlanabilir sabit sayılar da verilebilir, Random.secure() ile farklı da üretilebilir
class PlayfairKeyGenerator {
  PlayfairKeyGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// [playfairAlphabet] içindeki 36 karakteri rastgele karıştırıp
  /// 6x6'lık bir secret key karesi (List<List<String>>) olarak
  /// döndürür.
  List<List<String>> generateKey() {
    final shuffled = List<String>.from(playfairAlphabet)..shuffle(_random);

    return List.generate(
      kGridSize,
      (row) => shuffled.sublist(row * kGridSize, (row + 1) * kGridSize),
    );
  }

  /// Verilen anahtar karesinin geçerli olup olmadığını kontrol eder:
  /// 6x6 boyutunda olmalı, [playfairAlphabet] içindeki 36 karakterin
  /// her biri tam olarak bir kez bulunmalıdır.
  bool isValidKey(List<List<String>> grid) {
    if (grid.length != kGridSize) return false;
    for (final row in grid) {
      if (row.length != kGridSize) return false;
    }

    final flattened = grid.expand((row) => row).toList();
    if (flattened.length != playfairAlphabet.length) return false;

    final expected = Set<String>.from(playfairAlphabet);
    final actual = Set<String>.from(flattened);
    return flattened.length == actual.length && expected.length == actual.length && expected.containsAll(actual);
  }

  /// Verilen karakterin anahtar karesindeki (satır, sütun) konumunu
  /// döndürür. Şifreleme/şifre çözme algoritmalarında karakter
  /// çiftlerinin konumunu bulmak için kullanılır.
  ///
  /// Karakter karede bulunamazsa `null` döner.
  Point<int>? positionOf(List<List<String>> grid, String char) {
    final upper = char.toUpperCase();
    for (var row = 0; row < grid.length; row++) {
      for (var col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == upper) {
          return Point<int>(row, col);
        }
      }
    }
    return null;
  }
}

/// Üretilen anahtar karesini saklama/aktarma (örn. SharedPreferences,
/// dosya, veritabanı) amacıyla düz metne çevirir.
///
/// Izgara her zaman tam olarak [kGridSize] * [kGridSize] (36) karakter
/// içerdiğinden ve her hücre tek bir karakter olduğundan, herhangi bir
/// ayraç (örn. ',' veya ';') kullanılmaz; bunun nedeni bu karakterlerin
/// kendisinin de [extraPunctuation] kümesinde (yani ızgara içeriğinde)
/// yer alabilmesi ve ayraç olarak kullanılırsa veriyle çakışmasıdır.
/// Bunun yerine karakterler satır satır, sırayla birleştirilir.
String playfairKeyToString(List<List<String>> key) {
  return key.expand((row) => row).join();
}

/// [playfairKeyToString] ile üretilmiş düz metin anahtarı tekrar
/// 6x6 karakter karesine çevirir. Girdinin tam olarak
/// [kGridSize] * [kGridSize] karakter uzunluğunda olması beklenir.
List<List<String>> playfairKeyFromString(String data) {
  final expectedLength = kGridSize * kGridSize;
  if (data.length != expectedLength) {
    throw ArgumentError(
      'Anahtar metni $expectedLength karakter uzunluğunda olmalı, '
      'ancak ${data.length} karakter bulundu.',
    );
  }

  final chars = List.generate(data.length, (i) => data[i]);
  return List.generate(
    kGridSize,
    (row) => chars.sublist(row * kGridSize, (row + 1) * kGridSize),
  );
}
