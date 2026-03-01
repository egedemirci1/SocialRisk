import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Avatar fotoğraflarını Firebase Storage'a yüklemeden önce sıkıştıran yardımcı sınıf.
///
/// Algoritma:
/// 1. Gelen byte'ları decode et
/// 2. Boyutu [maxDimension]×[maxDimension]'a küçült (varsayılan 256px)
/// 3. JPEG olarak encode et, kaliteyi iteratif düşürerek [maxSizeBytes]'ın altına getir
class ImageCompressor {
  /// Varsayılan max boyut: 1 MB
  static const int defaultMaxSizeBytes = 1024 * 1024;

  /// Varsayılan max piksel boyutu (avatar için 256 yeterli)
  static const int defaultMaxDimension = 256;

  /// Kalite seviyeleri — yüksekten düşüğe denenecek
  static const List<int> _qualitySteps = [85, 70, 55, 40, 25];

  /// Verilen [bytes]'ı sıkıştırır.
  ///
  /// - [maxSizeBytes]: Hedef max dosya boyutu (varsayılan 1 MB)
  /// - [maxDimension]: Hedef max piksel genişliği/yüksekliği (varsayılan 256)
  ///
  /// Orijinal boyut zaten hedefin altındaysa bile resize + re-encode yapılır
  /// (tutarlı kalite ve boyut garantisi için).
  static Uint8List compress(
    Uint8List bytes, {
    int maxSizeBytes = defaultMaxSizeBytes,
    int maxDimension = defaultMaxDimension,
  }) {
    // 1. Decode
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // Decode başarısızsa orijinali döndür
      return bytes;
    }

    // 2. Resize — en-boy oranını koruyarak küçült
    img.Image resized;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      if (decoded.width >= decoded.height) {
        resized = img.copyResize(decoded, width: maxDimension);
      } else {
        resized = img.copyResize(decoded, height: maxDimension);
      }
    } else {
      resized = decoded;
    }

    // 3. İteratif JPEG encode — hedef boyutun altına düşene kadar kaliteyi düşür
    for (final quality in _qualitySteps) {
      final compressed = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );

      if (compressed.lengthInBytes <= maxSizeBytes) {
        return compressed;
      }
    }

    // En düşük kalitede bile hedefin üstündeyse (çok nadir), son sonucu döndür
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: _qualitySteps.last),
    );
  }
}
