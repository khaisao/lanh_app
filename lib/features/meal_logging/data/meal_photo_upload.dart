import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../domain/meal_photo_repository.dart';

/// Encoded photo bytes ready for the meal analysis endpoint.
final class MealPhotoUpload {
  const MealPhotoUpload(this.bytes, this.mimeType, this.fileName);

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

/// The service accepts JPEG, PNG and WebP up to 10 MB; the model sees far
/// fewer pixels, so large or unsupported photos (for example HEIC) are
/// decoded with the platform codec and re-encoded as a bounded PNG.
const _maxPassThroughBytes = 4 * 1024 * 1024;
const _maxEncodedSide = 1600;

Future<MealPhotoUpload> prepareMealPhotoUpload(MealPhoto photo) async {
  final bytes = photo.bytes;
  final mimeType = _sniffMimeType(bytes);
  if (mimeType != null && bytes.length <= _maxPassThroughBytes) {
    return MealPhotoUpload(bytes, mimeType, 'meal.${mimeType.split('/').last}');
  }
  return MealPhotoUpload(
    await _encodeBoundedPng(bytes),
    'image/png',
    'meal.png',
  );
}

String? _sniffMimeType(Uint8List bytes) {
  bool startsWith(List<int> prefix, [int offset = 0]) =>
      bytes.length >= offset + prefix.length &&
      Iterable<int>.generate(prefix.length)
          .every((index) => bytes[offset + index] == prefix[index]);
  if (startsWith(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith(const [0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (startsWith('RIFF'.codeUnits) && startsWith('WEBP'.codeUnits, 8)) {
    return 'image/webp';
  }
  return null;
}

Future<Uint8List> _encodeBoundedPng(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final longest = math.max(descriptor.width, descriptor.height);
  final scale = longest > _maxEncodedSide ? _maxEncodedSide / longest : 1.0;
  final codec = await descriptor.instantiateCodec(
    targetWidth: (descriptor.width * scale).round(),
    targetHeight: (descriptor.height * scale).round(),
  );
  final frame = await codec.getNextFrame();
  try {
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('PNG encoding failed.');
    return data.buffer.asUint8List();
  } finally {
    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  }
}
