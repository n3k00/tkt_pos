import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:file_selector/file_selector.dart' as fs;

class SettingsController extends GetxController {
  final RxBool compactTable = false.obs;

  void setCompactTable(bool v) => compactTable.value = v;

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
