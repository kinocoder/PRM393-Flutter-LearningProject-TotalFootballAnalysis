import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/b03_view_model.dart';

class B03Screen extends ConsumerWidget {
  const B03Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(b03ViewModelProvider);
    final viewModel = ref.read(b03ViewModelProvider.notifier);
    final query = state.draftQuery;
    final options = state.filterOptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ Lọc Cầu Thủ'),
        actions: [
          TextButton(
            onPressed: viewModel.resetFilter,
            child: const Text('Đặt lại', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Vị trí thi đấu (FilterChip)
          _buildSectionTitle('Vị trí thi đấu'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (options['positions'] ?? []).map((pos) {
              final isSelected = query.positions.contains(pos);
              return FilterChip(
                label: Text(pos),
                selected: isSelected,
                onSelected: (_) => viewModel.togglePosition(pos),
              );
            }).toList(),
          ),
          const Divider(height: 32),

          // 2. Chỉ số OVR tối thiểu (Slider)
          _buildSectionTitle('Chỉ số OVR tối thiểu: ${query.minOvr ?? "Tất cả"}'),
          Slider(
            value: (query.minOvr ?? 60).toDouble(),
            min: 60,
            max: 99,
            divisions: 39,
            label: '${query.minOvr ?? 60}',
            onChanged: (val) => viewModel.setMinOvr(val.toInt()),
          ),
          const Divider(height: 32),

          // 3. Mùa thẻ (Card Version)
          _buildDropdown(
            label: 'Card Version',
            value: query.cardVersion,
            items: options['cardVersions'] ?? [],
            onChanged: viewModel.selectCardVersion,
          ),
          const SizedBox(height: 12),

          // 4. Câu lạc bộ
          _buildDropdown(
            label: 'Câu lạc bộ',
            value: query.club,
            items: options['clubs'] ?? [],
            onChanged: viewModel.selectClub,
          ),
          const SizedBox(height: 12),

          // 5. Quốc tịch
          _buildDropdown(
            label: 'Quốc gia / Quốc tịch',
            value: query.nation,
            items: options['nations'] ?? [],
            onChanged: viewModel.selectNation,
          ),
          const Divider(height: 32),

          // 6. Sắp xếp (Sort)
          _buildSectionTitle('Sắp xếp theo'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('OVR giảm dần'),
                selected: query.sort == 'ovr_desc',
                onSelected: (_) => viewModel.setSort('ovr_desc'),
              ),
              ChoiceChip(
                label: const Text('OVR tăng dần'),
                selected: query.sort == 'ovr_asc',
                onSelected: (_) => viewModel.setSort('ovr_asc'),
              ),
              ChoiceChip(
                label: const Text('Tên (A-Z)'),
                selected: query.sort == 'name_asc',
                onSelected: (_) => viewModel.setSort('name_asc'),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                viewModel.applyFilter();
                Navigator.of(context).pop();
              },
              child: Text(
                'Xem ${state.matchedCount} cầu thủ phù hợp',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      initialValue: value,
      isExpanded: true,
      items: [
        const DropdownMenuItem(value: null, child: Text('Tất cả')),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}