import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding_provider.dart';

class ProvinceSelectorWidget extends ConsumerStatefulWidget {
  final String? selectedId;
  final String? selectedName;
  final void Function(String id, String name) onSelected;

  const ProvinceSelectorWidget({
    super.key,
    required this.selectedId,
    required this.selectedName,
    required this.onSelected,
  });

  @override
  ConsumerState<ProvinceSelectorWidget> createState() =>
      _ProvinceSelectorWidgetState();
}

class _ProvinceSelectorWidgetState
    extends ConsumerState<ProvinceSelectorWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villesAsync = ref.watch(villesTourquieProvider);

    return InkWell(
      onTap: () => _showPicker(context, villesAsync),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_city, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.selectedName ?? 'İl Seç...',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.selectedName == null
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)
                      : null,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, AsyncValue<VillesTourquie> async) {
    _searchController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'İl Seç',
        searchController: _searchController,
        async: async,
        itemBuilder: (villesAsync) {
          return villesAsync.when(
            loading: () =>
                [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [Center(child: Text('Hata: $e'))],
            data: (villes) {
              final query =
                  _searchController.text.toLowerCase();
              final filtered = villes.provinces
                  .where((p) =>
                      p.nom.toLowerCase().contains(query))
                  .toList();
              return filtered.map((p) => ListTile(
                    title: Text(p.nom),
                    onTap: () {
                      widget.onSelected(p.id, p.nom);
                      Navigator.pop(context);
                    },
                  )).toList();
            },
          );
        },
      ),
    );
  }
}

class DistrictSelectorWidget extends ConsumerStatefulWidget {
  final String? provinceId;
  final String? selectedId;
  final String? selectedName;
  final void Function(String id, String name) onSelected;

  const DistrictSelectorWidget({
    super.key,
    required this.provinceId,
    required this.selectedId,
    required this.selectedName,
    required this.onSelected,
  });

  @override
  ConsumerState<DistrictSelectorWidget> createState() =>
      _DistrictSelectorWidgetState();
}

class _DistrictSelectorWidgetState
    extends ConsumerState<DistrictSelectorWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villesAsync = ref.watch(villesTourquieProvider);
    final isEnabled = widget.provinceId != null;

    return InkWell(
      onTap:
          isEnabled ? () => _showPicker(context, villesAsync) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled
                ? Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.4)
                : Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.pin_drop,
                size: 20,
                color: isEnabled
                    ? null
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.selectedName ?? 'İlçe Seç...',
                style: TextStyle(
                  fontSize: 15,
                  color: !isEnabled || widget.selectedName == null
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)
                      : null,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down,
                color: isEnabled
                    ? null
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, AsyncValue<VillesTourquie> async) {
    _searchController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'İlçe Seç',
        searchController: _searchController,
        async: async,
        itemBuilder: (villesAsync) {
          return villesAsync.when(
            loading: () =>
                [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [Center(child: Text('Hata: $e'))],
            data: (villes) {
              final province = villes.provinces.firstWhere(
                (p) => p.id == widget.provinceId,
                orElse: () => const Province(
                    id: '', nom: '', districts: []),
              );
              final query =
                  _searchController.text.toLowerCase();
              final filtered = province.districts
                  .where((d) =>
                      d.nom.toLowerCase().contains(query))
                  .toList();
              return filtered.map((d) => ListTile(
                    title: Text(d.nom),
                    onTap: () {
                      widget.onSelected(d.id, d.nom);
                      Navigator.pop(context);
                    },
                  )).toList();
            },
          );
        },
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final String title;
  final TextEditingController searchController;
  final AsyncValue<VillesTourquie> async;
  final List<Widget> Function(AsyncValue<VillesTourquie>) itemBuilder;

  const _PickerSheet({
    required this.title,
    required this.searchController,
    required this.async,
    required this.itemBuilder,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Ara...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: widget.itemBuilder(widget.async),
              ),
            ),
          ],
        );
      },
    );
  }
}
