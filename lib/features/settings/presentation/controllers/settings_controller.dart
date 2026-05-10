import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final AppDatabase db = AppDatabase();

  final RxString appVersion = ''.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool databaseBusy = false.obs;
  final RxString databaseStatus = 'Ready'.obs;
  final RxList<DriverProfile> driverProfiles = <DriverProfile>[].obs;
  final RxBool driverProfilesBusy = false.obs;

  void selectCategory(int index) => selectedCategoryIndex.value = index;
  void setDatabaseStatus(String value) => databaseStatus.value = value;
  void setDatabaseBusy(bool value) => databaseBusy.value = value;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    loadDriverProfiles();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;
      appVersion.value = build.isEmpty ? 'v$version' : 'v$version+$build';
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
        fs.XTypeGroup(label: 'Database', extensions: ['db']),
      ],
    );
    if (location == null) return null; // user cancelled
    final path = location.path;
    await db.backupDatabaseToPath(path);
    return path;
  }

  Future<void> loadDriverProfiles() async {
    driverProfilesBusy.value = true;
    try {
      final profiles = await db.getDriverProfiles();
      driverProfiles.assignAll(profiles);
    } finally {
      driverProfilesBusy.value = false;
    }
  }

  Future<void> addDriverProfile({required String name, String? phone}) async {
    await db.insertDriverProfile(name: name, phone: phone);
    await loadDriverProfiles();
  }

  Future<void> updateDriverProfile({
    required DriverProfile profile,
    required String name,
    String? phone,
    required bool active,
  }) async {
    await db.updateDriverProfile(
      id: profile.id,
      name: name,
      phone: phone,
      active: active,
    );
    await loadDriverProfiles();
  }

  Future<void> setDriverProfileActive({
    required DriverProfile profile,
    required bool active,
  }) async {
    await db.setDriverProfileActive(id: profile.id, active: active);
    await loadDriverProfiles();
  }

  // Pick a .db file and replace the current database with it.
  // On null, restore succeeded and the app must exit or restart immediately.
  Future<String?> restoreFromFileReplaceWithMessage() async {
    final xfile = await fs.openFile(
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'Database', extensions: ['db']),
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
        final header = await src
            .openRead(0, 16)
            .fold<List<int>>(<int>[], (p, e) => p..addAll(e));
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
}
