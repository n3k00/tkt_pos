import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final RxBool compactTable = false.obs;
  final RxString appVersion = ''.obs;

  void setCompactTable(bool v) => compactTable.value = v;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;
      appVersion.value = 'v$version (beta)';
      if (build.isNotEmpty) {
        appVersion.value = 'v$version+$build (beta)';
      }
    } catch (_) {
      appVersion.value = 'beta';
    }
  }

  Future<String?> backupDb() async {
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final suggestedName = 'tkt_pos-$ts.db';
    final location = await fs.getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'Database', extensions: ['db'])
      ],
    );
    if (location == null) return null; // user cancelled
    final path = location.path;
    await AppDatabase().backupDatabaseToPath(path);
    return path;
  }

  Future<bool> restoreLatestBackup() async {
    final dir = await getApplicationSupportDirectory();
    final backupsDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupsDir.exists()) return false;
    final files = backupsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.db'))
        .toList();
    if (files.isEmpty) return false;
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final latest = files.first;
    final ok = await AppDatabase.restoreFromBackup(latest.path) != null;
    return ok;
  }

  // Pick a .db file and REPLACE current database with it
  Future<String?> restoreFromFileReplaceWithMessage() async {
    final xfile = await fs.openFile(
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'Database', extensions: ['db'])
      ],
    );
    if (xfile == null) return 'User cancelled.';

    try {
      final src = File(xfile.path);
      if (!await src.exists()) {
        return 'Selected file not found.';
      }
      final len = await src.length();
      if (len == 0) {
        return 'Selected file is empty (0 bytes).';
      }
      // Quick sanity check for SQLite header
      try {
        final header = await src.openRead(0, 16).fold<List<int>>(<int>[], (p, e) => p..addAll(e));
        final headerStr = String.fromCharCodes(header);
        if (!headerStr.startsWith('SQLite format 3')) {
          return 'Selected file is not a valid SQLite database.';
        }
      } catch (_) {}

      final replaced = await AppDatabase.restoreFromBackup(src.path);
      if (replaced == null) {
        // Try to give destination hint
        try {
          final dir = await getApplicationSupportDirectory();
          final dst = p.join(dir.path, 'app.db');
          return 'Failed to replace database. Destination: $dst';
        } catch (_) {
          return 'Failed to replace database.';
        }
      }
      return null; // success
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Backwards-compatible boolean wrapper (unused by UI after update)
  Future<bool> restoreFromFileReplace() async {
    final msg = await restoreFromFileReplaceWithMessage();
    return msg == null;
  }

  Future<bool> restoreFromFileMerge() async {
    final xfile = await fs.openFile(
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'Database', extensions: ['db'])
      ],
    );
    if (xfile == null) return false; // user cancelled
    await AppDatabase().mergeFromDatabaseFile(xfile.path);
    return true;
  }
}
