import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the dependency rules from docs/code-conventions/architecture.md.
void main() {
  const sdks = [
    'package:cloud_firestore/',
    'package:firebase_auth/',
    'package:firebase_core/',
    'package:supabase_flutter/',
  ];

  List<File> filesIn(String layer) =>
      Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => file.path.contains('/$layer/'))
          .toList();

  List<String> importsOf(File file) => file
      .readAsLinesSync()
      .where((line) => line.startsWith('import ') || line.startsWith('export '))
      .toList();

  List<String> violations(String layer, List<String> banned) => [
    for (final file in filesIn(layer))
      for (final line in importsOf(file))
        if (banned.any(line.contains)) '${file.path}: $line',
  ];

  test('domain depends on neither Flutter nor any SDK', () {
    expect(violations('domain', [...sdks, 'package:flutter/']), isEmpty);
  });

  test('application depends on no SDK and no widgets', () {
    expect(
      violations('application', [...sdks, 'package:flutter/material.dart']),
      isEmpty,
    );
  });

  test('presentation never touches an SDK directly', () {
    expect(violations('presentation', sdks), isEmpty);
  });

  test('features reach each other only through barrel files', () {
    final offenders = <String>[];
    for (final file
        in Directory('lib/features')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      final ownFeature = file.path.split('/')[2];
      for (final line in importsOf(file)) {
        final match = RegExp(r"features/(\w+)/(.+)'").firstMatch(line);
        if (match == null) continue;
        final otherFeature = match.group(1)!;
        final target = match.group(2)!;
        if (otherFeature != ownFeature && target.contains('/')) {
          offenders.add('${file.path}: $line');
        }
      }
      for (final line in importsOf(file)) {
        final crossFeature = RegExp(r"'\.\./\.\./(\w+)/(.+)'").firstMatch(line);
        if (crossFeature != null &&
            crossFeature.group(1) != ownFeature &&
            crossFeature.group(2)!.contains('/')) {
          offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
