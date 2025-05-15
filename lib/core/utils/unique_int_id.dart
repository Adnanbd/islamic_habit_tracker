import 'dart:developer';

import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

int generateUniqueIntId() {
  final uuid = const Uuid().v4();
  final bytes = utf8.encode(uuid);
  final digest = sha1.convert(bytes);
  // Take first 4 bytes from the digest and convert to int
  int uniqueId = digest.bytes.sublist(0, 4).fold(0, (a, b) => (a << 8) + b);
  log('uniqueId: $uniqueId', name: 'generateUniqueIntId');
  return uniqueId;
}
