import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routing/app_routes.dart';
import '../../core/widgets/player_tile.dart';
import '../view_models/b02_view_model.dart';

class B02Screen extends ConsumerStatefulWidget {
  const B02Screen({super.key});

  @override
  ConsumerState<B02Screen> createState() => _B02ScreenState();
}

class _B02ScreenState extends ConsumerState<B02Screen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(b02ViewModelProvider);
    final viewModel = ref.read(b02ViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nhập tên cầu thủ...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  splashRadius: 18,
                  onPressed: () {
                    _searchController.clear();
                    viewModel.clearQuery();
                    setState(() {});
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                setState(() {}); // Làm mới icon Clear
                viewModel.onQueryChanged(value);
              },
            ),
          ),
        ),
      ),
      body: _buildContent(context, searchState),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    // 1. Trạng thái ban đầu: Chưa nhập từ khóa (isInitial)
    if (state.isInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nhập tên hoặc biệt danh cầu thủ để tìm kiếm',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // 2. Trạng thái không có kết quả khớp (isEmptyResult)
    if (state.isEmptyResult) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy cầu thủ nào khớp với "${state.query}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử kiểm tra lại chính tả hoặc tìm bằng họ/tên rút gọn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Trạng thái hiển thị danh sách kết quả
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final player = state.results[index];
        return PlayerTile(
          player: player,
          onTap: () {
            Navigator.pushNamed(
                context,
                AppRoutes.b04,
                arguments: player.id,
            );
          },
        );
      },
    );
  }
}