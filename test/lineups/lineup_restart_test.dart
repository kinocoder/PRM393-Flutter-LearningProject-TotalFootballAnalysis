import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/services/local_database_service.dart';
import 'package:united2/ui/lineups/view_models/c01_view_model.dart';
import 'package:united2/ui/lineups/view_models/c04_view_model.dart';

/// Test restart process: chạy 2 lần, mỗi lần là một process riêng.
/// Bình thường bỏ qua. Muốn chạy thì dùng 2 lệnh (cùng một đường dẫn file):
///   flutter test test/lineups/lineup_restart_test.dart --dart-define=RESTART_DB=C:/temp/r.db --dart-define=RESTART_PHASE=write
///   flutter test test/lineups/lineup_restart_test.dart --dart-define=RESTART_DB=C:/temp/r.db --dart-define=RESTART_PHASE=read
void main() {
  const dbPath = String.fromEnvironment('RESTART_DB');
  const phase = String.fromEnvironment('RESTART_PHASE');

  ProviderContainer openApp(LocalDatabaseService service) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final container = ProviderContainer.test(
      overrides: [localDatabaseServiceProvider.overrideWithValue(service)],
    );
    container.listen(c01ViewModelProvider, (_, _) {});
    return container;
  }

  test(
    'Tắt process rồi mở lại vẫn còn đội hình đã lưu',
    () async {
      final service = LocalDatabaseService(path: dbPath);
      addTearDown(service.close);
      final container = openApp(service);

      if (phase == 'write') {
        // Ghi số process vào tên để lần đọc biết chắc là process khác
        final lineup = await container
            .read(c01ViewModelProvider.notifier)
            .createLineup('pid-$pid');
        final provider = c04ViewModelProvider(lineup.id);
        container.listen(provider, (_, _) {});
        await container.read(provider.future);
        container.read(provider.notifier).setPlayer('ST', '9284');
        await container.read(provider.notifier).save();
        return;
      }

      final lineups = await container.read(c01ViewModelProvider.future);
      final lineup = lineups.first;
      expect(lineup.name, startsWith('pid-'));
      expect(lineup.name, isNot('pid-$pid'));
      expect(lineup.slots, {'ST': '9284'});
    },
    skip: phase.isEmpty ? 'Chỉ chạy khi có --dart-define=RESTART_PHASE' : false,
  );
}
