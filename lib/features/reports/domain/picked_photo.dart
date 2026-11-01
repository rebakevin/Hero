import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A photo the user chose, already compressed to JPEG and within the size limit.
class PickedPhoto extends Equatable {
  const PickedPhoto(this.bytes);

  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes];
}
