import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/ui/catalog/view_models/b02_view_model.dart';
import 'package:united2/ui/catalog/widgets/b02_screen.dart';

class FakeB02ViewModel extends B02ViewModel {
  final SearchState _initialState;
  FakeB02ViewModel(this._initialState);

  @override
  SearchState build() => _initialState;
}

void main() {
  const player1 = Player(
    id: '9284',
    name: 'K. Mbappé',
    fullName: 'Kylian Mbappé',
    position: 'ST',
    cardVersion: 'TOTY',
    ovr: 125,
    level: 10,
    positionRatings: {'ST': 125},
    stats: {'PAC': 132},
    statDetails: {},
    nation: 'Pháp',
    club: 'Real Madrid',
    age: 25,
    heightCm: 178,
    weightKg: 75,
    skillMoves: 5,
  );

  group('B02Screen Widget Tests (Search)', () {
    testWidgets('displays initial prompt state before user enters search query', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b02ViewModelProvider.overrideWith(() => FakeB02ViewModel(const SearchState())),
          ],
          child: const MaterialApp(
            home: B02Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nhập tên hoặc biệt danh cầu thủ để tìm kiếm'), findsOneWidget);
    });

    testWidgets('typing search query displays matching player tiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b02ViewModelProvider.overrideWith(
              () => FakeB02ViewModel(const SearchState(query: 'mbappe', results: [player1])),
            ),
          ],
          child: const MaterialApp(
            home: B02Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('K. Mbappé'), findsOneWidget);
      expect(find.text('Real Madrid • Pháp'), findsOneWidget);
    });

    testWidgets('displays empty state when no player matches search query', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b02ViewModelProvider.overrideWith(
              () => FakeB02ViewModel(const SearchState(query: 'xyz', results: [])),
            ),
          ],
          child: const MaterialApp(
            home: B02Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy cầu thủ nào khớp với "xyz"'), findsOneWidget);
    });
  });
}
