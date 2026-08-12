import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/data/database.dart';

/// There is no way to compile or run Kotlin unit tests for
/// GusteauBackupAgent in this repo without an Android SDK — see the
/// comment on GusteauBackupAgent.DATABASE_FILE_NAME. CI's
/// `flutter build apk` is the first thing that actually compiles it.
///
/// What this test *can* do, with nothing more than plain file I/O, is
/// catch the specific failure mode that matters most: the database
/// filename, or the manifest wiring, silently drifting out of sync
/// between Dart and the native Android backup config. That's exactly
/// the kind of thing that fails silently in the field — an Auto Backup
/// snapshot that quietly backs up nothing, or a checkpoint that quietly
/// checkpoints the wrong file — with no error anywhere. See
/// docs/planning/architecture.md, "Backup and durability".
void main() {
  late String androidAppDir;

  setUpAll(() {
    // test/ and android/ are siblings under app/.
    androidAppDir = '${Directory.current.path}/android/app/src/main';
  });

  test('data_extraction_rules.xml includes exactly the drift database file', () {
    final xml = File(
      '$androidAppDir/res/xml/data_extraction_rules.xml',
    ).readAsStringSync();
    expect(xml, contains('path="$kDatabaseFileName"'));
    // Include-only semantics exclude the WAL sidecars and the
    // secure-storage prefs by *not* matching them — if this file ever
    // grows another <include> tag, that reasoning (see the comments in
    // the XML itself) needs re-checking by hand. Matches the tag, not
    // the word, since the explanatory comment above also says
    // "include" several times in prose.
    expect(
      RegExp('<include ').allMatches(xml).length,
      2,
      reason: 'cloud-backup + device-transfer, one include each',
    );
  });

  test('legacy backup_rules.xml includes exactly the drift database file', () {
    final xml = File('$androidAppDir/res/xml/backup_rules.xml').readAsStringSync();
    expect(xml, contains('path="$kDatabaseFileName"'));
  });

  test('GusteauBackupAgent checkpoints the same file drift opens', () {
    final kotlin = File(
      '$androidAppDir/kotlin/com/gusteau/gusteau/GusteauBackupAgent.kt',
    ).readAsStringSync();
    expect(kotlin, contains('DATABASE_FILE_NAME = "$kDatabaseFileName"'));
  });

  test('AndroidManifest.xml actually wires up the backup agent and rules', () {
    final manifest = File('$androidAppDir/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:backupAgent=".GusteauBackupAgent"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });
}
