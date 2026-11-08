import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/catalog/view_models/b01_view_model.dart';
import 'package:united2/ui/catalog/widgets/b01_screen.dart';

class FakeB01ViewModel extends B01ViewModel {
  final List<Player> _players;
  FakeB01ViewModel(this._players);

  @override
  Future<List<Player>> build() async => _players;
}

void main() {
  const player1 = Player(
    id: '9275',
    name: 'O. Dembélé',
    fullName: 'Ousmane Dembélé',
    position: 'RW',
    cardVersion: 'TOTS',
    ovr: 123,
    level: 10,
    positionRatings: {'RW': 123},
    stats: {'PAC': 128},
    statDetails: {},
    nation: 'Pháp',
    club: 'FC Barcelona',
    age: 27,
    heightCm: 178,
    weightKg: 73,
    skillMoves: 5,
  );

  group('B01Screen Widget Tests', () {
    testWidgets('displays player list when data is loaded successfully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b01ViewModelProvider.overrideWith(() => FakeB01ViewModel([player1])),
          ],
          child: const MaterialApp(
            home: B01Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Danh mục cầu thủ'), findsOneWidget);
      expect(find.text('O. DEMBÉLÉ'), findsOneWidget);
      expect(find.text('FC Barcelona · Pháp'), findsOneWidget);
    });

    testWidgets('displays empty list message when repository returns no players', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b01ViewModelProvider.overrideWith(() => FakeB01ViewModel([])),
          ],
          child: const MaterialApp(
            home: B01Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Danh sách rỗng'), findsOneWidget);
    });

    testWidgets('clicking search icon navigates to B02 screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b01ViewModelProvider.overrideWith(() => FakeB01ViewModel([player1])),
          ],
          child: MaterialApp(
            home: const B01Screen(),
            routes: {
              AppRoutes.b02: (_) => const Scaffold(body: Text('Screen B02')),
              AppRoutes.b03: (_) => const Scaffold(body: Text('Screen B03')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('Screen B02'), findsOneWidget);
    });
  });
}
